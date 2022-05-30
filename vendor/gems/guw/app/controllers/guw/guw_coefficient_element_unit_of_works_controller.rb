class Guw::GuwCoefficientElementUnitOfWorksController < ApplicationController
  def destroy
    @guw_coefficient_element_unit_of_work = Guw::GuwCoefficientElementUnitOfWork.find(params[:id])
    @guw_coefficient_element_unit_of_work.delete
  end
end
