require "rails_helper"

RSpec.describe "LetterPicture", js: true do
  it "shows the word and emoji for a letter" do
    mount "LetterPicture", letter: "a"

    expect(page).to have_css(".letter-picture-emoji", text: "🍎")
    expect(page).to have_content("A is for Apple")
  end

  it "shows a middle letter's word and emoji" do
    mount "LetterPicture", letter: "m"

    expect(page).to have_css(".letter-picture-emoji", text: "🌙")
    expect(page).to have_content("M is for Moon")
  end

  it "shows the last letter's word and emoji" do
    mount "LetterPicture", letter: "z"

    expect(page).to have_css(".letter-picture-emoji", text: "🦓")
    expect(page).to have_content("Z is for Zebra")
  end
end
