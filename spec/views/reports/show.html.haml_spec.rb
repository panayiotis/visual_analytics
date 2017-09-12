require 'rails_helper'

RSpec.describe "reports/show", type: :view do
  before(:each) do
    @report = assign(:report, Report.create!(
      :name => "Name",
      :short_name => "Short Name",
      :description => "Description",
      :attribution => "Attribution"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Short Name/)
    expect(rendered).to match(/Description/)
    expect(rendered).to match(/Attribution/)
  end
end
