Rails.application.routes.draw do

  mount BalancingModule::Engine => "/balancing_module"
end
