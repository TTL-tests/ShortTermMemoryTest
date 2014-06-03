class ListsController < ApplicationController
  before_action :set_list, only: [:show, :edit, :update, :destroy]
  skip_before_filter  :verify_authenticity_token

  before_filter :cors_preflight_check
  after_filter :cors_set_access_control_headers


  # GET /lists
  # GET /lists.json
  def index
    @lists = List.all
  end

  # GET /lists/1
  # GET /lists/1.json
  def show
  end

  # GET /lists/new
  def new
    @list = List.new
  end

  # GET /lists/1/edit
  #def edit
  #end


  #POST /nextList
  def getnextlist
    user = User.find_by username:params[:username]
    testcases = Testcase.where user_id:user.id
    max = 0
    for testcase in testcases do
      if testcase.id>max
        max=testcase.id
      end
    end
    if max != 0
      lastCase = Testcase.find max
      max = lastCase.list_id
    end
    min = 99999999
    retValue = 99999999
    lists = List.where training: false, active: true
    for list in lists do
      if list.id<min
        min = list.id
      end
      if max<list.id and retValue>list.id
        retValue = list.id
      end
    end
    if retValue == 99999999
      retValue = min
    end
    list = List.find retValue
    testcase = Testcase.new user_id:user.id, list_id:list.id, training: false, finished: false
    testcase.save


    render json: testcase.to_json(:only => :id,
                                  :include=>{:list=>{ :only=> [:id, :training],
                                                      :include => { :numbersets => {
                                                          :only => [:position, :order],
                                                          :include => { :numbers => {
                                                              :only => [:position, :text]
                                                          }}
                                                      }}
                                  }}
    )
  end


  #POST /trainingList
  def getTrainingList
    user = User.find_by username:params[:username]
    list = List.find_by training:true
    testcase = Testcase.new user_id:user.id, list_id:list.id, training: true, finished: false
    testcase.save
    render json: testcase.to_json(:only => :id,
                                  :include=>{:list=>{ :only=> [:id, :training],
                                                      :include => { :numbersets => {
                                                                                  :only => [:position, :order],
                                                                                  :include => { :numbers => {
                                                                                                          :only => [:position, :text]
                                                                                  }}
                                                      }}
                                  }}
    )
  end

  # POST /lists
  # POST /lists.json
  def create

    require 'csv'

    csvfile = params[:file]
    @list = List.new(list_params)
    if(params[:training])
      @list.training=true
    else
      @list.training = false
    end

    @list.active = true



    @list.filename = csvfile.original_filename
    @list.save()


    cvsArray = CSV.read(csvfile.path)

    last = -1
    position = 0

    cvsArray.drop(1).each do |row|
      if row[0] != last
        position += 1
        last = row[0]
        @numberset = Numberset.new
        @numberset.list = @list
        @numberset.position = position
        @numberset.length = row[0]
        @numberset.order = row[5]
        @numberset.save()
      end
      number = Number.new
      number.numberset = @numberset
      number.text = row[1]
      number.position = row[2]
      number.save

    end


    respond_to do |format|
       format.html { redirect_to @list, notice: 'List was successfully created.' }
       format.json { render action: 'show', status: :created, location: @list }
    end
    #end
  end

  # PATCH/PUT /lists/1
  # PATCH/PUT /lists/1.json
  #def update
  #  respond_to do |format|
  #    if @list.update(list_params)
  #      format.html { redirect_to @list, notice: 'List was successfully updated.' }
  #      format.json { head :no_content }
  #    else
  #      format.html { render action: 'edit' }
  #      format.json { render json: @list.errors, status: :unprocessable_entity }
  #    end
  #  end
  #end

  # DELETE /lists/1
  # DELETE /lists/1.json
  def destroy
    @list.destroy
    respond_to do |format|
      format.html { redirect_to lists_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_list
      @list = List.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def list_params
      params.permit(:filename)
    end
end
