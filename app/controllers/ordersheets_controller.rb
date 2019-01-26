class OrdersheetsController < ApplicationController
  before_action :set_ordersheet, only: [:show, :edit, :update, :destroy]

  # GET /ordersheets
  # GET /ordersheets.json
  def index
    @ordersheets = Ordersheet.all
  end

  # GET /ordersheets/1
  # GET /ordersheets/1.json
  def show
  end

  # GET /ordersheets/new
  def new
    @ordersheet = Ordersheet.new
  end

  # GET /ordersheets/1/edit
  def edit
  end

  # POST /ordersheets
  # POST /ordersheets.json
  def create
    @ordersheet = Ordersheet.new(ordersheet_params)

    respond_to do |format|
      if @ordersheet.save
        format.html { redirect_to @ordersheet, notice: 'Ordersheet was successfully created.' }
        format.json { render :show, status: :created, location: @ordersheet }
      else
        format.html { render :new }
        format.json { render json: @ordersheet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ordersheets/1
  # PATCH/PUT /ordersheets/1.json
  def update
    respond_to do |format|
      if @ordersheet.update(ordersheet_params)
        format.html { redirect_to @ordersheet, notice: 'Ordersheet was successfully updated.' }
        format.json { render :show, status: :ok, location: @ordersheet }
      else
        format.html { render :edit }
        format.json { render json: @ordersheet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ordersheets/1
  # DELETE /ordersheets/1.json
  def destroy
    @ordersheet.destroy
    respond_to do |format|
      format.html { redirect_to ordersheets_url, notice: 'Ordersheet was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ordersheet
      @ordersheet = Ordersheet.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ordersheet_params
      params.require(:ordersheet).permit(:amount, :height, :width)
    end
end
