require_relative './../../lib/bin_packing'
class ExportController < ApplicationController

  @@zoom = 0.7

  def createBins(algorithm)
    sheets = Sheet.all
    bins = []
    sheets.each do |sheet|
      bins << BinPacking::Bin.new(sheet.id, sheet.width, sheet.height, algorithm, sheet.isScrap)
    end
    bins
  end

  def createBoxes()
    ordersheets = Ordersheet.all
    boxes = []
    ordersheets.each do |ordersheet|
      for i in 1..ordersheet.amount
        boxes << BinPacking::Box.new(ordersheet.id, ordersheet.width, ordersheet.height)
      end
    end
    boxes
  end

  def calculateFreeSpaceForUsedBins
    @@used_bins.each do |usedBin|
      usedBin.calculateFreeSpaces
    end
  end

  def removeUsedBinsFromDataBase
    @@used_bins.each do |usedBin|
      p Sheet.delete(usedBin.id)
    end
  end

  def getUsedBins
    usedBins = []
    @bins.each do |bin|
      usedBins << bin if bin.boxes.size != 0
    end
    usedBins
  end

  def putFreeSpacesBackToDataBase
    @@used_bins.each do |usedBin|
      freeSpaces = usedBin.free_spaces
      freeSpaces.each do |freeSpace|
        sheet = Sheet.new(:width => freeSpace.width, :height => freeSpace.height, :isScrap => true)
        sheet.save
      end
    end
  end

  def getNewScrapsFromUsedSheets
    scraps = []
    @@used_bins.each do |usedBin|
      freeSpaces = usedBin.free_spaces
      freeSpaces.each do |freeSpace|
        scraps << freeSpace
      end
    end
    scraps
  end

  def getAlgorithm(algorithm_id)
    case algorithm_id
    when "1"
      return BinPacking::Heuristics::BestAreaFit.new, "Best area fit"
    when "2"
      return BinPacking::Heuristics::BestLongSideFit.new, "Best long side fit"
    when "3"
      return BinPacking::Heuristics::BestShortSideFit.new, "Best short side fit"
    when "4"
      return BinPacking::Heuristics::BottomLeft.new, "Bottom left"
    else
      return BinPacking::Heuristics::BestAreaFit.new, "Best area fit"
    end
  end

  def index
    algorithm, @algorithm_name = getAlgorithm(params[:selected_algorithm_id])
    @bins = createBins(algorithm)
    @boxes = createBoxes

    packer = BinPacking::Packer.new(@bins)
    @@packed_boxes = packer.pack(@boxes)
    @@unpacked_boxes = packer.unpacked_boxes
    @@used_bins = getUsedBins
    calculateFreeSpaceForUsedBins
    @@scraps = getNewScrapsFromUsedSheets
  end

  def claim
    removeUsedBinsFromDataBase
    putFreeSpacesBackToDataBase
    removeOrderSheetsFromDataBase
  end

  def removeOrderSheetsFromDataBase
    @@packed_boxes.each do |packed_box|
      order = Ordersheet.find(packed_box.id)
      order.amount = order.amount - 1

      if order.amount == 0
        order.delete
      else
        order.save
      end
    end
  end

  helper_method :zoom

  def zoom
    @@zoom
  end

  helper_method :packed_boxes

  def packed_boxes
    @@packed_boxes
  end

  helper_method :used_bins

  def used_bins
    @@used_bins
  end

  helper_method :scraps

  def scraps
    @@scraps
  end

  helper_method :unpacked_boxes

  def unpacked_boxes
    @@unpacked_boxes
  end

end
