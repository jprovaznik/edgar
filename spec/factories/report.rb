FactoryGirl.define do
  factory :report, class: Edgar::Report do
    defaults = {}
    initialize_with { Edgar::Report.new(defaults.merge(attributes)) }
  end
end
