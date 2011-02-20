#!/usr/local/bin/ruby
#  Class Audio: 聴検データ取扱い用クラス
#  Copyright 2007-2009 S Mamiya <MamiyaShn@gmail.com>
#  0.20091107

require 'AA79S.rb'

RAILS_ROOT = ".." if not defined? RAILS_ROOT
Image_parts_location = RAILS_ROOT+"/lib/images/" # !!! 必要に応じて変更を !!!
# railsの場合，directoryの相対表示の起点は rails/audiserv であるようだ
Overdraw_times = 2  # 重ね書きの回数．まずは2回，つまり1回前の検査までとする

class Bitmap
 
  RED = [255,0,0]
  BLUE = [0,0,255]
  RED_PRE0 = [255,30,30]
  RED_PRE1 = [255,90,90]
  BLUE_PRE0 = [30,30,255]
  BLUE_PRE1 = [90,90,255]
  BLACK = [0,0,0]
  BLACK_PRE0 = [30,30,30]
  BLACK_PRE1 = [90,90,90]
  WHITE = [255,255,255]
  GRAY = [170,170,170]
  CIRCLE_PTN = [[-5,-2],[-5,-1],[-5,0],[-5,1],[-5,2],[-4,-3],[-4,3],\
    [-3,-4],[-3,4],[-2,-5],[-2,5],[-1,-5],[-1,5],[0,-5],[0,5],[1,-5],[1,5],\
    [2,-5],[2,5],[3,-4],[3,4],[4,-3],[4,3],[5,-2],[5,-1],[5,0],[5,1],[5,2]]
  CROSS_PTN = [[-5,-5],[-5,5],[-4,-4],[-4,4],[-3,-3],[-3,3],[-2,-2],[-2,2],\
    [-1,-1],[-1,1],[0,0],[1,-1],[1,1],[2,-2],[2,2],[3,-3],[3,3],[4,-4],[4,4],\
    [5,-5],[5,5]]
  R_BRA_PTN = [[-8,-5],[-8,-4],[-8,-3],[-8,-2],[-8,-1],[-8,0],[-8,1],[-8,2],\
    [-8,3],[-8,4],[-8,5],[-7,-5],[-7,5],[-6,-5],[-6,5]]
  L_BRA_PTN = [[8,-5],[8,-4],[8,-3],[8,-2],[8,-1],[8,0],[8,1],[8,2],[8,3],\
    [8,4],[8,5],[7,-5],[7,5],[6,-5],[6,5]]
  R_SCALEOUT_PTN = [[-3,12],[-4,13],[-5,6],[-5,7],[-5,8],[-5,9],\
    [-5,10],[-5,11],[-5,12],[-5,13],[-5,14],[-6,13],[-7,12]]
  L_SCALEOUT_PTN = [[3,12],[4,13],[5,6],[5,7],[5,8],[5,9],\
    [5,10],[5,11],[5,12],[5,13],[5,14],[6,13],[7,12]]
  SYMBOL_PTN = {:circle => CIRCLE_PTN, :cross => CROSS_PTN, :r_bracket => R_BRA_PTN,\
        :l_bracket => L_BRA_PTN, :r_scaleout => R_SCALEOUT_PTN, :l_scaleout => L_SCALEOUT_PTN}

  def initialize
    @header = "P6 400 400 255\n"  # PPM magic num、幅、高さ、画素値の最大値
    prepare_buffer
  end

  def prepare_buffer
    @buffer = String.new
  end

  def to_string(rgb)
    s = String.new
    rgb.each do |element|
      s.concat(element)
    end
    return s
  end

  def point(x,y,rgb)
    3.times do |i|
      @buffer[(x + y * 400) * 3 + i] = rgb[i]
    end
  end

  def swap(a,b)
    return b,a
  end

  def line(x1,y1,x2,y2,rgb,dotted)
  # Bresenhamアルゴリズム http://dencha.ojaru.jp/programs_07/pg_graphic_07.html
    if x1 < 0 or x1 > 399 or x2 < 0 or x2 > 399 or \
       y1 < 0 or y1 > 399 or y2 < 0 or y2 > 399
      return
    end
    dx = x2 - x1
    dy = y2 - y1
    if dx*dy < 0
      a = -1        # 直線の傾きが負
    else
      a = 1         # 直線の傾きが正
    end
    dx = dx.abs
    dy = dy.abs
    if dotted == "dot"
      d = 0
    else
      d = 8
    end
    if dx == 0 and dy == 0
      point(x1,y1,rgb)
      return
    end
    if dx > dy      # x を変化させて y を計算
      if x1 > x2
        x1, x2 = swap(x1,x2)
        y1, y2 = swap(y1,y2)
      end
      y = y1
      e = dx
      for x in x1..x2
        e += (2 * dy)
        while e >= (2 * dx)
          e -= (2 * dx)
          y += a
        end
        d += 1
        case d
        when 1..3
          point(x,y,rgb)
        when 5
          d = 0
        when 9
          d = 8
          point(x,y,rgb)
        end
      end
    else      # y を変化させて x を計算
      if y1 > y2
        x1, x2 = swap(x1,x2)
        y1, y2 = swap(y1,y2)
      end
      x = x1
      e = dy
      for y in y1..y2
        e += (2 * dx)
        while e >= (2 * dy)
          e -= (2 * dy)
          x += a
        end
        d += 1
        case d
        when 1..3
          point(x,y,rgb)
        when 5
          d = 0
        when 9
          d = 8
          point(x,y,rgb)
        end
      end
    end
  end

  def put_symbol(symbol, x, y, rgb) # symbol is Symbol, like :circle
    xr = x.round
    yr = y.round
    SYMBOL_PTN[symbol].each do |xy|
      point(xr+xy[0],yr+xy[1],rgb)
    end
  end

  def to_graph_string
    return @header + @buffer
  end

  def output(filename)
    File.open(filename,"wb") do |f|
      f.puts to_graph_string
    end
  end
end

#----------------------------------------#
class Background_bitmap < Bitmap
  def initialize
    super()
    prepare_font
    draw_lines
    add_fonts
  end

  def prepare_buffer
    @buffer = to_string(WHITE) * (400*400)    # 160000 pixels
  end

  def prepare_font
    font_name = ["0","1","2","3","4","5","6","7","8","9","k","Hz","dB","minus"]
    @font = Hash.new
    font_name.each do |fontname|
      font_data = Array.new
      File.open(Image_parts_location+"#{fontname}.ppm") do |f|
        while l = f.gets
          if not /^(\w|#)/ =~ l
            for i in 0..(l.length/3)-1
              j = i * 3
              font_data << [l[j], l[j+1], l[j+2]]
            end
          end
        end
        @font[fontname] = font_data
      end
    end
  end

  def draw_lines               # audiogramの縦横の線を引いている
    y1=30
    y2=348
    line(50,y1,50,y2,[170,170,170],"line")
    for x in 0..6
      x1=70+x*45
      line(x1,y1,x1,y2,[170,170,170],"line")
    end
    line(360,y1,360,y2,[170,170,170],"line")
    x1=50
    x2=360
    line(x1,30,x2,30,[170,170,170],"line")
    line(x1,45,x2,45,[170,170,170],"line")
    line(x1,69,x2,69,[0,0,0],"line")
    for y in 0..10
      y1=93+y*24
      line(x1,y1,x2,y1,[170,170,170],"line")
    end
    line(x1,348,x2,348,[170,170,170],"line")
  end

  def add_fonts
    # add vertical scale
    for i in -1..11
      x = 15
      hear_level = (i * 10).to_s
      y = 69 + i *24 -7
      x += (3 - hear_level.length) * 8
      hear_level.each_byte do |c|
        if c == 45                  # if character is "-"
          put_font(x, y, "minus")
        else
          put_font(x, y, "%c" % c)
        end
        x += 8
      end
    end
    put_font(23, 15, "dB")

    # add holizontal scale
    cycle = ["125","250","500","1k","2k","4k","8k"]
    for i in 0..6
      y = 358
      x = 70 + i * 45 - cycle[i].length * 4 # 8px for each char / 2
      cycle[i].each_byte do |c|
        put_font(x, y, "%c" % c)
        x += 8
      end
    end
    put_font(360, 358, "Hz")
  end

  def put_font(x1,y1,fontname)
    return if not @font[fontname]
    if @font[fontname].length == 150
      dx = 10
    else
      dx = 20
    end
    dy = 15
    for y in 0..dy-1
      for x in 0..dx-1
        point(x1+x,y1+y,@font[fontname][y*dx+x])\
      end
    end
  end
end

def make_background
  bg = Background_bitmap.new
  bg.output(Image_parts_location+"background.ppm")    # !!!!!!!!!!!!!!!
end
#----------------------------------------#
class Audio < Bitmap
  X_pos = [70,115,160,205,250,295,340]   # 各周波数別の横座標

  def initialize(audiodata)              # 引数はFormatted_data のインスタンス
    @audiodata = audiodata
    @air_rt  = @audiodata.extract[:ra]
    @air_lt  = @audiodata.extract[:la]
    @bone_rt = @audiodata.extract[:rb]
    @bone_lt = @audiodata.extract[:lb]
    super()
  end

  def prepare_buffer
    make_background if not File.exist?(Image_parts_location+"background.ppm")
    @buffer = String.new

    File.open(Image_parts_location+"background.ppm") do |f|    # audiogram background 読み込み
      data = f.read(15)
      data = f.read
      @buffer.concat(data)
    end
  end

  def put_rawdata
    return @audiodata.put_rawdata
  end

  def mean4          # 4分法
    if @air_rt[:data][2] and @air_rt[:data][3] and @air_rt[:data][4]
      mean4_rt = (@air_rt[:data][2] + @air_rt[:data][3] * 2 + @air_rt[:data][4]) /4
    else
      mean4_rt = -100.0
    end
    if @air_lt[:data][2] and @air_lt[:data][3] and @air_lt[:data][4]
      mean4_lt = (@air_lt[:data][2] + @air_lt[:data][3] * 2 + @air_lt[:data][4]) /4
    else
      mean4_lt = -100.0
    end
    mean4_bs = {:rt => mean4_rt, :lt => mean4_lt}
  end

  def reg_mean4          # 正規化4分法: scaleout は 105dB に
    if @air_rt[:data][2] and @air_rt[:data][3] and @air_rt[:data][4]
      r = {:data => @air_rt[:data], :scaleout => @air_rt[:scaleout]}
      for i in 2..4
        if r[:scaleout][i]
          r[:data][i] = 105.0
        end
      end
      rmean4_rt = (r[:data][2] + r[:data][3] * 2 + r[:data][4]) /4
    else
      rmean4_rt = -100.0
    end
    if @air_lt[:data][2] and @air_lt[:data][3] and @air_lt[:data][4]
      l = {:data => @air_lt[:data], :scaleout => @air_lt[:scaleout]}
      for i in 2..4
        if l[:scaleout][i]
          l[:data][i] = 105.0
        end
      end
      rmean4_lt = (l[:data][2] + l[:data][3] * 2 + l[:data][4]) /4
    else
      rmean4_lt = -100.0
    end
    rmean4_bs = {:rt => rmean4_rt, :lt => rmean4_lt}
  end


  def mean3          # 3分法
    if @air_rt[:data][2] and @air_rt[:data][3] and @air_rt[:data][4]
      mean3_rt = (@air_rt[:data][2] + @air_rt[:data][3] + @air_rt[:data][4]) /3
    else
      mean3_rt = -100.0
    end
    if @air_lt[:data][2] and @air_lt[:data][3] and @air_lt[:data][4]
      mean3_lt = (@air_lt[:data][2] + @air_lt[:data][3] + @air_lt[:data][4]) /3
    else
      mean3_lt = -100.0
    end
    mean3_bs = {:rt => mean3_rt, :lt => mean3_lt}
  end

  def mean6          # 6分法
    if @air_rt[:data][2] and @air_rt[:data][3] and @air_rt[:data][4] and @air_rt[:data][5]
      mean6_rt = (@air_rt[:data][2] + @air_rt[:data][3] * 2 + @air_rt[:data][4] * 2 + \
                  @air_rt[:data][5] ) /6
    else
      mean6_rt = -100.0
    end
    if @air_lt[:data][2] and @air_lt[:data][3] and @air_lt[:data][4] and @air_lt[:data][5]
      mean6_lt = (@air_lt[:data][2] + @air_lt[:data][3] * 2 + @air_lt[:data][4] * 2 + \
                  @air_lt[:data][5] ) /6
    else
      mean6_lt = -100.0
    end
    mean6_bs = {:rt => mean6_rt, :lt => mean6_lt}
  end

  def draw_sub(audiodata, timing)
    case timing  # timingは重ね書き用の引数で検査の時期がもっとも古いものは
                 # pre0，やや新しいものは pre1とする
    when "pre0"
      rt_color = RED_PRE0
      lt_color = BLUE_PRE0
      bc_color = BLACK_PRE0
    when "pre1"
      rt_color = RED_PRE1
      lt_color = BLUE_PRE1
      bc_color = BLACK_PRE1
    else
      rt_color = RED
      lt_color = BLUE
      bc_color = BLACK    
    end
    scaleout = audiodata[:scaleout]
    threshold = audiodata[:data]
    for i in 0..6
      if threshold[i]   # threshold[i] が nilの時は plot処理を skipする
        threshold[i] = threshold[i] + 0.0
        case audiodata[:side]
        when "Rt"
          case audiodata[:mode]
          when "Air"
            put_symbol(:circle, X_pos[i], threshold[i] / 10 * 24 + 69, rt_color)
            if scaleout[i]
              put_symbol(:r_scaleout, X_pos[i], threshold[i] / 10 * 24 + 69, rt_color)
            end
          when "Bone"
            put_symbol(:r_bracket, X_pos[i], threshold[i] / 10 * 24 + 69, bc_color)
            if scaleout[i]
              put_symbol(:r_scaleout, X_pos[i], threshold[i] / 10 * 24 + 69, bc_color)
            end
          end
        when "Lt"
          case audiodata[:mode]
          when "Air"
            put_symbol(:cross, X_pos[i], threshold[i] / 10 * 24 + 69, lt_color)
            if scaleout[i]
              put_symbol(:l_scaleout, X_pos[i], threshold[i] / 10 * 24 + 69, lt_color)
            end
          when "Bone"
            put_symbol(:l_bracket, X_pos[i], threshold[i] / 10 * 24 + 69, bc_color)
            if scaleout[i]
              put_symbol(:l_scaleout, X_pos[i], threshold[i] / 10 * 24 + 69, bc_color)
            end
          end
        end
      end
    end
   
    if audiodata[:mode] == "Air"  # 気導の場合は周波数間の線を描く
      i = 0
      while i < 6
        if scaleout[i] or (not threshold[i])
          i += 1
          next
        end
        line_from = [X_pos[i],(threshold[i] / 10 * 24 + 69).prec_i]
                        # prec_i は float => integer のメソッド, 逆は prec_f
        j = i + 1
        while j < 7
          if not threshold[j]
            if j == 6
              i += 1
            end
            j += 1
            next
          end
          if scaleout[j]
            i += 1
            break
          else
            line_to = [X_pos[j],(threshold[j] / 10 * 24 + 69).prec_i]
            case audiodata[:side]
            when "Rt"
              line(line_from[0],line_from[1],line_to[0],line_to[1],rt_color,"line")
            when "Lt"
              line(line_from[0],line_from[1]+1,line_to[0],line_to[1]+1,lt_color,"dot")
            end
            i = j
            break
          end
        end
      end
    end
  end

  def draw
    draw_sub(@air_rt, "latest")
    draw_sub(@air_lt, "latest")
    draw_sub(@bone_rt, "latest")
    draw_sub(@bone_lt, "latest")
  end

  def predraw(preexams) # preexams は以前のデータの配列，要素はAudiodata
                        # preexams[0]が最も新しいデータ
    revert_exams = Array.new
    predata_n = Overdraw_times - 1
    element_n = (preexams.length < predata_n)? preexams.length: predata_n
               # 要素数か(重ね書き数-1)の小さい方の数を有効要素数とする
    element_n.times do |i|
      revert_exams[i] = preexams[element_n-i-1]
    end        # 古い順に並べ直す

    # 有効な要素の中で古いものから描いていく
    element_n.times do |i|
      exam = revert_exams[i]
      timing = "pre#{i}"
      draw_sub(exam.extract[:ra], timing)
      draw_sub(exam.extract[:la], timing)
      draw_sub(exam.extract[:rb], timing)
      draw_sub(exam.extract[:lb], timing)
    end
  end

end

#----------------------------------------#
if ($0 == __FILE__)

  datafile = "./Data/data_with_mask.dat"
  #datafile = "./Data/data1.dat"
  #datafile = "./Data/data2.dat"
  buf = String.new
  File.open(datafile,"r") do |f|
    buf = f.read
  end
  d = Audiodata.new("raw", buf)
  a = Audio.new(d)

  p a.mean6
  p a.put_rawdata
  
  puts "pre draw"
  
  a.draw
  
  puts "pre output"
  
  a.output("./test.ppm")    
#----------
=begin
  ra = ["0","10","20","30","40","50","60"]
  la = ["1","11","21","31","41","51","61"]
  rm = ["b0","b10","b20","b30","b40","b50","b60"]
  lm = ["w1","w11","w21","w31","w41","w51","w61"]

  dd = Audiodata.new("cooked", ra,la,ra,la,rm,lm,lm,rm)
  aa = Audio.new(dd)

  p aa.reg_mean4
  p aa.put_rawdata

  aa.draw
  aa.output("./test.ppm")
=end

end
