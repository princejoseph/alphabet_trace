class AlphabetTraceApp < HyperComponent
  param :letter

  LETTERS = ("a".."z").to_a

  before_mount do
    @drawing = false
    @last_point = nil
    @canvas_node = nil
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
          CANVAS(width: 300, height: 340, class: "trace-canvas",
                 ref: ->(node) { @canvas_node = node })
            .on(:mouse_down) { |e| start_stroke(e) }
            .on(:mouse_move) { |e| continue_stroke(e) }
            .on(:mouse_up) { |e| end_stroke(e) }
            .on(:mouse_leave) { |e| end_stroke(e) }
            .on(:touch_start) { |e| start_stroke(e) }
            .on(:touch_move) { |e| continue_stroke(e) }
            .on(:touch_end) { |e| end_stroke(e) }
        end
      end

      DIV(class: "controls") do
        BUTTON(class: "btn-clear") { "Clear" }.on(:click) { clear_canvas }
      end

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

  def start_stroke(e)
    e.prevent_default
    @drawing = true
    @last_point = event_point(e)
  end

  def continue_stroke(e)
    return unless @drawing

    e.prevent_default
    point = event_point(e)
    draw_line(@last_point, point)
    @last_point = point
  end

  def end_stroke(_e)
    @drawing = false
    @last_point = nil
  end

  def event_point(e)
    node = @canvas_node
    raw_event = e.to_n
    %x{
      var rect = #{node}.getBoundingClientRect();
      var clientX, clientY;
      if (#{raw_event}.touches && #{raw_event}.touches.length > 0) {
        clientX = #{raw_event}.touches[0].clientX;
        clientY = #{raw_event}.touches[0].clientY;
      } else {
        clientX = #{raw_event}.clientX;
        clientY = #{raw_event}.clientY;
      }
      return [clientX - rect.left, clientY - rect.top];
    }
  end

  def draw_line(from, to)
    node = @canvas_node
    from_x = from[0]
    from_y = from[1]
    to_x = to[0]
    to_y = to[1]
    %x{
      var ctx = #{node}.getContext('2d');
      ctx.lineWidth = 14;
      ctx.lineCap = 'round';
      ctx.lineJoin = 'round';
      ctx.strokeStyle = '#e8601c';
      ctx.beginPath();
      ctx.moveTo(#{from_x}, #{from_y});
      ctx.lineTo(#{to_x}, #{to_y});
      ctx.stroke();
    }
  end

  def clear_canvas
    node = @canvas_node
    %x{
      var ctx = #{node}.getContext('2d');
      ctx.clearRect(0, 0, #{node}.width, #{node}.height);
    }
  end
end
