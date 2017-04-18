module Operation
  class OperationInput < ActiveRecord::Base
    attr_accessible :name, :description, :in_out, :is_modifiable, :operation_model_id, :standard_unit_coefficient, :standard_unit

    validates :name, :presence => true, :uniqueness => {:scope => [:operation_model_id], :case_sensitive => false, message: "Un attribut avec le même nom existe déjà dans ce modèle"}
    validates :description, :in_out, :standard_unit_coefficient, :standard_unit, presence: true

    belongs_to :operation_model
    has_many :pe_attributes, dependent: :destroy  #tester avec has_one pour voir le resultat

    def to_s
      self.name
    end

  end
end
