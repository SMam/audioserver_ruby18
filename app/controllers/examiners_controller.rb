class ExaminersController < ApplicationController
  # GET /examiners
  # GET /examiners.xml
  def index
    @examiners = Examiner.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @examiners }
    end
  end

  # GET /examiners/1
  # GET /examiners/1.xml
  def show
    @examiner = Examiner.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @examiner }
    end
  end

  # GET /examiners/new
  # GET /examiners/new.xml
  def new
    @examiner = Examiner.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @examiner }
    end
  end

  # GET /examiners/1/edit
  def edit
    @examiner = Examiner.find(params[:id])
  end

  # POST /examiners
  # POST /examiners.xml
  def create
    @examiner = Examiner.new(params[:examiner])

    respond_to do |format|
      if @examiner.save
        format.html { redirect_to(@examiner, :notice => 'Examiner was successfully created.') }
        format.xml  { render :xml => @examiner, :status => :created, :location => @examiner }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @examiner.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /examiners/1
  # PUT /examiners/1.xml
  def update
    @examiner = Examiner.find(params[:id])

    respond_to do |format|
      if @examiner.update_attributes(params[:examiner])
        format.html { redirect_to(@examiner, :notice => 'Examiner was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @examiner.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /examiners/1
  # DELETE /examiners/1.xml
  def destroy
    @examiner = Examiner.find(params[:id])
    @examiner.destroy

    respond_to do |format|
      format.html { redirect_to(examiners_url) }
      format.xml  { head :ok }
    end
  end
end
