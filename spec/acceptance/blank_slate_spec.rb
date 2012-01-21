require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Blank Slate", %q{
  In order to allow anyone to setup a BPS for any other person 
  As the owner
  I want the to be led through the setup process and have the site locked to me
} do

  scenario "Blank site allows first user to send setup email to owner" do
    visit "/"
    
    page.should have_content "Bitcoin Payment Service"
    page.should have_content "This site has not been locked to an owner"

    # No email
    click_button "Send setup instructions"
    page.within "#user_email_input" do
      page.should have_content "can't be blank"
    end
    
    # Not an email
    fill_in "Email", with: "not an email"
    click_button "Send setup instructions"
    page.within "#user_email_input" do
      page.should have_content "is not valid"
    end
    
    # Proper email 
    fill_in "Email", with: "owen@example.com"
    click_button "Send setup instructions"
    page.should have_content "Email with instructions sent"

    "owen@example.com".should receive_email(subject: "Setup instuction for Bitcoin Payment Service")
    email_to("owen@example.com").body.should include("setup your Bitcoin Payment Service")

    click_link_in_email "setup your BPS now", to: "owen@example.com"
    page.should have_content "Setup you Bitcoin Payment Service"

    # Clickling link a second time still works while site has not been setup
    click_link_in_email "setup your BPS now", to: "owen@example.com"
    page.should have_content "Setup you Bitcoin Payment Service"

    # Empty name
    click_button "Continue"
    page.within "#site_name_input" do
      page.should have_content "can't be blank"
    end
    
    # Filled out site name
    fill_in "Site name", with: "Owen's BPS"
    click_button "Continue"

    # Empty passwords
    click_button "Continue"
    page.within "#user_password_input" do
      page.should have_content "can't be blank"
    end

    # Passwords do not match
    fill_in "Password", with: "aaaaaaa"
    fill_in "Password confirmation", with: "bbbbbbbbbbb"
    click_button "Continue"
    page.within "#user_password_input" do
      page.should have_content "doesn't match"
    end

    # Passwords too short
    fill_in "Password", with: "1234567"
    fill_in "Password confirmation", with: "1234567"
    click_button "Continue"
    page.within "#user_password_input" do
      page.should have_content "too short"
    end

    # Proper password
    fill_in "Password", with: "something secret"
    fill_in "Password confirmation", with: "something secret"
    click_button "Continue"
    
    page.should have_content "As the owner, your password is really important"
    page.should have_content "If you lose it, you lose access to you bitcoins"
    page.should have_content "Type in your password again, to make sure you know it"
    
    fill_in "Password", with: "something secret"
    click_button "Verify"
    
    page.should have_content "The site is now locked to you"
    page.should have_content "Keep your password safe"
  end
  
end
