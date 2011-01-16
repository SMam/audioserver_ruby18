class PatientsController < ApplicationController
  # GET /patients
  # GET /patients.xml
  def index
    @patients = Patient.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @patients }
    end
  end

  # GET /patients/1
  # GET /patients/1.xml
  def show
    @patient = Patient.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @patient }
    end
  end

  # GET /patients/new
  # GET /patients/new.xml
  def new
    @patient = Patient.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @patient }
    end
  end

  # GET /patients/1/edit
  def edit
    @patient = Patient.find(params[:id])
  end

  # POST /patients
  # POST /patients.xml
  def create
    @patient = Patient.new(params[:patient])

    respond_to do |format|
      if @patient.save
        format.html { redirect_to(@patient, :notice => 'Patient was successfully created.') }
        format.xml  { render :xml => @patient, :status => :created, :location => @patient }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @patient.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /patients/1
  # PUT /patients/1.xml
  def update
    @patient = Patient.find(params[:id])

    respond_to do |format|
      if @patient.update_attributes(params[:patient])
        format.html { redirect_to(@patient, :notice => 'Patient was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @patient.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /patients/1
  # DELETE /patients/1.xml
  def destroy
    @patient = Patient.find(params[:id])
    @patient.destroy

    respond_to do |format|
      format.html { redirect_to(patients_url) }
      format.xml  { head :ok }
    end
  end

  # GET /direct_create/:hp_id
  # create audiogram directly from http request
  # http://host.ip/direct_create/hp_id?data="..."&examdate="..."&comment="..."
  def direct_create
    hp_id = valid_id?(params[:hp_id])
    if not @patient = Patient.find_by_hp_id(hp_id)
      @patient = Patient.new
      @patient.hp_id = hp_id
    end

    audiogram_created = false
    if @patient.save
      @audiogram = @patient.audiograms.create
      @audiogram.examdate = Time.local *params[:examdate].split(/:|-/)
      @audiogram.comment = params[:comment]
      @audiogram.manual_input = false
      set_data(params[:data])
      build_graph
      audiogram_created = @audiogram.save
    end

    if audiogram_created
      render :nothing => true, :status => 201
    else
      render :nothing => true, :status => 501
    end

    #respond_to do |format|
    #  format.html { redirect_to(patients_url) }
    #  format.xml  { head :ok }
    #end
  end

  # GET /by_hp_id/:hp_id
  # get index by hp_id
  def by_hp_id
    hp_id = valid_id?(params[:hp_id])
    patient_exists = false
    if @patient = Patient.find_by_hp_id(hp_id)
      patient_exists = true
    else
      @patient = Patient.new
      @patient.hp_id = hp_id
      patient_exists = @patient.save
    end

    respond_to do |format|
      format.html { redirect_to(@patient) }
      format.xml  { head :ok }
    end
  end
end
