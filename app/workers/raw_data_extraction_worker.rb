class RawDataExtractionWorker
  include Sidekiq::Worker
  include DataExtractionsHelper

  sidekiq_options retry: false

  def perform(organization_id, item_title, user_id)

    #workbook = RubyXL::Workbook.new
    # timeago = 1.year

    @organization = Organization.where(id: organization_id).first
    user = User.find(user_id)
    @item_title = item_title

    # if params[:date_min].present? && params[:date_min].present?
    #                                        # .where(is_historized: (params[:is_historized] == "1"))
    #                                        # .where("created_at > ?", timeago.ago)
    @organization_projects = @organization.projects
                                          .where(is_model: false)
                                          .includes(:project_fields, :application, :project_area, :acquisition_category, :platform_category, :provider,
                                                    :estimation_status, :guw_model, :guw_attributes, :guw_coefficients,
                                                    :guw_types, :guw_unit_of_works, :module_projects,
                                                    :guw_unit_of_work_attributes, :guw_coefficient_element_unit_of_works)
    # else
    #   @organization_projects = @organization.projects
    #                                .where(is_model: false)
    #                                .includes(:project_fields, :application, :project_area, :acquisition_category, :platform_category, :provider,
    #                                          :estimation_status, :guw_model, :guw_attributes, :guw_coefficients,
    #                                          :guw_types, :guw_unit_of_works, :module_projects,
    #                                          :guw_unit_of_work_attributes, :guw_coefficient_element_unit_of_works)
    # end



    case @item_title
    when "raw_data_extraction_synthese"
      workbook = raw_data_extraction_synthese(@organization, @organization_projects)

    when "raw_data_extract_abaques_services_DE"
      workbook = raw_data_extract_abaques_services_DE(@organization, @organization_projects)

    when "raw_data_extract_services_ratio"
      workbook = raw_data_extract_services_ratio(@organization, @organization_projects)

    else
      workbook = raw_data_extraction_synthese(@organization, @organization_projects)
    end


    workbook.write("#{Rails.root}/public/#{@organization.name.gsub(" ", "_")}-#{user_id}-RAW_DATA.xlsx")

    # send_data(workbook.stream.string,
    #           filename: "#{@organization.name.gsub(" ", "_")}-#{user_id}-RAW_DATA.xlsx",
    #           type: "application/vnd.ms-excel")

    UserMailer.send_raw_data_extraction(user, @organization).deliver_now
  end

end