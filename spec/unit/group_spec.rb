require "spec_helper"

describe Group do
  before :each do
    @group = FactoryGirl.create(:group)
    @project = FactoryGirl.create(:project)
  end

  it 'should be valid' do
    @group.should be_valid
  end

  it 'should return an array' do
    #@group.project_securities_for_select(@project.id).should be_a_kind_of(Array)
  end

  it "should not be valid without name" do
    @group.name = ""
    @group.should_not be_valid
  end

  it "should not be valid  when group name already exists" do
    group2 = @group.dup
    group2.save
    group2.should_not be_valid
  end

  it "should be not valid" do
    @group.name=1
    @group.to_s.should_not be_instance_of(String)
  end

  it "should be valid" do
    @group.to_s.should be_an_instance_of(String)
  end

  it "should return group name" do
    @group.to_s.should eql(@group.name)
  end

end