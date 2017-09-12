require 'rails_helper'

RSpec.describe "datasets/index", type: :view do
  before(:each) do
    assign(:datasets, [
      Dataset.create!(
        :type => "Type",
        :name => "Name",
        :description => "Description",
        :schema_json => "Schema Json",
        :attribution => "Attribution",
        :uri => "Uri"
      ),
      Dataset.create!(
        :type => "Type",
        :name => "Name",
        :description => "Description",
        :schema_json => "Schema Json",
        :attribution => "Attribution",
        :uri => "Uri"
      )
    ])
  end

  it "renders a list of datasets" do
    render
    assert_select "tr>td", :text => "Type".to_s, :count => 2
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Description".to_s, :count => 2
    assert_select "tr>td", :text => "Schema Json".to_s, :count => 2
    assert_select "tr>td", :text => "Attribution".to_s, :count => 2
    assert_select "tr>td", :text => "Uri".to_s, :count => 2
  end
end
