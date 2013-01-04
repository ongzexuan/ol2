class CheckpointsController < ApplicationController
  before_filter :google_login, only: ["create", "update", "import"]

  def google_login
    session = GoogleDrive.login(ENV["OL_GMAIL_USERNAME"],ENV["OL_GMAIL_PASSWORD"])
    @ws = session.spreadsheet_by_key(ENV["SPREADSHEET_KEY"]).worksheets[5]
  end

  # GET /checkpoints
  # GET /checkpoints.json
  def index
    @checkpoints = Checkpoint.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @checkpoints }
    end
  end

  # GET /checkpoints/1
  # GET /checkpoints/1.json
  def show
    @checkpoint = Checkpoint.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @checkpoint }
    end
  end

  # GET /checkpoints/new
  # GET /checkpoints/new.json
  def new
    @checkpoint = Checkpoint.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @checkpoint }
    end
  end

  # GET /checkpoints/1/edit
  def edit
    @checkpoint = Checkpoint.find(params[:id])
  end

  # POST /checkpoints
  # POST /checkpoints.json
  def create
    @checkpoint = Checkpoint.new(params[:checkpoint])
    row = @ws.num_rows()+1

    respond_to do |format|
      if @checkpoint.save
        @ws[row,1] = @checkpoint.id
        @ws[row,2] = @checkpoint.checkpoint
        @ws[row,3] = @checkpoint.lesson_id
        @ws[row,4] = @checkpoint.description
        @ws[row,5] = @checkpoint.videourl
        @ws[row,6] = @checkpoint.objective
        @ws.save()
        format.html { redirect_to @checkpoint, notice: 'Checkpoint was successfully created.' }
        format.json { render json: @checkpoint, status: :created, location: @checkpoint }
      else
        format.html { render action: "new" }
        format.json { render json: @checkpoint.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /checkpoints/1
  # PUT /checkpoints/1.json
  def update
    @checkpoint = Checkpoint.find(params[:id])
    row = @checkpoint.id+1
    respond_to do |format|
      if @checkpoint.update_attributes(params[:checkpoint])
        @ws[row,2] = @checkpoint.checkpoint
        @ws[row,3] = @checkpoint.lesson_id
        @ws[row,4] = @checkpoint.description
        @ws[row,5] = @checkpoint.videourl
        @ws[row,6] = @checkpoint.objective
        @ws.save()
        format.html { redirect_to @checkpoint, notice: 'Checkpoint was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @checkpoint.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /checkpoints/1
  # DELETE /checkpoints/1.json
  def destroy
    @checkpoint = Checkpoint.find(params[:id])
    @checkpoint.destroy

    respond_to do |format|
      format.html { redirect_to checkpoints_url }
      format.json { head :no_content }
    end
  end

  def import
    Checkpoint.import(@ws)
    redirect_to checkpoints_url, notice: "Imported!"
  end
end
