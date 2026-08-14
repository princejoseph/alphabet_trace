require "rails_helper"

RSpec.describe "Tracing a letter", js: true do
  def pixel_count
    page.evaluate_script(<<~JS)
      (function() {
        var c = document.querySelector('.trace-canvas');
        var data = c.getContext('2d').getImageData(0, 0, c.width, c.height).data;
        var count = 0;
        for (var i = 3; i < data.length; i += 4) { if (data[i] > 0) count++; }
        return count;
      })()
    JS
  end

  def drag_across_canvas
    canvas = find(".trace-canvas")
    page.driver.browser.action
      .move_to(canvas.native, -60, -60)
      .click_and_hold
      .move_by(20, 40)
      .move_by(20, 40)
      .release
      .perform
  end

  it "shows the reference letter and a blank trace canvas" do
    visit "/a"

    expect(page).to have_css(".reference-pane svg")
    expect(page).to have_css(".trace-pane svg")
    expect(page).to have_css(".trace-canvas")
    expect(pixel_count).to eq(0)
  end

  it "lets a user draw on the canvas and clear it" do
    visit "/a"

    drag_across_canvas
    expect(pixel_count).to be > 0

    click_button "Clear"
    expect(pixel_count).to eq(0)
  end

  it "navigates to the next and previous letter" do
    visit "/a"

    click_link "B >"
    expect(page).to have_current_path("/b")

    click_link "< A"
    expect(page).to have_current_path("/a")
  end

  it "disables the previous link on the first letter" do
    visit "/a"

    expect(page).to have_no_link("< ")
    expect(page).to have_link("B >")
  end

  it "disables the next link on the last letter" do
    visit "/z"

    expect(page).to have_link("< Y")
    expect(page).to have_no_link(" >")
  end
end
