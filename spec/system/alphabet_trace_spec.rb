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

  # Roughly traces the "A" guide with three strokes (left leg, right leg,
  # crossbar) so scoring specs have something legitimately letter-shaped to
  # grade, rather than an arbitrary scribble.
  LETTER_A_STROKES = [
    [ [ 150, 60 ], [ 75, 320 ] ],
    [ [ 150, 60 ], [ 225, 320 ] ],
    [ [ 105, 220 ], [ 195, 220 ] ]
  ].freeze

  def trace_letter_a
    canvas = find(".trace-canvas").native
    LETTER_A_STROKES.each do |points|
      action = page.driver.browser.action.move_to(canvas, points[0][0] - 150, points[0][1] - 170).click_and_hold
      points.each_cons(2) { |(px, py), (x, y)| action = action.move_by(x - px, y - py) }
      action.release.perform
    end
  end

  def score_percentage
    find(".score-result").text[/(\d+)%/, 1].to_i
  end

  it "shows the reference letter, word/picture card, and a blank trace canvas" do
    visit "/a"

    expect(page).to have_css(".reference-pane svg")
    expect(page).to have_css(".trace-pane svg")
    expect(page).to have_css(".trace-canvas")
    expect(page).to have_content("A is for Apple")
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

  it "wraps from the first letter back to the last letter" do
    visit "/a"

    click_link "< Z"
    expect(page).to have_current_path("/z")
  end

  it "wraps from the last letter back to the first letter" do
    visit "/z"

    click_link "A >"
    expect(page).to have_current_path("/a")
  end

  it "shows an encouraging low score when checking an untouched canvas" do
    visit "/a"

    click_button "Check my tracing"
    expect(page).to have_content("0% - Keep practicing!")
  end

  it "shows a high score after tracing the letter reasonably well" do
    visit "/a"

    trace_letter_a
    click_button "Check my tracing"
    expect(score_percentage).to be >= 50
  end

  it "hides the score after Clear is pressed" do
    visit "/a"

    trace_letter_a
    click_button "Check my tracing"
    expect(page).to have_css(".score-result")

    click_button "Clear"
    expect(page).to have_no_css(".score-result")
  end

  it "scores more strictly with Tight Check than the regular check" do
    visit "/a"
    trace_letter_a

    click_button "Check my tracing"
    regular_score = score_percentage

    click_button "Tight Check"
    tight_score = score_percentage

    expect(tight_score).to be < regular_score
  end
end
