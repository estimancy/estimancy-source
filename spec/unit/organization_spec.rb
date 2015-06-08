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

require "spec_helper"

describe Organization do
  before :each do
    #@organization = Organization.first
    @organization = FactoryGirl.create(:organization)
  end

  it "should be valid" do
    @organization.should be_valid
  end

  it "should not be valid without name" do
    @organization.name = ""
    @organization.should_not be_valid
  end

  it "should return :organization name" do
    @organization.to_s.should eql(@organization.name)
  end
end