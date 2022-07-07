class AddIndexToDemands < ActiveRecord::Migration
  def change
    # add_index :criticality_severities, [:organization_id, :demand_type_id, :criticality_id, :agreement_id, :severity_id], name: "criticality_severities_index"
    # add_index :demands, :organization_id
    # add_index :demand_types, :organization_id
    # add_index :services, :organization_id
    # add_index :livrables, :organization_id
    #
    # add_index :projects, :demand_id
    #
    # add_index :agreement_demands, [:organization_id, :agreement_id, :demand_id, :demand_type_id], name: "agreement_demands_index"
    # add_index :status_histories, :demand
    #
    # add_index :service_demand_livrables, [:organization_id, :service_id, :demand_id], name: "service_demand_livrables_index"
  end
end