class IwidgetsController < ApplicationController
  before_action :set_iwidget, only: [:show, :edit, :update, :destroy]

  # GET /iwidgets
  # GET /iwidgets.json
  def index
    @iwidgets = Iwidget.all
  end

  # GET /iwidgets/1
  # GET /iwidgets/1.json
  def show
    @indicator_dashboard_id = @iwidget.indicator_dashboard_id
    
  end

  # GET /iwidgets/new
  def new
    @iwidget = Iwidget.new
    @indicator_dashboard_id = params[:indicator_dashboard_id]
    @min_value = @iwidget.min_value
    @max_value = @iwidget.max_value
    @position_x = 1; @position_y = 1
  end

  # GET /iwidgets/1/edit
  def edit
    @indicator_dashboard_id = @iwidget.indicator_dashboard_id
    @min_value = @iwidget.min_value
    @max_value = @iwidget.max_value
    @position_x = (@iwidget.position_x.nil? || @iwidget.position_x.downcase.eql?("nan")) ? 1 : @iwidget.position_x
    @position_y = (@iwidget.position_y.nil? || @iwidget.position_y.downcase.eql?("nan")) ? 1 : @iwidget.position_y
  end

  # POST /iwidgets
  # POST /iwidgets.json
  def create
    @iwidget = Iwidget.new(iwidget_params)
    @indicator_dashboard = @iwidget.indicator_dashboard

    # Add the position_x and position_y to params
    position_x = 0
    position_y = 0

    # Get the max (width, height) of the view's widgets : then add the widget in last positions
    unless @indicator_dashboard.nil? || @indicator_dashboard.iwidgets.empty?
      current_view_widgets = @indicator_dashboard.iwidgets
      y_positions = @indicator_dashboard.iwidgets.map(&:position_y).map(&:to_i)
      y_max = y_positions.max
      widgets_on_ymax = current_view_widgets.where(position_y: y_max.to_s)
      x_positions = widgets_on_ymax.map(&:position_x).map(&:to_i)
      x_max = x_positions.max
      view_widget_max_position = widgets_on_ymax.where(position_x: x_max.to_s).first

      #position_x = view_widget_max_position.position_x.to_i+view_widget_max_position.width.to_i+1
      position_y = view_widget_max_position.position_y.to_i+view_widget_max_position.height.to_i+1  #y_max
    end

    #new widget with the default positions
    @iwidget = Iwidget.new(iwidget_params.merge(:position_x => position_x,
                                                :position_y => position_y,
                                                :width => 3,
                                                :height => 1))
    respond_to do |format|
      if @iwidget.save
        partial_name = "tabs_dashboard_#{@indicator_dashboard.name}"

        format.js { render(:js => "window.location.replace('#{organization_global_kpis_path(@current_organization, is_a_dashboard: true, partial_name: partial_name, item_title: @indicator_dashboard.name)}');")}
        format.js { render(:js => "window.location.replace('#{dashboard_path(@module_project.project)}');")}
        format.html { redirect_to @iwidget, notice: 'Iwidget was successfully created.' }
        format.json { render action: 'show', status: :created, location: @iwidget }
      else
        format.html { render action: 'new' }
        format.json { render json: @iwidget.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /iwidgets/1
  # PATCH/PUT /iwidgets/1.json
  def update
    @indicator_dashboard_id = @iwidget.indicator_dashboard_id
    @indicator_dashboard = @iwidget.indicator_dashboard
    partial_name = "tabs_dashboard_#{@indicator_dashboard.name}"

    respond_to do |format|
      if @iwidget.update(iwidget_params)
        #flash[:notice] = 'Iwidget was successfully updated.'
        #format.js { render :js => "window.location.replace('#{organization_global_kpis_path(@current_organization, is_a_dashboard: true, partial_name: partial_name, item_title: @indicator_dashboard.name, anchor: 'tabs-indicator_dashboards')}');"}
        format.js { render :js => "window.location.replace('#{organization_global_kpis_path(@current_organization, is_a_dashboard: true, partial_name: partial_name, item_title: @indicator_dashboard.name)}');"}
        format.html { redirect_to @iwidget }
        format.json { head :no_content }
      else
        format.js { render action: :edit }
        format.html { render action: 'edit' }
        format.json { render json: @iwidget.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /iwidgets/1
  # DELETE /iwidgets/1.json
  def destroy
    @indicator_dashboard = @iwidget.indicator_dashboard

    @iwidget.destroy
    respond_to do |format|
      format.html { redirect_to organization_global_kpis_path(@current_organization, is_a_dashboard: true, partial_name: "tabs_dashboard_#{@indicator_dashboard.name}", item_title: @indicator_dashboard.name, anchor: 'tabs-indicator_dashboards') }
      format.json { head :no_content }
    end
  end

  #update the iwidget position (x,y)
  def update_iwidget_positions

    dragged_widget_id = params[:iwidget_id]
    iwidget_items = params[:iwidget_items]

    unless iwidget_items.empty?
      iwidget_items.each_with_index do |item, index|

        iwidget_item = item[1]
        iwidget_id = iwidget_item[:iwidget_id]

        unless iwidget_id.blank?
          iwidget = Iwidget.find(iwidget_id)
          if iwidget
            # Update the View Widget positions (left = position_x, top = position_y)
            if iwidget.id == dragged_widget_id.to_i

              iwidget.update_attributes(position_x: params[:x_position],
                                            position_y: params[:y_position],
                                            width: params[:item_width],
                                            height: params[:item_height])
            else
              iwidget.update_attributes(position_x: iwidget_item[:x_position],
                                            position_y: iwidget_item[:y_position],
                                            width: iwidget_item[:item_width],
                                            height: iwidget_item[:item_height])
            end
          end
        end
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_iwidget
      @iwidget = Iwidget.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def iwidget_params
      params.require(:iwidget).permit(:indicator_dashboard_id, :name, :description,
                                      :serie_a_kpi_id, :serie_a_output_type,
                                      :serie_b_kpi_id, :serie_b_output_type,
                                      :serie_c_kpi_id, :serie_c_output_type,
                                      :serie_d_kpi_id, :serie_d_output_type,
                                      :icon_class, :color, :position_x, :position_y, :width, :height,
                                      :is_label_widget, :comment, :is_calculation_widget, :equation,
                                      :min_value, :max_value, :validation_text, :signalize, :x_axis_label, :y_axis_label, :equation_output_type)
    end
end
