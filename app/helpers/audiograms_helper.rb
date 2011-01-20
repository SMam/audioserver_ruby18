module AudiogramsHelper

  def mean(mode, audiogram)
    case mode
    when "3"
      result_R = (audiogram.ac_rt_500 + audiogram.ac_rt_1k + audiogram.ac_rt_2k)/3.0 rescue "--"
      result_L = (audiogram.ac_lt_500 + audiogram.ac_lt_1k + audiogram.ac_lt_2k)/3.0 rescue "--"
    when "4"
      result_R = (audiogram.ac_rt_500 + 2 * audiogram.ac_rt_1k + audiogram.ac_rt_2k)/4.0 rescue "--"
      result_L = (audiogram.ac_lt_500 + 2 * audiogram.ac_lt_1k + audiogram.ac_lt_2k)/4.0 rescue "--"
    when "4R"
      result_R = (reg(audiogram, "R", "500") + 2 * reg(audiogram, "R", "1k") + reg(audiogram, "R", "2k"))/4.0 rescue "--"
      result_L = (reg(audiogram, "L", "500") + 2 * reg(audiogram, "L", "1k") + reg(audiogram, "L", "2k"))/4.0 rescue "--"      
    when "6"
      result_R = (audiogram.ac_rt_500 + 2 * audiogram.ac_rt_1k + 2 * audiogram.ac_rt_2k + audiogram.ac_rt_4k)/6.0 rescue "--"
      result_L = (audiogram.ac_lt_500 + 2 * audiogram.ac_lt_1k + 2 * audiogram.ac_lt_2k + audiogram.ac_lt_4k)/6.0 rescue "--"
    end
    result_R = round1(result_R) if result_R.class == Float
    result_L = round1(result_L) if result_L.class == Float
    return {:R => result_R, :L => result_L}
  end

  def reg_id(id)
    r_id = "0" * (10-id.length) + id
    return "#{r_id[0..2]}-#{r_id[3..6]}-#{r_id[7..8]}-#{"%c" % r_id[9]}"
  end

  private
  def reg(audiogram, side, freq)
    case side
    when "R"
      case freq
      when "500"
        (audiogram.ac_rt_500 > 100.0 or audiogram.ac_rt_500_scaleout)?105.0:audiogram.ac_rt_500 rescue nil
      when "1k"
        (audiogram.ac_rt_1k > 100.0 or audiogram.ac_rt_1k_scaleout)?105.0:audiogram.ac_rt_1k rescue nil
      when "2k"
        (audiogram.ac_rt_2k > 100.0 or audiogram.ac_rt_2k_scaleout)?105.0:audiogram.ac_rt_2k rescue nil
      end
    when "L"
      case freq
      when "500"
        (audiogram.ac_lt_500 > 100.0 or audiogram.ac_lt_500_scaleout)?105.0:audiogram.ac_lt_500 rescue nil
      when "1k"
        (audiogram.ac_lt_1k > 100.0 or audiogram.ac_lt_1k_scaleout)?105.0:audiogram.ac_lt_1k rescue nil
      when "2k"
        (audiogram.ac_lt_2k > 100.0 or audiogram.ac_lt_2k_scaleout)?105.0:audiogram.ac_lt_2k rescue nil
      end
    end
  end

  def round1(r)  # 小数点1位で四捨五入
    rr = r * 10.0
    rr = rr.round
    return (rr / 10.0)
  end

end
