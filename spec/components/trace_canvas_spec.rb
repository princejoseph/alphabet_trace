require "rails_helper"

# Unit-level spec: mounts TraceCanvas on its own. Clearing via the "Clear"
# button is an integration concern between this component and its parent
# (AlphabetTraceApp calls @trace_canvas.clear_canvas through a ref) and is
# covered there instead -- this file only covers TraceCanvas's own behavior.
RSpec.describe "TraceCanvas", js: true do
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

  it "renders a blank canvas" do
    mount "TraceCanvas", letter: "a"

    expect(page).to have_css(".trace-canvas")
    expect(pixel_count).to eq(0)
  end

  it "draws a stroke when dragged across" do
    mount "TraceCanvas", letter: "a"

    drag_across_canvas
    expect(pixel_count).to be > 0
  end
end
