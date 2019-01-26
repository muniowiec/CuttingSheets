module BinPacking
  class Bin
    attr_reader :width, :height, :boxes, :heuristic, :id, :free_rectangles, :free_spaces, :is_scrap

    def initialize(id, width, height, heuristic = nil, is_scrap = false)
      @id = id
      @width = width
      @height = height
      @is_scrap = is_scrap

      @boxes = []
      box = BinPacking::FreeSpaceBox.new(width, height)
      @free_rectangles = [box]
      @free_spaces = []

      @heuristic = heuristic || BinPacking::Heuristics::BestAreaFit.new
    end

    def getFreeRectangles
      @free_rectangles.sort_by {|free| -free.area}
    end

    def isGoodForPush(freespace)
      (freespace.width > 30) && (freespace.height > 30) && (freespace.area > 2500)
    end

    def calculateFreeSpaces
      return [] if @free_rectangles.size == 0
      @free_rectangles = @free_rectangles.sort_by {|free| -free.area}
      return unless isGoodForPush(@free_rectangles[0])
      @free_spaces = [@free_rectangles[0]]
      @free_rectangles.delete_at(0)
      @free_rectangles.each do |freeRectangle|
        isPushed = false
        @free_spaces.each do |freeSpace|
          left = [freeRectangle.x, freeSpace.x].max
          right = [freeRectangle.x + freeRectangle.width, freeSpace.x + freeSpace.width].min
          bottom = [freeRectangle.y + freeRectangle.height, freeSpace.y + freeSpace.height].min
          top = [freeRectangle.y, freeSpace.y].max
          if (left < right) && (bottom > top)
            deltaX = right - left
            deltaY = bottom - top
            if freeRectangle.height == deltaY
              if !(left == freeRectangle.x || right == freeRectangle.x + freeRectangle.width)
                lefter = BinPacking::FreeSpaceBox.new(left - freeRectangle.x, freeRectangle.height)
                lefter.x = freeRectangle.x
                lefter.y = freeRectangle.y
                if isGoodForPush(lefter)
                  @free_spaces << lefter
                  isPushed = true
                end
                righter = BinPacking::FreeSpaceBox.new(freeRectangle.width - (right - freeRectangle.x), freeRectangle.height)
                righter.x = right
                righter.y = freeRectangle.y
                if isGoodForPush(righter)
                  @free_spaces << righter
                  isPushed = true
                end
              else
                freeRectangle.width -= deltaX
              end
            else
              if !(top == freeRectangle.y || bottom == freeRectangle.y + freeRectangle.height)
                upper = BinPacking::FreeSpaceBox.new(freeRectangle.width, top - freeRectangle.y)
                upper.x = freeRectangle.x
                upper.y = freeRectangle.y
                if isGoodForPush(upper)
                  @free_spaces << upper
                  isPushed = true
                end
                lower = BinPacking::FreeSpaceBox.new(freeRectangle.width, freeRectangle.height - (bottom - freeRectangle.y))
                lower.x = freeRectangle.x
                lower.y = bottom
                if isGoodForPush(lower)
                  @free_spaces << lower
                  isPushed = true
                end
              else
                freeRectangle.height -= deltaY
              end
             end
            if (freeRectangle.y == top) && (freeRectangle.x == left)
              if (freeRectangle.y + freeRectangle.height) == bottom
                freeRectangle.x += deltaX
              end
              if (freeRectangle.x + freeRectangle.width) == right
                freeRectangle.y += deltaY
              end
            end
          end
        end
        @free_spaces.push(freeRectangle) if !isPushed && isGoodForPush(freeRectangle)
      end
    end

    def efficiency
      boxes_area = 0
      @boxes.each {|box| boxes_area += box.area}
      boxes_area * 100 / area
    end

    def insert(box)
      return false if box.packed?

      @heuristic.find_position_for_new_node!(box, @free_rectangles)
      return false unless box.packed?

      num_rectangles_to_process = @free_rectangles.size
      i = 0
      while i < num_rectangles_to_process
        if split_free_node(@free_rectangles[i], box)
          @free_rectangles.delete_at(i)
          num_rectangles_to_process -= 1
        else
          i += 1
        end
      end

      prune_free_list

      @boxes << box
      true
    end

    def insert!(box)
      unless insert(box)
        raise ArgumentError, "Could not insert box #{box.inspect} "\
                             "into bin #{inspect}."
      end
      self
    end

    def score_for(box)
      @heuristic.find_position_for_new_node!(box.clone, @free_rectangles)
    end

    def is_larger_than?(box)
      (@width >= box.width && @height >= box.height) ||
          (@height >= box.width && @width >= box.height)
    end

    def label
      "Id: #{@id} #{@width}x#{@height} #{efficiency}%"
    end

    private

    def area
      @width * @height
    end

    def place_rect(node)
      num_rectangles_to_process = @free_rectangles.size
      i = 0
      while i < num_rectangles_to_process
        if split_free_node(@free_rectangles[i], node)
          @free_rectangles.delete_at(i)
          num_rectangles_to_process -= 1
        else
          i += 1
        end
      end

      prune_free_list

      @boxes << node
    end

    def split_free_node(free_node, used_node)
      # Test with SAT if the rectangles even intersect.
      if used_node.x >= free_node.x + free_node.width ||
          used_node.x + used_node.width <= free_node.x ||
          used_node.y >= free_node.y + free_node.height ||
          used_node.y + used_node.height <= free_node.y
        return false
      end

      try_split_free_node_vertically(free_node, used_node)

      try_split_free_node_horizontally(free_node, used_node)

      true
    end

    def try_split_free_node_vertically(free_node, used_node)
      if used_node.x < free_node.x + free_node.width && used_node.x + used_node.width > free_node.x
        try_leave_free_space_at_top(free_node, used_node)
        try_leave_free_space_at_bottom(free_node, used_node)
      end
    end

    def try_leave_free_space_at_top(free_node, used_node)
      if used_node.y > free_node.y && used_node.y < free_node.y + free_node.height
        new_node = free_node.clone
        new_node.height = used_node.y - new_node.y
        @free_rectangles << new_node
      end
    end

    def try_leave_free_space_at_bottom(free_node, used_node)
      if used_node.y + used_node.height < free_node.y + free_node.height
        new_node = free_node.clone
        new_node.y = used_node.y + used_node.height
        new_node.height = free_node.y + free_node.height - (used_node.y + used_node.height)
        @free_rectangles << new_node
      end
    end

    def try_split_free_node_horizontally(free_node, used_node)
      if used_node.y < free_node.y + free_node.height && used_node.y + used_node.height > free_node.y
        try_leave_free_space_on_left(free_node, used_node)
        try_leave_free_space_on_right(free_node, used_node)
      end
    end

    def try_leave_free_space_on_left(free_node, used_node)
      if used_node.x > free_node.x && used_node.x < free_node.x + free_node.width
        new_node = free_node.clone
        new_node.width = used_node.x - new_node.x
        @free_rectangles << new_node
      end
    end

    def try_leave_free_space_on_right(free_node, used_node)
      if used_node.x + used_node.width < free_node.x + free_node.width
        new_node = free_node.clone
        new_node.x = used_node.x + used_node.width
        new_node.width = free_node.x + free_node.width - (used_node.x + used_node.width)
        @free_rectangles << new_node
      end
    end

    # Goes through the free rectangle list and removes any redundant entries.
    def prune_free_list
      i = 0
      while i < @free_rectangles.size
        j = i + 1
        while j < @free_rectangles.size
          if is_contained_in?(@free_rectangles[i], @free_rectangles[j])
            @free_rectangles.delete_at(i)
            i -= 1
            break
          end
          if is_contained_in?(@free_rectangles[j], @free_rectangles[i])
            @free_rectangles.delete_at(j)
          else
            j += 1
          end
        end
        i += 1
      end
    end

    def is_contained_in?(rect_a, rect_b)
      return rect_a.x >= rect_b.x && rect_a.y >= rect_b.y &&
          rect_a.x + rect_a.width <= rect_b.x + rect_b.width &&
          rect_a.y + rect_a.height <= rect_b.y + rect_b.height
    end
  end
end
