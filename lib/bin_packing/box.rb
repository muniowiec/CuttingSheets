module BinPacking
  class Box
    attr_accessor :width, :height, :x, :y, :packed, :id
    def initialize(id, width, height)
      @id = id
      @width = width
      @height = height
      @x = 0
      @y = 0
      @packed = false
    end

    def area
      @area ||= @width * @height
    end

    def rotate
      @width, @height = [@height, @width]
    end

    def packed?
      @packed
    end

    def label
      "Id: #{@id} #{@width}x#{@height} [#{@x},#{@y}]"
    end
  end
end
