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

module ModuleProjectsHelper

  # Compute the probable result for each node
  # results: estimation result for (low, most_likely, high)
  # estimation_value : the estimation_value object
  def probable_value(results, estimation_value)
    minimum = nil #0.0
    most_likely = nil #0.0
    maximum = nil #0.0
    attribute_alias = estimation_value.pe_attribute.alias.to_sym
    #puts "RESULT_FOR_PROBABLE = #{results}"
    min_estimation_value = results[:low]["#{estimation_value.pe_attribute.alias}_#{estimation_value.module_project_id.to_s}".to_sym] rescue nil
    most_likely_estimation_value = results[:most_likely]["#{estimation_value.pe_attribute.alias}_#{estimation_value.module_project_id.to_s}".to_sym] rescue nil
    high_estimation_value = results[:high]["#{estimation_value.pe_attribute.alias}_#{estimation_value.module_project_id.to_s}".to_sym] rescue nil

    # Get the current estimation Module
    estimation_pemodule = estimation_value.module_project.pemodule
    if estimation_pemodule.yes_for_output_with_ratio? || estimation_pemodule.yes_for_output_without_ratio? || estimation_pemodule.yes_for_input_output_with_ratio? || estimation_pemodule.yes_for_input_output_without_ratio?
      hash_data_probable = Hash.new

      if min_estimation_value.nil? || most_likely_estimation_value.nil? || high_estimation_value.nil?
        hash_data_probable = Hash.new
      else
        min_estimation_value.keys.each do |wbs_project_elt_id|
          minimum = min_estimation_value[wbs_project_elt_id]
          most_likely = most_likely_estimation_value[wbs_project_elt_id]
          maximum = high_estimation_value[wbs_project_elt_id]

          # Get the number of not null value
          hash_data_probable[wbs_project_elt_id] = compute_probable_value(minimum, most_likely, maximum, estimation_value)
        end
      end

      hash_data_probable

      # Probable is only calculated for PBS
    else
      probable_result = compute_probable_value(min_estimation_value, most_likely_estimation_value, high_estimation_value, estimation_value)
      data_probable = probable_result[:value]
    end
  end

  #Function that compute the probable value according to the number of nut null value
  def compute_probable_value_avec_zero(minimum, most_likely, maximum, estimation_value=nil)
    # Get the number of not null value
    input_data = {:min => minimum, :ml => most_likely, :max => maximum}
    not_integer_or_float = Array.new
    sum_of_not_null = 0.0
    computed_probable_value = 0.0

    # leaf element consistency will be compute at the same time
    consistency = false

    number_of_not_null = 0.0
    input_data.each do |key, value|
      ###if value.is_a?(Integer) || value.is_a?(Float) || value.is_a?(BigDecimal) || value.is_a?(Bignum)
      if value.is_a?(Integer) || value.is_a?(Float) || value.class.superclass == Integer || value.class.superclass == Numeric
        begin
          if key.to_s.eql?("ml")
            number_of_not_null = number_of_not_null+4
          else
            number_of_not_null = number_of_not_null+1
          end
        rescue
          not_integer_or_float << nil
        end
      else
        not_integer_or_float << "#{key.to_s}"
      end
    end

    # If there is no null value, probable value is calculated normally as follow
    if not_integer_or_float.empty?
      computed_probable_value = (minimum.to_f + 4*most_likely.to_f + maximum.to_f) / 6
      consistency = true
    else
      # One or more value is/are null
      input_data.each do |key, value|
        unless not_integer_or_float.include?(key.to_s)
          if key.to_s.eql?("ml")
            sum_of_not_null = sum_of_not_null.to_f + (4*value.to_f)
          else
            sum_of_not_null = sum_of_not_null.to_f + value.to_f
          end
        end
      end
      # Calculate the probable value according to the number of not null value (sum is divide by the number od not null values)
      if number_of_not_null.zero?
        computed_probable_value = 0.0
      else
        computed_probable_value = sum_of_not_null.to_f / number_of_not_null.to_f
      end

    end

    unless estimation_value.nil?
      #computed_probable_value according to the attribute type
      ###if estimation_value.pe_attribute.attr_type.eql?("integer") && !computed_probable_value.nan?
      ###if computed_probable_value.is_a?(Integer) || (computed_probable_value.is_a?(Float) && !computed_probable_value.nan?)
      unless computed_probable_value.is_a?(Float) && computed_probable_value.nan?
        computed_probable_value = computed_probable_value
      end
    end

    {:value => computed_probable_value, :is_consistent => consistency}
  end

  #Function that compute the probable value according to the number of nut null value
  def compute_probable_value(minimum, most_likely, maximum, estimation_value=nil)
    # Get the number of not null value
    input_data = {:min => minimum, :ml => most_likely, :max => maximum}
    not_integer_or_float = Array.new
    sum_of_not_null = nil#0.0
    computed_probable_value = nil #0.0

    # leaf element consistency will be compute at the same time
    consistency = true

    number_of_not_null = nil #0.0
    value_to_compute_for_probable = []
    input_data.each do |key, value|
      ###if value.is_a?(Integer) || value.is_a?(Float) || value.is_a?(BigDecimal) || value.is_a?(Bignum)
      if value.is_a?(Integer) || value.is_a?(Float) || value.class.superclass == Integer || value.class.superclass == Numeric
        begin
          if key.to_s.eql?("ml")
            unless value.nil?
              number_of_not_null = number_of_not_null.to_i+4
              value_to_compute_for_probable << 4*value.to_f
            end
          else
            unless value.nil?
              number_of_not_null = number_of_not_null.to_i+1
              value_to_compute_for_probable << value.to_f
            end
          end
        rescue
          not_integer_or_float << nil
        end
      else
        not_integer_or_float << "#{key.to_s}"
      end
    end

    # If there is no null value, probable value is calculated normally as follow
    if value_to_compute_for_probable.empty?
      computed_probable_value = nil
    else
      if value_to_compute_for_probable.length == 3
        computed_probable_value = value_to_compute_for_probable.sum / 6
      else
        # Calculate the probable value according to the number of not null value (sum is divide by the number od not null values)
      computed_probable_value = number_of_not_null.nil? ? nil : (value_to_compute_for_probable.sum / number_of_not_null)
      end
    end

    unless computed_probable_value.nil? || (computed_probable_value.is_a?(Float) && computed_probable_value.nan?)
      computed_probable_value = computed_probable_value
    end

    {:value => computed_probable_value, :is_consistent => consistency}
  end

end
