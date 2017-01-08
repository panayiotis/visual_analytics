require 'rails_helper'

feature 'landing page' do
    scenario 'hello world message' do
      #Use capybara to auto complete forms and navigate
      visit('/')
      expect(page).to have_content("European Big Data Hackathon")
      expect(page).to have_content("More Info")
    end
end
