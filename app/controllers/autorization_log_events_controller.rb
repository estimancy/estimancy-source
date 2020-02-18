class AutorizationLogEventsController < ApplicationController
  before_filter :set_autorization_log_event, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @autorization_log_events = AutorizationLogEvent.all
    respond_with(@autorization_log_events)
  end

  def show
    respond_with(@autorization_log_event)
  end

  def new
    @autorization_log_event = AutorizationLogEvent.new
    respond_with(@autorization_log_event)
  end

  def edit
  end

  def create
    @autorization_log_event = AutorizationLogEvent.new(params[:autorization_log_event])
    @autorization_log_event.save
    respond_with(@autorization_log_event)
  end

  def update
    @autorization_log_event.update_attributes(params[:autorization_log_event])
    respond_with(@autorization_log_event)
  end

  def destroy
    @autorization_log_event.destroy
    respond_with(@autorization_log_event)
  end

  private
    def set_autorization_log_event
      @autorization_log_event = AutorizationLogEvent.find(params[:id])
    end
end
