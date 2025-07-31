class ProjectsController < ApplicationController
    before_action :authenticate_request! 
    before_action :set_project, only: [:show, :update, :destroy]
    before_action :authorize_project_access, only: [:show] 
    before_action :authorize_project_owner, only: [:update, :destroy] 
  
    
    def index
     
      user_projects = current_user.owned_projects.or(current_user.projects)
  
      
      @projects = user_projects.by_status(params[:status])
                               .by_priority(params[:priority])
                               .distinct 
  
      render json: @projects, include: [:creator, :project_members] 
    end
  
   
    def show
      render json: @project, include: [:creator, :members, :tasks] 
    end
  
   
    def create
      
      @project = current_user.owned_projects.build(project_params)
  
     
      @project.project_members.build(user: current_user, role: :owner)
  
      if @project.save
        render json: @project, status: :created, include: [:creator, :project_members]
      else
        render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
   
    def update
      if @project.update(project_params)
        render json: @project, include: [:creator, :project_members]
      else
        render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
   
    def destroy
      @project.destroy
      head :no_content 
    end
  
    private
  
    def set_project
      @project = Project.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Project not found' }, status: :not_found
    end
  
    def project_params
      params.require(:project).permit(:title, :description, :start_date, :end_date, :status, :priority)
    end
  
   
    def authorize_project_access
      unless current_user.member_of_project?(@project) || current_user.owns_project?(@project)
        render json: { error: 'You are not authorized to view this project.' }, status: :forbidden 
      end
    end
  
    
    def authorize_project_owner
      unless current_user.owns_project?(@project)
        render json: { error: 'You are not authorized to perform this action.' }, status: :forbidden 
      end
    end
end