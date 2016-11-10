# encoding: UTF-8
#############################################################################
#
# Estimancy, Open Source project estimation web application
# Copyright (c) 2014 Estimancy (http://www.estimancy.com)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#############################################################################

require 'spec_helper'

describe Project do

  before :each do
    @project = FactoryGirl.create(:project)
    @user = FactoryGirl.create(:user)
    #@user = FactoryGirl.build(:user)
    #@user.skip_confirmation!
    #@user.save!

    @project_security = ProjectSecurity.new(:project_id => @project.id, :user_id => @user.id)
  end

  it 'should be a valid project' do
    @project.should be_valid
  end

  it 'should be a valid user (user1)' do
    @user.should be_valid
  end

  #validation
  it 'should not be valid without title' do
    @project.title=''
    @project.should_not be_valid
  end

  it 'should not be valid without alias' do
    @project.alias=''
    @project.should_not be_valid
  end

  it 'should not be valid without estimation status' do
    @project.estimation_status_id = nil
    @project.should_not be_valid
  end

  it 'should not be valid when title already exists' do
    p1 = @project.dup
    p1.title = @project.title
    p1.save
    p1.should_not be_valid
  end

  it 'should not be valid when alias already exists' do
    p1 = @project.dup
    p1.alias = @project.alias
    p1.save
    p1.should_not be_valid
  end

  it 'should be in preliminary state' do
    @project.state.should eql('preliminary')
    @project.should be_valid
  end

  it "should be present in user's project list" do
    #@project.users.count.should eql(1)
    #@project.should be_valid
    @user.projects = [@project]
    @user.projects.should include(@project)
  end

  it 'should return valid string' do
    @project.to_s.should eql("#{@project.title} - #{@project.version_number}")
  end


  #ASSM STATES

  it 'should have defined states in transition states' do
    #Project.aasm.states_for_select.size.should eql(6)
  end

  it 'should change project state when transition' do
    #lambda { @project.commit! }.should change(@project, :state).from('preliminary').to('in_progress')
    #lambda { @project.commit! }.should change(@project, :state).from('in_progress').to('in_review')
    #lambda { @project.commit! }.should change(@project, :state).from('in_review').to('released')
  end

  it 'should return all possible states' do
    #@project.states.should eql(Project.aasm.states_for_select)
  end


  #OTHERS TESTS

  it 'should return his root pbs_project_element' do
    #@project1.root_component.id.should eql(@project1.pe_wbs_project.pbs_project_elements.first.id)
  end

  it 'should return the good WBS attached to the project' do
    pe_wbs_project = FactoryGirl.create(:wbs_1, :project_id => @project.id)
    #pe_wbs_project.project.should eql(@project)
    @project.pe_wbs_projects.products_wbs.first.project_id.should eql(@project.id)
  end

  it 'should be the project root pbs_project_element' do
    @work_element_type = FactoryGirl.create(:work_element_type, :wet_folder)
    @organization_technology = FactoryGirl.create(:organization_technology)

    pe_wbs_project_1 = FactoryGirl.create(:wbs_1, :project_id => @project.id)

    pbs_project_element = FactoryGirl.create(:pbs_project_element, :pbs_trait_folder, :is_root => true, :pe_wbs_project => pe_wbs_project_1, :work_element_type => @work_element_type, :organization_technology => @organization_technology)
    #pbs_project_element.pe_wbs_project = pe_wbs_project_1

    #project.root_component.is_root?.should be_true
    @project.root_component.should eq(pbs_project_element)
  end


  it 'should return a good project attribute value' do
     #TODO
  end

  it 'should execute correctly a estimation plan' do
     #
  end

  it 'should be a folder component' do
    pe_wbs_project = FactoryGirl.create(:wbs_1, :project_id => @project.id)
    #project.pe_wbs_project.pbs_project_elements << FactoryGirl.create(:pbs_project_element_folder)
    #project.pe_wbs_project.pbs_project_elements << FactoryGirl.create(:pbs_project_element_link)

    @project.pe_wbs_projects.products_wbs.first.pbs_project_elements.each do |pc|
      pc.work_element_type.name.should eql('Folder')
    end
  end

  it 'should return table search' do
    Project::table_search('').should be_kind_of(ActiveRecord::Relation)
    Project::table_search('').should be_an_instance_of(ActiveRecord::Relation)
  end

  it 'should return encoding' do
    Project::encoding.should eql(['Big5', 'CP874', 'CP932', 'CP949', 'gb18030', 'ISO-8859-1', 'ISO-8859-13', 'ISO-8859-15', 'ISO-8859-2', 'ISO-8859-8', 'ISO-8859-9', 'UTF-8', 'Windows-874'])
    Project::encoding.should be_an_instance_of(Array)
  end

  it ' should duplicate project' do
    @project4 = @project.amoeba_dup
  end

  after :each do
    #clean up
  end

end