class RawDataExtractionWorker
  include Sidekiq::Worker
  include DataExtractionsHelper

  sidekiq_options retry: false

  def perform(organization_id, item_title, user_id, date_min=nil, date_max=nil)

    #workbook = RubyXL::Workbook.new
    # timeago = 1.year

    @organization = Organization.where(id: organization_id).first
    user = User.find(user_id)
    @item_title = item_title
    report_type = "Synthese"

    #.where(is_historized: (params[:is_historized] == "1"))
    # @organization_projects = @organization.projects
    #                                       .where(is_model: false, is_historized: [false, nil])
    #                                       .includes(:project_fields, :application, :project_area, :acquisition_category, :platform_category, :provider,
    #                                                 :estimation_status, :guw_model, :guw_attributes, :guw_coefficients,
    #                                                 :guw_types, :guw_unit_of_works, :module_projects,
    #                                                 :guw_unit_of_work_attributes, :guw_coefficient_element_unit_of_works)

    all_organization_projects = @organization.projects.where(is_model: [false, nil], is_historized: [false, nil])

    if !date_min.blank? || !date_max.blank?
      if !date_min.blank?
        all_organization_projects = all_organization_projects.where("created_at > ?", date_min.to_date.beginning_of_day)
      end

      if !date_min.blank?
        all_organization_projects = all_organization_projects.where("created_at < ?", date_max.to_date.end_of_day)
      end

    end

    @organization_projects = all_organization_projects.includes(:project_fields, :application, :project_area, :acquisition_category, :platform_category, :provider,
                                                                :estimation_status, :guw_model, :guw_attributes, :guw_coefficients,
                                                                :guw_types, :guw_unit_of_works, :module_projects,
                                                                :guw_unit_of_work_attributes, :guw_coefficient_element_unit_of_works)


    report_type = "Synthese"
    case @item_title
    when "raw_data_extraction_synthese"
      report_type = "Synthese"
      workbook = raw_data_extraction_synthese(@organization, @organization_projects)

    when "raw_data_extract_abaques_services_DE"
      report_type = "Abaques_services_DE"
      workbook = raw_data_extract_abaques_services_DE(@organization, @organization_projects)

    when "raw_data_extract_services_ratio"
      report_type = "Services_WBS_Ratio"
      workbook = raw_data_extract_services_ratio(@organization, @organization_projects)

    else
      workbook = raw_data_extraction_synthese(@organization, @organization_projects)
    end


    #workbook.write("#{Rails.root}/public/#{@organization.name.gsub(" ", "_")}-#{user_id}-RAW_DATA.xlsx")
    filename = "#{@organization.name.gsub(" ", "_")}-#{user_id}-#{Time.now.strftime("%d-%m-%Y_%H-%M-%S")}-RAW_DATA_#{report_type}.xlsx"
    workbook.write("#{Rails.root}/public/#{filename}")

    # send_data(workbook.stream.string,
    #           filename: "#{@organization.name.gsub(" ", "_")}-#{user_id}-RAW_DATA.xlsx",
    #           type: "application/vnd.ms-excel")

    UserMailer.send_raw_data_extraction(user, @organization, filename).deliver_now
  end

end