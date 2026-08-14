class TraceCanvas < HyperComponent
  before_mount do
    @drawing = false
    @last_point = nil
    @canvas_node = nil
  end

  render do
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

  def clear_canvas
    node = @canvas_node
    %x{
      var ctx = #{node}.getContext('2d');
      ctx.clearRect(0, 0, #{node}.width, #{node}.height);
    }
  end

  private

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
      // The canvas's CSS display size can differ from its drawing-buffer
      // size (width=300/height=340 attrs) on narrow screens where it's
      // scaled down to fit -- map displayed-pixel coordinates back to
      // buffer coordinates or strokes land in the wrong place.
      var scaleX = #{node}.width / rect.width;
      var scaleY = #{node}.height / rect.height;
      var clientX, clientY;
      if (#{raw_event}.touches && #{raw_event}.touches.length > 0) {
        clientX = #{raw_event}.touches[0].clientX;
        clientY = #{raw_event}.touches[0].clientY;
      } else {
        clientX = #{raw_event}.clientX;
        clientY = #{raw_event}.clientY;
      }
      return [(clientX - rect.left) * scaleX, (clientY - rect.top) * scaleY];
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
end
