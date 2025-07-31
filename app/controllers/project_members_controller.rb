class ProjectMembersController < ApplicationController
    before_action :authenticate_request!
    before_action :set_project # Assumes project_id from nested route
    before_action :authorize_project_owner # Only project owner can manage members
    before_action :set_project_member, only: [:update, :destroy]
  
    # GET /projects/:project_id/members
    def index
      @project_members = @project.project_members.includes(:user) # Eager load user data
      render json: @project_members, include: [:user] # Include user details
    end
  
    # POST /projects/:project_id/members
    def create
      # Find the user to invite
      invited_user = User.find_by(email: params[:user_email]) # Assuming email is passed to find user
      unless invited_user
        render json: { error: 'User with provided email not found.' }, status: :unprocessable_entity
        return
      end
  
      # Build the new project member
      @project_member = @project.project_members.build(user: invited_user, role: project_member_params[:role])
  
      if @project_member.save
        render json: @project_member, status: :created, include: [:user]
      else
        render json: { errors: @project_member.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /projects/:project_id/members/:id
    def update
      # Prevent the project owner from changing their own role to something less than 'owner'
      if @project_member.user == @project.creator && project_member_params[:role].to_i != ProjectMember.roles[:owner]
        render json: { error: "Project creator's role cannot be changed from 'owner'." }, status: :forbidden
        return
      end
  
      if @project_member.update(project_member_params)
        render json: @project_member, include: [:user]
      else
        render json: { errors: @project_member.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    # DELETE /projects/:project_id/members/:id
    def destroy
      # Prevent the project owner from removing themselves
      if @project_member.user == @project.creator
        render json: { error: "Project creator cannot be removed from the project." }, status: :forbidden
        return
      end
  
      @project_member.destroy
      head :no_content
    end
  
    private
  
    def set_project
      @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Project not found' }, status: :not_found
    end
  
    def set_project_member
      @project_member = @project.project_members.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Project member not found' }, status: :not_found
    end
  
    def project_member_params
      params.require(:project_member).permit(:user_id, :role, :user_email) # user_email for create, user_id for update/destroy
    end
  
    # Authorization check: User must be the project owner to manage members
    def authorize_project_owner
      unless current_user.owns_project?(@project)
        render json: { error: 'You are not authorized to manage project members.' }, status: :forbidden
      end
    end
end