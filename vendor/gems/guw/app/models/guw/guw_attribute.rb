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

module Guw
  class GuwAttribute < ActiveRecord::Base
    belongs_to :guw_model
    has_many :guw_attribute_complexities, dependent: :destroy
    has_many :guw_unit_of_work_attributes, dependent: :destroy
    validates_presence_of :name

    attr_accessible :name, :description, :guw_model_id

    amoeba do
      enable

      exclude_association [:guw_unit_of_work_attributes]

      customize(lambda { |original_guw_attribute, new_guw_attribute|
        new_guw_attribute.copy_id = original_guw_attribute.id
      })
    end

    def to_s
      name
    end
  end
end




# organizations = Organization.all
# organizations.each do |o|
#   o.guw_models.each do |guw_model|
#     guw_model.guw_coefficients.each do |guw_coefficient|
#
#       guw_outputs = []
#       guw_types = []
#
#       if guw_coefficient.name == "Dégressivité MCO"
#
#         guw_output_names = ["Charges T (jh)", "Coût Services (€)"]
#         guw_outputs = Guw::GuwOutput.where(name: guw_output_names).all
#         guw_types = guw_model.guw_types.where("name LIKE ?", "%MCO%").all
#
#       elsif guw_coefficient.name == "Dégressivité Services"
#
#         guw_output_names = ["Charges T (jh)", "Coût Services (€)", "Charge Services (jh)"]
#         guw_outputs = Guw::GuwOutput.where(name: guw_output_names).all
#         guw_types = guw_model.guw_types.where("name LIKE ?", "%SRV%").all
#
#       elsif guw_coefficient.name == "Dégressivité Abaque"
#
#         guw_output_names = ["Charge RIS (jh)", "Charge RTU (jh)", "Assiette Test (jh)", "Charge RTU Avec Dégr.", "Charge RIS Avec Dégr."]
#         guw_outputs = Guw::GuwOutput.where(name: guw_output_names).all
#         guw_types = guw_model.guw_types.where("name LIKE ?", "%CF%").all
#
#       elsif guw_coefficient.name == "Dégressivité"
#
#         guw_output_names = ["Charge (jh)", "Coût (€)"]
#         guw_outputs = Guw::GuwOutput.where(name: guw_output_names).all
#         guw_types = guw_model.guw_types.where("name LIKE ?", "%CPT1%").all
#
#       end
#
#       guw_coefficient.guw_coefficient_elements.each do |guw_coefficient_element|
#         if guw_coefficient_element.name == 'A2'
#
#           guw_coefficient_element.default = true
#           guw_coefficient_element.save
#
#           guw_types.each do |guw_type|
#             guw_outputs.each do |guw_output|
#               Guw::GuwComplexityCoefficientElement.where(guw_complexity_id: guw_type.guw_complexities.first.id,
#                                                          guw_coefficient_element_id: guw_coefficient_element.id,
#                                                          guw_output_id: guw_output.id,
#                                                          guw_type_id: guw_type.id,
#                                                          value: 1).first_or_create
#             end
#           end
#
#         elsif guw_coefficient_element.name.in?(%w(A1 A3 A4 A5 A6 A7 A8))
#
#           guw_coefficient_element.default = false
#           guw_coefficient_element.save
#
#           guw_coefficient_element.guw_complexity_coefficient_elements.each do |cce|
#             unless cce.guw_output.nil?
#               begin
#                 if cce.guw_output.name.in?(guw_output_names)
#                   cce.value = nil
#                   cce.save
#                 end
#               rescue
#               end
#             end
#           end
#         end
#       end
#     end
#   end
# end