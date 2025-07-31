class ChecklistItemsController < ApplicationController
    before_action :authenticate_request!
    before_action :set_task # From nested route
    before_action :authorize_task_access # Ensure user has access to parent task's project
    before_action :set_checklist_item, only: [:update, :destroy]
  
    # GET /tasks/:task_id/checklists
    def index
      @checklist_items = @task.checklist_items
      render json: @checklist_items
    end
  
    # POST /tasks/:task_id/checklists
    def create
      @checklist_item = @task.checklist_items.build(checklist_item_params)
      if @checklist_item.save
        render json: @checklist_item, status: :created
      else
        render json: { errors: @checklist_item.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /tasks/:task_id/checklists/:id
    def update
      if @checklist_item.update(checklist_item_params)
        render json: @checklist_item
      else
        render json: { errors: @checklist_item.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    # DELETE /tasks/:task_id/checklists/:id
    def destroy
      @checklist_item.destroy
      head :no_content
    end
  
    private
  
    def set_task
      @task = Task.find(params[:task_id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Task not found' }, status: :not_found
    end
  
    def set_checklist_item
      @checklist_item = @task.checklist_items.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Checklist item not found' }, status: :not_found
    end
  
    def checklist_item_params
      params.require(:checklist_item).permit(:content, :completed)
    end
  
    # Authorization: User must be a member (or owner) of the project containing the task
    def authorize_task_access
      project = @task.project
      unless current_user.member_of_project?(project) || current_user.owns_project?(project)
        render json: { error: 'You are not authorized to access this task\'s checklist.' }, status: :forbidden
      end
    end
end