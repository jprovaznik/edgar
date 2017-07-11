FactoryGirl.define do
  factory :index, class: Edgar::Index do
    data = File.read('spec/support/index.idx')
    defaults = {}
    initialize_with { Edgar::Index.new(data, defaults.merge(attributes)) }
  end
end
