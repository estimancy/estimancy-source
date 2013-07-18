require "spec_helper"

describe PeAttribute do

  before :each do
    @attribute = FactoryGirl.create(:ksloc_attribute)
    @custom_status = FactoryGirl.build(:custom_status)
  end

  it 'should return attribute_update_at date' do
    PeAttribute::attribute_updated_at.should be_an_instance_of Array
    PeAttribute::attribute_updated_at.last.to_date.should eq @attribute.updated_at.to_date
    PeAttribute::attribute_updated_at.should include(@attribute.updated_at.to_s)
  end


  it 'should be return attribute type=integer' do
    @attribute.attr_type = "integer"
    @attribute.attribute_type.should eql("numeric")
  end

  it 'should be return attribute type=float' do
    @attribute.attr_type = "float"
    @attribute.attribute_type.should eql("numeric")
  end

  it 'should be return attribute type=date' do
    @attribute.attr_type = "date"
    @attribute.attribute_type.should eql("date")
  end

  it 'should be return attribute type=text' do
    @attribute.attr_type = "text"
    @attribute.attribute_type.should eql("string")
  end

  it 'should be return attribute type=list' do
    @attribute.attr_type = "list"
    @attribute.attribute_type.should eql("string")
  end

  it 'should be return attribute type=array' do
    @attribute.attr_type = "array"
    @attribute.attribute_type.should eql("string")
  end

  it 'should be valid' do
    @attribute.should be_valid
  end

  it "should be not valid without name" do
    @attribute.name = ""
    @attribute.should_not be_valid
  end

  it "should be not valid without description" do
    @attribute.description = ""
    @attribute.should_not be_valid
  end

  it "should be not valid without alias" do
    @attribute.alias = ""
    @attribute.should_not be_valid
  end

  it "should not be valid without custom_value when record_status='Custom'" do
    @attribute.record_status = @custom_status
    @attribute.should_not be_valid
  end

  it "should be not valid without attribute type :attr_type" do
    @attribute.attr_type = nil
    @attribute.should_not be_valid
  end

  it 'should return a correct data type' do
    @attribute.data_type.should eql(@attribute.attr_type)
  end

  it 'should list and return an array of aggregation type' do
    PeAttribute::type_aggregation.should be_an_instance_of Array
    PeAttribute::type_aggregation.should eql([["Moyenne", "average" ] ,["Somme", "sum"], ["Maximum", "maxi" ]])
  end

  it 'should list and return an array of value options type' do
    PeAttribute::value_options.should be_an_instance_of Array
    PeAttribute::value_options.should eql([
         ["Greater than or equal to", ">=" ],
         ["Greater than", ">" ],
         ["Lower than or equal to", "<=" ],
         ["Lower than", "<" ],
         ["Equal to", "=="],
         ["Not equal to", "!="],
         ["Between", "between"]
        ])
  end

  it 'should list and return an array of type_values' do
    PeAttribute::type_values.should be_an_instance_of Array
    PeAttribute::type_values.should eql([["Integer", "integer" ] ,["Float", "float"], ["Date", "date" ], ["Text", "text" ], ["List", "list" ]])
  end

  it 'should list an array' do
    PeAttribute::attribute_list.should be_an_instance_of Array
  end

  specify "should return :name + ' - ' + :description.truncate(20)" do
    @attribute.to_s.should eql(@attribute.name + ' - ' + @attribute.description.truncate(20) )
  end

  it "should return an attribute list" do

  end
end
