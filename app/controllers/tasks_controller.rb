class TasksController < ApplicationController
    before_action :authenticate_request!
    before_action :set_project 
    before_action :authorize_project_member_access 
    before_action :set_task, only: [:show, :update, :destroy]
    before_action :authorize_task_modification, only: [:update, :destroy] 
  
  
    def index
      
      @tasks = @project.tasks.by_status(params[:status])
                               .by_priority(params[:priority])
                               .assigned_to(params[:assignee_id])
                               .top_level 
  
     
      render json: @tasks, include: [:assignee, :subtasks, :checklist_items]
    end
  
   
    def show
      render json: @task, include: [:assignee, :parent_task, :subtasks, :checklist_items, :comments]
    end
  
    
    def create
      @task = @project.tasks.build(task_params)
     
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
  
   
    def update
     
      if @task.update(task_params)
        render json: @task, include: [:assignee]
      else
        render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
   
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
  
  
    def authorize_project_member_access
      unless current_user.member_of_project?(@project) || current_user.owns_project?(@project)
        render json: { error: 'You are not authorized to access tasks in this project.' }, status: :forbidden
      end
    end
  
    
    def authorize_task_modification
    
      return if current_user.owns_project?(@project)
  
     
      if action_name == 'destroy'
        unless current_user.owns_project?(@project)
          render json: { error: 'Only project owners can delete tasks.' }, status: :forbidden
        end
      else 
        unless current_user.member_of_project?(@project)
          render json: { error: 'You are not authorized to modify tasks in this project.' }, status: :forbidden
        end
      end
    end
end