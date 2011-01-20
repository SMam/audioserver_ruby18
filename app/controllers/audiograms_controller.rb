class AudiogramsController < ApplicationController
  # GET /patients/:patient_id/audiograms          {:action=>"index", :controller=>"audiograms"}
  # GET /patients.xml
  def index
    @patient = Patient.find(params[:patient_id])
    @audiograms = @patient.audiograms.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @patients }
    end
  end

  # GET /patients/:patient_id/audiograms/1
  # GET /patients/1.xml
  def show
    @patient = Patient.find(params[:patient_id])
    @audiogram = @patient.audiograms.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @patient }
    end
  end

  # GET /patients/:patient_id/audiograms/1/edit
  def edit
    @patient = Patient.find(params[:patient_id])
    @audiogram = @patient.audiograms.find(params[:id])
  end

  # POST /patients/:patient_id/audiograms
  # POST /patients.xml
  def create
    @patient = Patient.find(params[:patient_id])
    @audiogram = @patient.audiograms.create(params[:audiogram])

    respond_to do |format|
      if @audiogram.save
        format.html { redirect_to(@audiogram, :notice => 'Audiogram was successfully created.') }
        format.xml  { render :xml => @patient, :status => :created, :location => @patient }
      else
        format.html { render :action => "new" } #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! how shall i do
        format.xml  { render :xml => @audiogram.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /patients/:patient_id/audiograms/1
  # PUT /patients/1.xml
  def update
    @patient = Patient.find(params[:patient_id])
    @audiogram = @patient.audiograms.find(params[:id])

    respond_to do |format|
      if @audiogram.update_attributes(params[:audiogram])
        format.html { redirect_to(@audiogram, :notice => 'Audiogram was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" } #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! how...?
        format.xml  { render :xml => @audiogram.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /patients/:patient_id/audiograms/1
  # DELETE /patients/1.xml
  def destroy
    @patient = Patient.find(params[:patient_id])
    @audiogram = @patient.audiograms.find(params[:id])
    @audiogram.destroy

    respond_to do |format|
      format.html { redirect_to(patient_audiograms_url) }
      format.xml  { head :ok }
    end
  end

end
