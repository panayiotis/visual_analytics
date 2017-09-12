require 'rails_helper'

RSpec.describe "datasets/edit", type: :view do
  before(:each) do
    @dataset = assign(:dataset, Dataset.create!(
      :type => "",
      :name => "MyString",
      :description => "MyString",
      :schema_json => "MyString",
      :attribution => "MyString",
      :uri => "MyString"
    ))
  end

  it "renders the edit dataset form" do
    render

    assert_select "form[action=?][method=?]", dataset_path(@dataset), "post" do

      assert_select "input#dataset_type[name=?]", "dataset[type]"

      assert_select "input#dataset_name[name=?]", "dataset[name]"

      assert_select "input#dataset_description[name=?]", "dataset[description]"

      assert_select "input#dataset_schema_json[name=?]", "dataset[schema_json]"

      assert_select "input#dataset_attribution[name=?]", "dataset[attribution]"

      assert_select "input#dataset_uri[name=?]", "dataset[uri]"
    end
  end
end
