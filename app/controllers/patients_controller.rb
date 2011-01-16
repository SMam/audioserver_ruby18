class PatientsController < ApplicationController
  require 'lib/audio_class.rb'
  require 'lib/id_validation.rb'

  Thumbnail_size = "160x160"
  Number_of_selection = 2 #Overdraw_times   # for overdrawing of audiograms

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

  ###
  private

  def set_data(data)
    d = Audiodata.new("raw", data)
    @audiogram = convert_to_audiogram(d, @audiogram)
  end

  def convert_to_audiogram(audiodata, audiogram)
    d = audiodata.extract
    a = audiogram
    a.ac_rt_125 = d[:ra][:data][0]  # float
    a.ac_rt_250 = d[:ra][:data][1]
    a.ac_rt_500 = d[:ra][:data][2]
    a.ac_rt_1k  = d[:ra][:data][3]
    a.ac_rt_2k  = d[:ra][:data][4]
    a.ac_rt_4k  = d[:ra][:data][5]
    a.ac_rt_8k  = d[:ra][:data][6]
    a.ac_lt_125 = d[:la][:data][0]
    a.ac_lt_250 = d[:la][:data][1]
    a.ac_lt_500 = d[:la][:data][2]
    a.ac_lt_1k  = d[:la][:data][3]
    a.ac_lt_2k  = d[:la][:data][4]
    a.ac_lt_4k  = d[:la][:data][5]
    a.ac_lt_8k  = d[:la][:data][6]
    a.bc_rt_250 = d[:rb][:data][1]
    a.bc_rt_500 = d[:rb][:data][2]
    a.bc_rt_1k  = d[:rb][:data][3]
    a.bc_rt_2k  = d[:rb][:data][4]
    a.bc_rt_4k  = d[:rb][:data][5]
    a.bc_rt_8k  = d[:rb][:data][6]
    a.bc_lt_250 = d[:lb][:data][1]
    a.bc_lt_500 = d[:lb][:data][2]
    a.bc_lt_1k  = d[:lb][:data][3]
    a.bc_lt_2k  = d[:lb][:data][4]
    a.bc_lt_4k  = d[:lb][:data][5]
    a.bc_lt_8k  = d[:lb][:data][6]
    a.ac_rt_125_scaleout = d[:ra][:scaleout][0]  # boolean
    a.ac_rt_250_scaleout = d[:ra][:scaleout][1]
    a.ac_rt_500_scaleout = d[:ra][:scaleout][2]
    a.ac_rt_1k_scaleout = d[:ra][:scaleout][3]
    a.ac_rt_2k_scaleout = d[:ra][:scaleout][4]
    a.ac_rt_4k_scaleout = d[:ra][:scaleout][5]
    a.ac_rt_8k_scaleout = d[:ra][:scaleout][6]
    a.ac_lt_125_scaleout = d[:la][:scaleout][0]
    a.ac_lt_250_scaleout = d[:la][:scaleout][1]
    a.ac_lt_500_scaleout = d[:la][:scaleout][2]
    a.ac_lt_1k_scaleout = d[:la][:scaleout][3]
    a.ac_lt_2k_scaleout = d[:la][:scaleout][4]
    a.ac_lt_4k_scaleout = d[:la][:scaleout][5]
    a.ac_lt_8k_scaleout = d[:la][:scaleout][6]
    a.bc_rt_250_scaleout = d[:rb][:scaleout][1]
    a.bc_rt_500_scaleout = d[:rb][:scaleout][2]
    a.bc_rt_1k_scaleout = d[:rb][:scaleout][3]
    a.bc_rt_2k_scaleout = d[:rb][:scaleout][4]
    a.bc_rt_4k_scaleout = d[:rb][:scaleout][5]
    a.bc_rt_8k_scaleout = d[:rb][:scaleout][6]
    a.bc_lt_250_scaleout = d[:lb][:scaleout][1]
    a.bc_lt_500_scaleout = d[:lb][:scaleout][2]
    a.bc_lt_1k_scaleout = d[:lb][:scaleout][3]
    a.bc_lt_2k_scaleout = d[:lb][:scaleout][4]
    a.bc_lt_4k_scaleout = d[:lb][:scaleout][5]
    a.bc_lt_8k_scaleout = d[:lb][:scaleout][6]

    #  Air-Rt, data type of :mask is Array, data-order: mask_type, mask_level
    a.mask_ac_rt_125 = d[:ra][:mask][0][1].prec_f rescue nil    # Air-rt
    a.mask_ac_rt_125_type = d[:ra][:mask][0][0] rescue nil
    a.mask_ac_rt_250 = d[:ra][:mask][1][1].prec_f rescue nil
    a.mask_ac_rt_250_type = d[:ra][:mask][1][0] rescue nil
    a.mask_ac_rt_500 = d[:ra][:mask][2][1].prec_f rescue nil
    a.mask_ac_rt_500_type = d[:ra][:mask][2][0] rescue nil
    a.mask_ac_rt_1k = d[:ra][:mask][3][1].prec_f rescue nil
    a.mask_ac_rt_1k_type = d[:ra][:mask][3][0] rescue nil
    a.mask_ac_rt_2k = d[:ra][:mask][4][1].prec_f rescue nil
    a.mask_ac_rt_2k_type = d[:ra][:mask][4][0] rescue nil
    a.mask_ac_rt_4k = d[:ra][:mask][5][1].prec_f rescue nil
    a.mask_ac_rt_4k_type = d[:ra][:mask][5][0] rescue nil
    a.mask_ac_rt_8k = d[:ra][:mask][6][1].prec_f rescue nil
    a.mask_ac_rt_8k_type = d[:ra][:mask][6][0] rescue nil

    a.mask_ac_lt_125 = d[:la][:mask][0][1].prec_f rescue nil    #  Air-Lt
    a.mask_ac_lt_125_type = d[:la][:mask][0][0] rescue nil
    a.mask_ac_lt_250 = d[:la][:mask][1][1].prec_f rescue nil
    a.mask_ac_lt_250_type = d[:la][:mask][1][0] rescue nil
    a.mask_ac_lt_500 = d[:la][:mask][2][1].prec_f rescue nil
    a.mask_ac_lt_500_type = d[:la][:mask][2][0] rescue nil
    a.mask_ac_lt_1k = d[:la][:mask][3][1].prec_f rescue nil
    a.mask_ac_lt_1k_type = d[:la][:mask][3][0] rescue nil
    a.mask_ac_lt_2k = d[:la][:mask][4][1].prec_f rescue nil
    a.mask_ac_lt_2k_type = d[:la][:mask][4][0] rescue nil
    a.mask_ac_lt_4k = d[:la][:mask][5][1].prec_f rescue nil
    a.mask_ac_lt_4k_type = d[:la][:mask][5][0] rescue nil
    a.mask_ac_lt_8k = d[:la][:mask][6][1].prec_f rescue nil
    a.mask_ac_lt_8k_type = d[:la][:mask][6][0] rescue nil

    a.mask_bc_rt_250 = d[:rb][:mask][1][1].prec_f rescue nil    #  Bone-Rt
    a.mask_bc_rt_250_type = d[:rb][:mask][1][0] rescue nil
    a.mask_bc_rt_500 = d[:rb][:mask][2][1].prec_f rescue nil
    a.mask_bc_rt_500_type = d[:rb][:mask][2][0] rescue nil
    a.mask_bc_rt_1k = d[:rb][:mask][3][1].prec_f rescue nil
    a.mask_bc_rt_1k_type = d[:rb][:mask][3][0] rescue nil
    a.mask_bc_rt_2k = d[:rb][:mask][4][1].prec_f rescue nil
    a.mask_bc_rt_2k_type = d[:rb][:mask][4][0] rescue nil
    a.mask_bc_rt_4k = d[:rb][:mask][5][1].prec_f rescue nil
    a.mask_bc_rt_4k_type = d[:rb][:mask][5][0] rescue nil
    a.mask_bc_rt_8k = d[:rb][:mask][6][1].prec_f rescue nil
    a.mask_bc_rt_8k_type = d[:rb][:mask][6][0] rescue nil

    a.mask_bc_lt_250 = d[:lb][:mask][1][1].prec_f rescue nil    #  Bone-Lt
    a.mask_bc_lt_250_type = d[:lb][:mask][1][0] rescue nil
    a.mask_bc_lt_500 = d[:lb][:mask][2][1].prec_f rescue nil
    a.mask_bc_lt_500_type = d[:lb][:mask][2][0] rescue nil
    a.mask_bc_lt_1k = d[:lb][:mask][3][1].prec_f rescue nil
    a.mask_bc_lt_1k_type = d[:lb][:mask][3][0] rescue nil
    a.mask_bc_lt_2k = d[:lb][:mask][4][1].prec_f rescue nil
    a.mask_bc_lt_2k_type = d[:lb][:mask][4][0] rescue nil
    a.mask_bc_lt_4k = d[:lb][:mask][5][1].prec_f rescue nil
    a.mask_bc_lt_4k_type = d[:lb][:mask][5][0] rescue nil
    a.mask_bc_lt_8k = d[:lb][:mask][6][1].prec_f rescue nil
    a.mask_bc_lt_8k_type = d[:lb][:mask][6][0] rescue nil

    return a
  end

  def create_dir_if_not_exist(dir)
    Dir::mkdir(dir) if not File.exists?(dir)
  end

  def convert_to_audiodata(audiogram)
    ra_data = [{:data => audiogram.ac_rt_125, :scaleout => audiogram.ac_rt_125_scaleout},
               {:data => audiogram.ac_rt_250, :scaleout => audiogram.ac_rt_250_scaleout},
               {:data => audiogram.ac_rt_500, :scaleout => audiogram.ac_rt_500_scaleout},
               {:data => audiogram.ac_rt_1k,  :scaleout => audiogram.ac_rt_1k_scaleout} ,
               {:data => audiogram.ac_rt_2k,  :scaleout => audiogram.ac_rt_2k_scaleout} ,
               {:data => audiogram.ac_rt_4k,  :scaleout => audiogram.ac_rt_4k_scaleout} ,
               {:data => audiogram.ac_rt_8k,  :scaleout => audiogram.ac_rt_8k_scaleout} ]
    la_data = [{:data => audiogram.ac_lt_125, :scaleout => audiogram.ac_lt_125_scaleout},
               {:data => audiogram.ac_lt_250, :scaleout => audiogram.ac_lt_250_scaleout},
               {:data => audiogram.ac_lt_500, :scaleout => audiogram.ac_lt_500_scaleout},
               {:data => audiogram.ac_lt_1k,  :scaleout => audiogram.ac_lt_1k_scaleout} ,
               {:data => audiogram.ac_lt_2k,  :scaleout => audiogram.ac_lt_2k_scaleout} ,
               {:data => audiogram.ac_lt_4k,  :scaleout => audiogram.ac_lt_4k_scaleout} ,
               {:data => audiogram.ac_lt_8k,  :scaleout => audiogram.ac_lt_8k_scaleout} ]
    rb_data = [{:data => nil, :scaleout => nil},           # nil is better than "" ?
               {:data => audiogram.bc_rt_250, :scaleout => audiogram.bc_rt_250_scaleout},
               {:data => audiogram.bc_rt_500, :scaleout => audiogram.bc_rt_500_scaleout},
               {:data => audiogram.bc_rt_1k,  :scaleout => audiogram.bc_rt_1k_scaleout} ,
               {:data => audiogram.bc_rt_2k,  :scaleout => audiogram.bc_rt_2k_scaleout} ,
               {:data => audiogram.bc_rt_4k,  :scaleout => audiogram.bc_rt_4k_scaleout} ,
               {:data => audiogram.bc_rt_8k,  :scaleout => audiogram.bc_rt_8k_scaleout} ]
    lb_data = [{:data => nil, :scaleout => nil},           # nil is better than "" ?
               {:data => audiogram.bc_lt_250, :scaleout => audiogram.bc_lt_250_scaleout},
               {:data => audiogram.bc_lt_500, :scaleout => audiogram.bc_lt_500_scaleout},
               {:data => audiogram.bc_lt_1k,  :scaleout => audiogram.bc_lt_1k_scaleout} ,
               {:data => audiogram.bc_lt_2k,  :scaleout => audiogram.bc_lt_2k_scaleout} ,
               {:data => audiogram.bc_lt_4k,  :scaleout => audiogram.bc_lt_4k_scaleout} ,
               {:data => audiogram.bc_lt_8k,  :scaleout => audiogram.bc_lt_8k_scaleout} ]
    ra_mask = [{:type => audiogram.mask_ac_rt_125_type, :level => audiogram.mask_ac_rt_125},
               {:type => audiogram.mask_ac_rt_250_type, :level => audiogram.mask_ac_rt_250},
               {:type => audiogram.mask_ac_rt_500_type, :level => audiogram.mask_ac_rt_500},
               {:type => audiogram.mask_ac_rt_1k_type,  :level => audiogram.mask_ac_rt_1k} ,
               {:type => audiogram.mask_ac_rt_2k_type,  :level => audiogram.mask_ac_rt_2k} ,
               {:type => audiogram.mask_ac_rt_4k_type,  :level => audiogram.mask_ac_rt_4k} ,
               {:type => audiogram.mask_ac_rt_8k_type,  :level => audiogram.mask_ac_rt_8k} ]
    la_mask = [{:type => audiogram.mask_ac_lt_125_type, :level => audiogram.mask_ac_lt_125},
               {:type => audiogram.mask_ac_lt_250_type, :level => audiogram.mask_ac_lt_250},
               {:type => audiogram.mask_ac_lt_500_type, :level => audiogram.mask_ac_lt_500},
               {:type => audiogram.mask_ac_lt_1k_type,  :level => audiogram.mask_ac_lt_1k} ,
               {:type => audiogram.mask_ac_lt_2k_type,  :level => audiogram.mask_ac_lt_2k} ,
               {:type => audiogram.mask_ac_lt_4k_type,  :level => audiogram.mask_ac_lt_4k} ,
               {:type => audiogram.mask_ac_lt_8k_type,  :level => audiogram.mask_ac_lt_8k} ]
    rb_mask = [{:type => nil, :level => nil},
               {:type => audiogram.mask_bc_rt_250_type, :level => audiogram.mask_bc_rt_250},
               {:type => audiogram.mask_bc_rt_500_type, :level => audiogram.mask_bc_rt_500},
               {:type => audiogram.mask_bc_rt_1k_type,  :level => audiogram.mask_bc_rt_1k} ,
               {:type => audiogram.mask_bc_rt_2k_type,  :level => audiogram.mask_bc_rt_2k} ,
               {:type => audiogram.mask_bc_rt_4k_type,  :level => audiogram.mask_bc_rt_4k} ,
               {:type => audiogram.mask_bc_rt_8k_type,  :level => audiogram.mask_bc_rt_8k} ]
    lb_mask = [{:type => nil, :level => nil},
               {:type => audiogram.mask_bc_lt_250_type, :level => audiogram.mask_bc_lt_250},
               {:type => audiogram.mask_bc_lt_500_type, :level => audiogram.mask_bc_lt_500},
               {:type => audiogram.mask_bc_lt_1k_type,  :level => audiogram.mask_bc_lt_1k} ,
               {:type => audiogram.mask_bc_lt_2k_type,  :level => audiogram.mask_bc_lt_2k} ,
               {:type => audiogram.mask_bc_lt_4k_type,  :level => audiogram.mask_bc_lt_4k} ,
               {:type => audiogram.mask_bc_lt_8k_type,  :level => audiogram.mask_bc_lt_8k} ]
    return Audiodata.new("cooked", ra_data, la_data, rb_data, lb_data, ra_mask, la_mask, rb_mask, lb_mask)
  end

  def make_graph_data(audiogram)
    a = Audio.new(convert_to_audiodata(audiogram))
    a.draw
    return a.to_graph_string
  end

  def make_filename(base_dir, base_name)
    # assume make_filename(base_dir, @audiogram.examdate.strftime("%Y%m%d-%H%M%S")) as actual argument
    ver = 0
    Dir.glob("#{base_dir}#{base_name}*").each do |f|
      if /#{base_name}.png\Z/ =~ f
        ver = 1 if ver == 0
      end
      if /#{base_name}-(\d*).png\Z/ =~ f
        ver = ($1.to_i + 1) if $1.to_i >= ver
      end
    end
    if ver == 0
      return "#{base_dir}#{base_name}.png"
    else
      if ver < 100
        ver_str = "%02d" % ver
      else
        ver_str = ver.to_s
      end
      return "#{base_dir}#{base_name}-#{ver_str}.png"
    end
  end

  def build_graph
    exam_year = @audiogram.examdate.strftime("%Y")
    base_dir = "#{Rails.env}/graphs/#{exam_year}/"
    @audiogram.image_location = make_filename(base_dir, @audiogram.examdate.strftime("%Y%m%d-%H%M%S"))
    thumbnail_location = @audiogram.image_location.sub("graphs", "thumbnails")
    create_dir_if_not_exist("public/images/#{Rails.env}")
    create_dir_if_not_exist("public/images/#{Rails.env}/graphs")
    create_dir_if_not_exist("public/images/#{Rails.env}/graphs/#{exam_year}")
    create_dir_if_not_exist("public/images/#{Rails.env}/thumbnails")
    create_dir_if_not_exist("public/images/#{Rails.env}/thumbnails/#{exam_year}")
    buf = make_graph_data(@audiogram)                      # re-make data from audiogram
      tmp_file = "public/images/#{Rails.env}/graphs/tmp.ppm"
      File.open(tmp_file, "wb") do |f|                       # write temporally as ppm-file
      f.puts buf
    end
    system("convert #{tmp_file} public/images/#{@audiogram.image_location}")   # convert with ImageMagick
    system("convert -geometry #{Thumbnail_size} #{tmp_file} public/images/#{thumbnail_location}")
                                                                              # convert to 160x160px thumbnail
  end

  def build_overdrawn_graph(audiogram, *pre_audiograms)  # *pre_audiogram ??????�?��????????
    a = Audio.new(convert_to_audiodata(audiogram))
    p_as = Array.new     # (p)re(_a)udiogram(s) ???? p_as
    pre_audiograms.each do |pre_audiogram|
      p_as << convert_to_audiodata(pre_audiogram)
    end
    a.predraw(p_as)
    a.draw
    buf = a.to_graph_string
    tmp_file = "public/images/#{Rails.env}/graphs/tmp.ppm"
    tmp_file_png = "public/images/#{Rails.env}/graphs/tmp.png"
    File.open(tmp_file, "wb") do |f|                       # write temporally as ppm-file
      f.puts buf
    end
    system("convert #{tmp_file} #{tmp_file_png}")   # convert with ImageMagick
  end

  def select_recent_audiograms(params) # ????????��???�???��?
    audiograms = Array.new
    if params[:selected]
      for id in params[:selected]
        audiograms << Audiogram.find(id.to_i)
      end
      n = audiograms.length
      limit_n = Number_of_selection

      if n > (limit_n-1)
        audiograms.sort! do |s1, s2|
         s2.examdate <=> s1.examdate
        end
        for i in limit_n..(n-1)
          audiograms.delete_at(limit_n)
        end
      end
    end
    return audiograms
  end

end
