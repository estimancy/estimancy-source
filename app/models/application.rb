class Application < ActiveRecord::Base
  attr_accessible :name, :organization_id, :is_ignored, :forfait_mco, :month_number, :start_date, :end_date, :coefficient, :coefficient_label

  belongs_to :organization

  has_and_belongs_to_many :projects

  has_many :demands
  has_many :budget_types
  has_many :budgets

  validates :name, :presence => true , :uniqueness => { :scope => :organization_id, :case_sensitive => false }

  default_scope { order('name ASC') }

  # scope :active, where(is_ignored: [false, nil])
  # scope :ignored, where(is_ignored: true)

  scope :active, -> {
    where(:is_ignored => [false, nil])
  }

  scope :ignored, -> {
    where(:is_ignored => true)
  }


  amoeba do
    enable
    exclude_association [:projects, :demands, :budget_types, :budgets]
    customize(lambda { |original_application, new_application|
                new_application.copy_id = original_application.id
              })
  end


  def to_s
    self.nil? ? '' : self.name
  end
end
