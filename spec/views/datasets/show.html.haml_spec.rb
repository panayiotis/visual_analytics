require 'rails_helper'

RSpec.describe "datasets/show", type: :view do
  before(:each) do
    @dataset = assign(:dataset, Dataset.create!(
      :type => "Type",
      :name => "Name",
      :description => "Description",
      :schema_json => "Schema Json",
      :attribution => "Attribution",
      :uri => "Uri"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Type/)
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Description/)
    expect(rendered).to match(/Schema Json/)
    expect(rendered).to match(/Attribution/)
    expect(rendered).to match(/Uri/)
  end
end
