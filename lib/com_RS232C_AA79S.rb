require 'timeout'

def get_data_from_audiometer
  port = "/dev/cuaU0"
  option = " evenp -cstopb speed 2400 -ixon -ixoff crtscts"
  #option = " evenp -cstopb speed 4800 -ixon -ixoff crtscts"
  #option = " evenp -cstopb speed 9600 -ixon -ixoff crtscts"
  timelimit = 1200   # i.e. 1200 seconds = 20 mins

  com  = open(port, "r+")
  system( "stty -f " + port + option )
  stream = ''

  begin
    status = timeout(timelimit) do   # timeout処理
      while c = com.read(1)          # RS232C IN
        stream += c
        break if c == "\n"
      end
    end
  rescue Timeout::Error
    stream = "Timeout"
  ensure
    return stream  # 時間内にデータがとれればデータ，時間切れなら"Timeout"を返す
  end
end

if ($0 == __FILE__)
  d = get_data_from_audiometer
  puts d

  File.open("./data.dat","w") do |f|
    f.puts(d)
  end

#  print status,"\n" unless status
end

