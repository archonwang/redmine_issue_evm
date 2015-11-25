include ProjectAndVersionValue

class EvmbaselinesController < ApplicationController
  unloadable

  menu_item :issuevm
  before_action :find_project, :authorize

  def index
    @evm_baselines = Evmbaseline.where("project_id = ? ", @project.id).order("created_on DESC")
  end

  def new
    @evm_baselines = Evmbaseline.new
    issues = project_issues @project
    @start_date = issues.minimum(:start_date)
    @due_date = issues.maximum(:due_date)
    @bac = 0.0
    issues.each do |issue|
      @bac = @bac + issue.estimated_hours.to_f
    end
  end

  def edit
    @evm_baselines = Evmbaseline.find(params[:id])
  end

  def update
    evm_baselines = Evmbaseline.find(params[:id])
    evm_baselines.update_attributes(params[:evmbaseline])
    if evm_baselines.save
      flash[:notice] = l(:notice_successful_update)
      redirect_to :action => 'index'
    else
      redirect_to :action => 'edit'
    end
  end

  def create
    evm_baselines = Evmbaseline.new(params[:evmbaseline])
    evm_baselines.project_id = @project.id
    evm_baselines.state = l(:label_current_baseline)
    #issues
    issues = project_issues @project
    issues.each do |issue|
      baseline_issues = EvmbaselineIssue.new(issue_id: issue.id, start_date: issue.start_date, due_date: issue.due_date, estimated_hours: issue.estimated_hours, leaf: issue.leaf?)
      evm_baselines.evmbaselineIssues << baseline_issues
    end
    #update status
    Evmbaseline.where(project_id: @project.id).update_all(state: l(:label_old_baseline))
    #Save
    if evm_baselines.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to :action => 'index'
    else
      redirect_to :action => 'new'
    end
  end

  def destroy
    evm_baselines = Evmbaseline.find(params[:id])
    evm_baselines.destroy
    flash[:notice] = l(:notice_successful_delete)
    redirect_to :action => 'index'
  end

private
  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
