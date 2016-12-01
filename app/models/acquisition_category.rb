#encoding: utf-8
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

#Master Table
class AcquisitionCategory < ActiveRecord::Base
  attr_accessible :name, :description, :record_status_id, :custom_value, :change_comment, :organization_id

  # has_and_belongs_to_many :project_areas

  # validates_presence_of :description
  validates :name, :presence => true

  has_many :projects

  amoeba do
    enable
    exclude_association [:projects]
    customize(lambda { |original_acquisition_category, new_acquisition_category|
                new_acquisition_category.copy_id = original_acquisition_category.id
              })
  end

  #Search fields
  scoped_search :on => [:name, :description, :created_at, :updated_at]

  def to_s
    self.nil? ? '' : self.name
  end
end

# def test_safae
#
#   # Générer les clés
#   body = ''
#   (0..28000).step(200).each do |i|
#
#     url = "https://www.mulesoft.org/jira/sr/jira.issueviews:searchrequest-excel-current-fields/temp/SearchRequest.xls?tempMax=200&pager/start=#{i}"
#     easy = Curl::Easy.new(url)
#
#     easy.username = 'safae_laqrichi'
#     easy.password = 'Estimancy16'
#     easy.perform
#
#     body << easy.body_str
#   end
#   File.open("tmp_mule_keys", 'wb+') do |f|
#     f << body
#   end
#
#   #Supprimer à la main les entetes qui se répète dans Excel
#
#   # Traiter la description
#   doc = Roo::Spreadsheet.open('mule_keys.xlsx')
#   agent = Mechanize.new
#   csva = {}
#   30000.times do |i|
#     val = doc.sheet(0).row(i)[0]# clé
#     sp = doc.sheet(0).row(i)[1] # storypoint
#     desc = ""
#     summary = ""
#     begin
#       url = "https://jira.spring.io/browse/#{val}"
#       agent.get(url)
#
#       agent.page.search(".user-content-block p").each do |item|
#         desc << item.text
#       end
#
#       agent.page.search("#summary-val").each do |item|
#         summary << item.text.gsub("\n", "")
#       end
#     rescue
#     end
#
#     csva[val] = [summary, desc, sp]
#   end
#
#   #Creation du fichier CSV
#   CSV.open("xd_results.csv", "wb") do |csv|
#     csva.each do |row|
#       r = row.flatten
#
#       r0 = r[0]
#       r1 = r[1].gsub("\n"," ")
#       r2 = r[2].gsub("\n"," ")
#       r3 = r[3]
#
#       csv << [r0, r1 + ' ' + r2, r3]
#     end
#   end
# end
