class TasksController < ApplicationController
    before_action :authenticate_request!
    before_action :set_project # From nested route
    before_action :authorize_project_member_access # Only project members can access tasks
    before_action :set_task, only: [:show, :update, :destroy]
    before_action :authorize_task_modification, only: [:update, :destroy] # More granular task auth
  
    # GET /projects/:project_id/tasks
    def index
      # Fetch all tasks for the project, optionally filtering
      @tasks = @project.tasks.by_status(params[:status])
                               .by_priority(params[:priority])
                               .assigned_to(params[:assignee_id])
                               .top_level # Only fetch top-level tasks by default
  
      # You might want to include subtasks for each task in the serializer
      render json: @tasks, include: [:assignee, :subtasks, :checklist_items]
    end
  
    # GET /projects/:project_id/tasks/:id
    def show
      render json: @task, include: [:assignee, :parent_task, :subtasks, :checklist_items, :comments]
    end
  
    # POST /projects/:project_id/tasks
    def create
      @task = @project.tasks.build(task_params)
      # Ensure assignee is part of the project if assigned
      if @task.assignee_id.present? && !@project.members.exists?(id: @task.assignee_id)
        render json: { error: 'Assigned user is not a member of this project.' }, status: :unprocessable_entity
        return
      end
  
      if @task.save
        render json: @task, status: :created, include: [:assignee]
      else
        render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /projects/:project_id/tasks/:id
    def update
      # The `authorize_task_modification` handles general access.
      # Here you might add specific logic, e.g., assignee can only update status.
      if @task.update(task_params)
        render json: @task, include: [:assignee]
      else
        render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    # DELETE /projects/:project_id/tasks/:id
    def destroy
      @task.destroy
      head :no_content
    end
  
    private
  
    def set_project
      @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Project not found' }, status: :not_found
    end
  
    def set_task
      @task = @project.tasks.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Task not found in this project' }, status: :not_found
    end
  
    def task_params
      params.require(:task).permit(
        :title, :description, :assignee_id, :parent_task_id,
        :status, :priority, :due_date
      )
    end
  
    # Authorization: User must be a member (or owner) of the project
    def authorize_project_member_access
      unless current_user.member_of_project?(@project) || current_user.owns_project?(@project)
        render json: { error: 'You are not authorized to access tasks in this project.' }, status: :forbidden
      end
    end
  
    # Authorization: More granular for task modification (update/destroy)
    def authorize_task_modification
      # Project owner can modify any task
      return if current_user.owns_project?(@project)
  
      # Project member can modify tasks, but consider restrictions (e.g., cannot delete others' tasks)
      # For now, let's say members can update but only owners can delete or modify all fields.
      # Refine this based on your specific role-based permissions.
      # Example: if action is :destroy, only owner can delete.
      if action_name == 'destroy'
        unless current_user.owns_project?(@project)
          render json: { error: 'Only project owners can delete tasks.' }, status: :forbidden
        end
      else # For update
        # Allow assignee to update status, but only project members/owners to change other fields
        # This is a common requirement. For simplicity now, if you are a member, you can update.
        # But you'd build out more detailed logic here if needed.
        unless current_user.member_of_project?(@project)
          render json: { error: 'You are not authorized to modify tasks in this project.' }, status: :forbidden
        end
      end
    end
  end