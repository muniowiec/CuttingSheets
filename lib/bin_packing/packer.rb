module BinPacking
  class Packer

    attr_reader :unpacked_boxes

    def initialize(bins)
      @bins = bins
      @unpacked_boxes = []
    end

    def pack(boxes, options = {})
      packed_boxes = []
      boxes = boxes.reject(&:packed?)
      return packed_boxes if boxes.none?

      limit = options[:limit] || BinPacking::Score::MAX_INT
      board = BinPacking::ScoreBoard.new(@bins, boxes)
      while entry = board.best_fit
        entry.bin.insert!(entry.box)
        board.remove_box(entry.box)
        board.recalculate_bin(entry.bin)
        packed_boxes << entry.box
        break if packed_boxes.size >= limit
      end
      @unpacked_boxes = boxes - packed_boxes
      packed_boxes
    end

    def pack!(boxes)
      packed_boxes = pack(boxes)
      if packed_boxes.size != boxes.size
        raise ArgumentError, "#{boxes.size - packed_boxes.size} boxes not "\
                            "packed into #{@bins.size} bins!"
      end
    end
  end
end
