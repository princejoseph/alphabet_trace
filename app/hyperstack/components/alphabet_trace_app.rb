class AlphabetTraceApp < HyperComponent
  param :letter

  LETTERS = ("a".."z").to_a

  before_mount do
    @score = nil
    @revealed = false

    nav = Native(`navigator`)
    nav.serviceWorker.register("/service-worker.js") if nav[:serviceWorker]
  end

  render do
    index = LETTERS.index(letter) || 0
    prev_letter = LETTERS[index - 1]
    next_letter = LETTERS[index + 1] || LETTERS[0]

    DIV(class: "app") do
      DIV(class: "letter-heading") { "#{letter.upcase}#{letter}" }

      LetterPicture(letter: letter)

      DIV(class: "panes") do
        DIV(class: "pane reference-pane") do
          letter_svg(fill: "#3b6fd6")
        end

        DIV(class: "pane trace-pane") do
          letter_svg(fill: "none", stroke: "#c7c7cf", stroke_width: 3,
                     stroke_dasharray: "1 15", stroke_linecap: "round")
          TraceCanvas(letter: letter, ref: ->(instance) { @trace_canvas = instance })
          DIV(class: "reveal-overlay#{' revealed' if @revealed}") { letter_svg(fill: "#3b6fd6") }
        end
      end

      DIV(class: "controls") do
        BUTTON(class: "btn-clear") { "Clear" }.on(:click) do
          mutate @score = nil, @revealed = false
          @trace_canvas.clear_canvas
        end

        BUTTON(class: "btn-check") { "Check my tracing" }.on(:click) { run_check }
        BUTTON(class: "btn-check btn-check-tight") { "Tight Check" }.on(:click) { run_check(tolerance: 4) }
      end

      DIV(class: "score-result") { score_message(@score) } if @score

      DIV(class: "nav-row") do
        A(href: "/#{prev_letter}", class: "btn-nav") { "< #{prev_letter.upcase}" }
        A(href: "/#{next_letter}", class: "btn-nav") { "#{next_letter.upcase} >" }
      end
    end
  end

  def letter_svg(fill:, stroke: nil, stroke_width: nil, stroke_dasharray: nil, stroke_linecap: nil)
    SVG(viewBox: "0 0 300 340", class: "letter-svg") do
      TEXT(x: 150, y: 250, text_anchor: "middle",
           font_size: 280, font_weight: 700, font_family: "'Baloo 2', sans-serif",
           fill: fill, stroke: stroke, stroke_width: stroke_width,
           stroke_dasharray: stroke_dasharray, stroke_linecap: stroke_linecap) { letter.upcase }
    end
  end

  def run_check(tolerance: 14)
    mutate @score = @trace_canvas.check_tracing(tolerance: tolerance), @revealed = true
    after(2.2) { mutate @revealed = false }
  end

  def score_message(score)
    emoji, phrase =
      if score >= 80
        [ "🌟", "Amazing tracing!" ]
      elsif score >= 50
        [ "👍", "Nice try!" ]
      else
        [ "💪", "Keep practicing!" ]
      end
    "#{emoji} #{score}% - #{phrase}"
  end
end
