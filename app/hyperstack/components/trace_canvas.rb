class TraceCanvas < HyperComponent
  param :letter

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

  # Renders the target letter's outline onto an offscreen canvas (same font/
  # position as the visible dotted guide) and compares it against the ink on
  # the real canvas. A blurred copy of each becomes a "tolerance zone" so
  # kids aren't graded on pixel-perfect accuracy:
  #  - coverage: how much of the letter's outline got traced over
  #  - precision: how much of the drawn ink stayed close to the outline
  # `tolerance` is the blur radius in pixels -- smaller means stricter
  # grading. Returns a 0-100 score (average of the two), or 0 if nothing
  # was drawn.
  def check_tracing(tolerance: 14)
    node = @canvas_node
    target_letter = letter.upcase
    tol = tolerance
    %x{
      var canvasNode = #{node};
      var targetLetter = #{target_letter};
      var tolerancePx = #{tol};
      var w = canvasNode.width, h = canvasNode.height;

      function renderOutline(blurPx) {
        var c = document.createElement('canvas');
        c.width = w; c.height = h;
        var ctx = c.getContext('2d');
        if (blurPx) ctx.filter = 'blur(' + blurPx + 'px)';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'alphabetic';
        ctx.font = '700 280px "Baloo 2", sans-serif';
        ctx.lineWidth = 3;
        ctx.strokeStyle = '#000';
        ctx.strokeText(targetLetter, 150, 250);
        return ctx.getImageData(0, 0, w, h).data;
      }

      function renderInk(blurPx) {
        var c = document.createElement('canvas');
        c.width = w; c.height = h;
        var ctx = c.getContext('2d');
        if (blurPx) ctx.filter = 'blur(' + blurPx + 'px)';
        ctx.drawImage(canvasNode, 0, 0);
        return ctx.getImageData(0, 0, w, h).data;
      }

      var letterMask = renderOutline(0);
      var letterTolerance = renderOutline(tolerancePx);
      var inkMask = renderInk(0);
      var inkTolerance = renderInk(tolerancePx);

      var letterCount = 0, coveredCount = 0;
      var inkCount = 0, precisionCount = 0;

      for (var i = 3; i < letterMask.length; i += 4) {
        if (letterMask[i] > 10) {
          letterCount++;
          if (inkTolerance[i] > 10) coveredCount++;
        }
        if (inkMask[i] > 10) {
          inkCount++;
          if (letterTolerance[i] > 10) precisionCount++;
        }
      }

      if (inkCount === 0) return 0;

      var coverage = letterCount > 0 ? coveredCount / letterCount : 0;
      var precision = precisionCount / inkCount;
      return Math.round(((coverage + precision) / 2) * 100);
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
