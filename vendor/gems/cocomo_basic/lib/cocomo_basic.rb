#########################################################################
#
# ProjEstimate, Open Source project estimation web application
# Copyright (c) 2012-2013 Spirula (http://www.spirula.fr)
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
########################################################################

module CocomoBasic

  #Definition of CocomoBasic
  class CocomoBasic

    attr_accessor :coef_a, :coef_b, :coef_c, :coef_kls, :complexity

    #Constructor
    def initialize(elem)
      elem[:ksloc].blank? ? @coef_kls = nil : @coef_kls = elem[:ksloc].to_f
      case elem[:complexity]
        when 'Organic'
          set_cocomo_organic
        when 'Semi-detached'
          set_cocomo_semidetached
        when 'Embedded'
          set_cocomo_embedded
        else
          nil
      end
    end

    #Setters
    def set_cocomo_organic
      @coef_a = 2.4
      @coef_b = 1.05
      @coef_c = 0.38
      @complexity = 'Organic'
    end

    def set_cocomo_semidetached
      @coef_a = 3
      @coef_b = 1.12
      @coef_c = 0.35
      @complexity = 'Semi-detached'
    end

    def set_cocomo_embedded
      @coef_a = 3.6
      @coef_b = 1.2
      @coef_c = 0.32
      @complexity = 'Embedded'
    end

    #Getters
    #Return effort (in man-hour)
    def get_effort_man_hour
      if @coef_kls && @complexity
        (152 * @coef_a*(@coef_kls**@coef_b)).to_f
      else
        nil
      end
    end

    #Return delay (in hour)
    def get_delay
      if @coef_kls && @complexity
        (152 * 2.5*((get_effort_man_hour/152)**@coef_c)).to_f
      else
        nil
      end
    end

    #Return end date
    def get_end_date
      if @coef_kls && @complexity
        Time.now + (get_delay/152).to_i.months
      else
        nil
      end
    end

    #Return staffing
    def get_staffing
      if @coef_kls && @complexity
        get_effort_man_hour / get_delay
      else
        nil
      end
    end

    def get_complexity
      if @complexity
        @complexity
      else
        nil
      end
    end
  end

end
