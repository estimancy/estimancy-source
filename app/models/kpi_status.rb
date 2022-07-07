class KpiStatus < ActiveRecord::Base
  attr_accessible :kpi_id, :estimation_status_id

  belongs_to :kpi
  belongs_to :estimation_status

  def to_s
    self.estimation_status.name rescue ""
  end

end

