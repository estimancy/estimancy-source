require 'spec_helper'

describe WbsActivityRatio do

  before :each do
    @wbs_activity = FactoryGirl.create(:wbs_activity)
    @wbs_activity_ratio = FactoryGirl.create(:wbs_activity_ratio, :wbs_activity => @wbs_activity)
  end

  it "should be valid" do
    @wbs_activity_ratio.should be_valid
  end

  it "should not be valid without name" do
    @wbs_activity_ratio.name = ""
    @wbs_activity_ratio.should_not be_valid
  end

  it "should not be valid without uuid" do
    @wbs_activity_ratio.uuid = ""
    @wbs_activity_ratio.should_not be_valid
  end

  it "should not be valid without custom_value when record_status = Custom" do
    @custom_status = FactoryGirl.build(:custom_status)
    @wbs_activity_ratio.record_status = @custom_status
    @wbs_activity_ratio.custom_value = ""
    @wbs_activity_ratio.should_not be_valid
  end

  it "should not be valid, when name already exist in same wbs-activity" do
    wbs_activity_ratio_2 = @wbs_activity_ratio.dup
    wbs_activity_ratio_2.name = @wbs_activity_ratio.name
    wbs_activity_ratio_2.save
    wbs_activity_ratio_2.should_not be_valid
  end

  it "should be a One Activity-elements" do
    one_elt_reference_value = FactoryGirl.create(:reference_value, :one_activity_elements)
    one_elt_reference_value.value = "One Activity-element"
    @wbs_activity_ratio = FactoryGirl.create(:wbs_activity_ratio, :wbs_activity => @wbs_activity, :reference_value => one_elt_reference_value)
    @wbs_activity_ratio.is_One_Activity_Element?.should be_true
  end

  it "should be an All Activity-elements" do
    all_activity_elt_ref_value = FactoryGirl.create(:reference_value, :all_activity_elements)
    all_activity_elt_ref_value.value = "All Activity-elements"
    @wbs_activity_ratio = FactoryGirl.create(:wbs_activity_ratio, :wbs_activity => @wbs_activity, :reference_value => all_activity_elt_ref_value)
    @wbs_activity_ratio.is_All_Activity_Elements?.should be_true
  end

  #TODO : will be transfer in ModuleProject class
  #it "should be a Set Of Activity-elements" do
  #  set_of_reference_value = FactoryGirl.create(:reference_value, :a_set_of_activity_elements)
  #  set_of_reference_value.value = "A set of activity-elements"
  #  @wbs_activity_ratio = FactoryGirl.create(:wbs_activity_ratio, :wbs_activity => @wbs_activity, :reference_value => set_of_reference_value)
  #  @wbs_activity_ratio.is_A_Set_Of_Activity_Elements?.should be_true
  #end

  #Should be false
  it "It's a set of activity-elements" do
    set_of_reference_value = FactoryGirl.create(:reference_value, :a_set_of_activity_elements)
    set_of_reference_value.value = "A set of activity-elements"
    @wbs_activity_ratio = FactoryGirl.create(:wbs_activity_ratio, :wbs_activity => @wbs_activity, :reference_value => set_of_reference_value)
    @wbs_activity_ratio.is_One_Activity_Element?.should be_false
  end

  it "It's one of activity-element" do
    one_elt_reference_value = FactoryGirl.create(:reference_value, :one_activity_elements)
    one_elt_reference_value.value = "One Activity-element"
    @wbs_activity_ratio = FactoryGirl.create(:wbs_activity_ratio, :wbs_activity => @wbs_activity, :reference_value => one_elt_reference_value)
    @wbs_activity_ratio.is_All_Activity_Elements?.should be_false
  end

  #TODO : will be transfer in ModuleProject class
  #it "It's All of activity-elements" do
  #  all_activity_elt_ref_value = FactoryGirl.create(:reference_value, :all_activity_elements)
  #  all_activity_elt_ref_value.value = "All Activity-elements"
  #  @wbs_activity_ratio = FactoryGirl.create(:wbs_activity_ratio, :wbs_activity => @wbs_activity, :reference_value => all_activity_elt_ref_value)
  #  @wbs_activity_ratio.is_A_Set_Of_Activity_Elements?.should be_false
  #end


  #Rescue
  it "Rescue is_A_Set_Of_Activity_Elements " do
    @wbs_activity_ratio.is_A_Set_Of_Activity_Elements?.should be_false
  end

  it "Rescue is_All_Activity_Elements" do
    @wbs_activity_ratio.is_All_Activity_Elements?.should be_false
  end

  it "Rescue is_One_Activity_Element" do
    @wbs_activity_ratio.is_One_Activity_Element?.should be_false
  end

  describe "On master" do
    it " After Duplicate wbs activity ratio: record status should be proposed" do
      MASTER_DATA=true
      @wbs_activity_ratio2=@wbs_activity_ratio.amoeba_dup
      if defined?(MASTER_DATA) and MASTER_DATA and File.exists?("#{Rails.root}/config/initializers/master_data.rb")
        @wbs_activity_ratio2.record_status.name.should eql("Proposed")
      else
        @wbs_activity_ratio2.record_status.name.should eql("Local")
      end
    end
  end

  describe "On local" do
    it "After Duplicate wbs activity ratio: record status should be local" do
      MASTER_DATA=false
      @wbs_activity_ratio2=@wbs_activity_ratio.amoeba_dup
      if defined?(MASTER_DATA) and MASTER_DATA and File.exists?("#{Rails.root}/config/initializers/master_data.rb")
        @wbs_activity_ratio2.record_status.name.should eql("Proposed")
      else
        @wbs_activity_ratio2.record_status.name.should eql("Local")
      end
    end
  end

  describe "export/import" do
    before :each do
      @wbs_activity_ratio = FactoryGirl.create(:wbs_activity_ratio, :wbs_activity => @wbs_activity)
      @wbs_activity_element = FactoryGirl.create(:wbs_activity_element, :wbs_activity => @wbs_activity)
      @wbs_activity_ratio_element = FactoryGirl.create( :wbs_activity_ratio_element,:id=>258, :wbs_activity_ratio=> @wbs_activity_ratio, :wbs_activity_element => @wbs_activity_element)
      @wbs_activity_ratio_element = FactoryGirl.create( :wbs_activity_ratio_element,:id=>259, :wbs_activity_ratio=> @wbs_activity_ratio, :wbs_activity_element => @wbs_activity_element)
    end

    it "should export wbs activity ratio" do
      csv_string = CSV.generate(:col_sep => I18n.t(:general_csv_separator)) do |csv|
        csv << ["id", "Ratio Name", "Outline", "Element Name", "Element Description", "Ratio Value", "Reference"]
        @wbs_activity_ratio=WbsActivityRatio.find(@wbs_activity_ratio.id)
        @wbs_activity_ratio.wbs_activity_ratio_elements.each do |element|
          csv << [element.id, "#{@wbs_activity_ratio.name}", "#{element.wbs_activity_element.dotted_id}", "#{element.wbs_activity_element.name}", "#{element.wbs_activity_element.description}", element.ratio_value, element.simple_reference, element.multiple_references]
        end
      end
      csv_string.encode(I18n.t(:general_csv_encoding))
      WbsActivityRatio.export(@wbs_activity_ratio.id).should be_eql(csv_string)
    end

    it "should import wbs activity ratio without error" do
      expected_csv =  File.dirname(__FILE__) + '/../fixtures/test.csv'
      file=ActionDispatch::Http::UploadedFile.new({
                                                      :filename => 'test.csv',
                                                      :content_type => 'text/csv',
                                                      :tempfile => File.new(File.dirname(__FILE__) + '/../fixtures/test.csv')
                                                  })
      WbsActivityRatio::import(file,'',"UTF-8").should be_true
      # sometimes it is better to parse generated_csv (ie. when you testing other formats like json or xml
    end
  end

end
