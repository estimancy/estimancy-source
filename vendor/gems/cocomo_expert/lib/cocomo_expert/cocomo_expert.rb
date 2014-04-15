require 'cocomo_expert/version'

module CocomoExpert

  #Definition of CocomoBasic
  class CocomoExpert

    include ApplicationHelper

    attr_accessor :coef_a, :coef_b, :coef_c, :coef_kls, :complexity, :effort

    #Constructor
    def initialize(elem)
      @coef_kls = elem['ksloc'].to_f
    end

    # Return effort
    def get_effort_man_month(*args)
      sf = Array.new
      Factor.where(factor_type: "early_design").all.each do |factor|
        ic = InputCocomo.where(factor_id: factor.id,
                               pbs_project_element_id: args[2],
                               module_project_id: args[1],
                               project_id: args[0]).first.coefficient
        sf << ic
      end


      pers = InputCocomo.where( factor_id: Factor.where(alias: "pers").first.id,
                                pbs_project_element_id: args[2],
                                module_project_id: args[1],
                                project_id: args[0]).first.coefficient

      prex = InputCocomo.where( factor_id: Factor.where(alias: "prex").first.id,
                                pbs_project_element_id: args[2],
                                module_project_id: args[1],
                                project_id: args[0]).first.coefficient

      a = 2.94
      #todo : missing rcpx, ruse, pdif, sced (commun avec avancé)
      em = pers + prex
      b = 0.91 + (1/100) * sf.sum
      pm = em * a * @coef_kls**b

      pm
    end

    #Return delay (in hour)
    def get_delay(*args)
      @effort = get_effort_man_month(args[0], args[1], args[2])

      sf = Array.new
      Factor.where(factor_type: "early_design").all.each do |factor|
        ic = InputCocomo.where(factor_id: factor.id,
                               pbs_project_element_id: args[2],
                               module_project_id: args[1],
                               project_id: args[0]).first.coefficient
        sf << ic
      end

      f = 0.28 + 0.2 * (1/100) * sf.sum
      @delay = 3.67 * (@effort ** f )
      @delay
    end

    #Return end date
    def get_end_date(*args)
      @end_date = (Time.now + (get_delay(args[0], args[1], args[2])).to_i.months)
      @end_date
    end

    #Return staffing
    def get_staffing(*args)
      @staffing = (get_effort_man_month(args[0], args[1], args[2]) / get_delay(args[0], args[1], args[2]))
      @staffing
    end

    def get_cost(*args)
      @cost = 0
      @cost
    end
  end

end
