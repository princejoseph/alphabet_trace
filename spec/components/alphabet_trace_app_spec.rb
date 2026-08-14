require "rails_helper"

# Unit-level spec: mounts AlphabetTraceApp on its own, independent of the
# real /:letter route/controller. This is the pattern to follow for any
# future component added to the page -- one `mount`, one spec file, no
# dependency on the rest of the app.
RSpec.describe "AlphabetTraceApp", js: true do
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

  it "renders the reference letter and a blank trace guide" do
    mount "AlphabetTraceApp", letter: "a"

    expect(page).to have_css(".reference-pane svg")
    expect(page).to have_css(".trace-pane svg")
    expect(pixel_count).to eq(0)
  end

  it "lets a user draw on the canvas and clear it" do
    mount "AlphabetTraceApp", letter: "a"

    drag_across_canvas
    expect(pixel_count).to be > 0

    click_button "Clear"
    expect(pixel_count).to eq(0)
  end

  it "links to the next and previous letter" do
    mount "AlphabetTraceApp", letter: "m"

    expect(find_link("N >")[:href]).to end_with("/n")
    expect(find_link("< L")[:href]).to end_with("/l")
  end

  it "wraps to the last letter when previous is clicked on the first letter" do
    mount "AlphabetTraceApp", letter: "a"

    expect(find_link("< Z")[:href]).to end_with("/z")
  end

  it "wraps to the first letter when next is clicked on the last letter" do
    mount "AlphabetTraceApp", letter: "z"

    expect(find_link("A >")[:href]).to end_with("/a")
  end
end
