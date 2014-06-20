#
FactoryGirl.define do

  # Organizations
  factory :organization do
    sequence(:name) {|n| "Organization_#{n}"}
    sequence(:description) {|n| "Organisation number #{n}"}
    number_hours_per_day 7
    number_hours_per_month 140
    cost_per_hour 10
    association :currency, :factory => :euro_curreny
  end

end