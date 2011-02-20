#! /usr/local/bin/ruby
# -*- coding: utf-8 -*-


require 'gtk2'
require 'net/http'
require 'id_validation'
require 'com_RS232C_AA79S'
require 'audio_class'

pixbuf_msg_scan    = Gdk::Pixbuf.new("./images/msg_scan.jpg")
pixbuf_msg_recieve = Gdk::Pixbuf.new("./images/msg_recieve.jpg")
pixbuf_msg_timeout = Gdk::Pixbuf.new("./images/msg_timeout.jpg")

def make_markup(msg, color) # Pango Text Attribute Markup Language
  markup = "<span foreground=\"#{color}\" size=\"x-large\">#{msg}</span>"
end

markup_msg_scan    = make_markup("IDをバーコードまたはキーボードから入力してください\nscan Barcode or Input ID.", "black")
markup_msg_recieve = make_markup("データ受信中\nRecieving data now...", "black")
markup_msg_transmit = make_markup("送信ボタンを押してください\nTransmit, please", "black")
markup_msg_timeout = make_markup("時間切れです\nTimeout!", "red")
markup_msg_invalid_id = make_markup("IDが間違っています。再入力してください\nInvalid ID. Scan or Input again", "red")
markup_msg_no_data = make_markup("有効なデータがありません。\nNo data", "red")

transmit_data = {:hp_id => '', :examdate => '', :data => '', :comment => ''}

window = Gtk::Window.new
window.border_width = 5
window.signal_connect('delete_event') do
  Gtk.main_quit
  false
end

# ID entry area
id_label = Gtk::Label.new("ID: ")
id_entry = Gtk::Entry.new
id_entry.max_length = 20
id_entry.text = ""
id_enter_button = Gtk::Button.new("Enter")

id_box = Gtk::HBox.new(false, 0)
id_box.pack_start(id_label, true, true, 0)
id_box.pack_start(id_entry, true, true, 0)
id_box.pack_start(id_enter_button, true, true, 0)

# audiogram appearance
image = Gtk::Image.new(pixbuf_msg_scan)

# message area
msg_label = Gtk::Label.new #(text_msg_scan)
msg_label.set_markup(markup_msg_scan)

# separator
separator = Gtk::HSeparator.new

# comment area
# comment_retry.active? => true or false

comment_retry = Gtk::CheckButton.new(label = "再検査 RETRY")
comment_masking = Gtk::CheckButton.new(label = "マスキング適用 MASK_")
comment_after_patch = Gtk::CheckButton.new(label = "パッチ後 PATCH")
comment_after_med = Gtk::CheckButton.new(label = "投薬後 MEDIC")
comment_other_check = Gtk::CheckButton.new(label = "その他 OTHER: write here ----->")
comment_other_entry = Gtk::Entry.new
comment_other_entry.max_length = 100
comment_other_box = Gtk::HBox.new(false,0)
comment_other_box.pack_start(comment_other_check, true, true, 0)
comment_other_box.pack_start(comment_other_entry, true, true, 0)

comment_box = Gtk::VBox.new(false,0)
comment_box.pack_start(comment_retry, true, true, 0)
comment_box.pack_start(comment_masking, true, true, 0)
comment_box.pack_start(comment_after_patch, true, true, 0)
comment_box.pack_start(comment_after_med, true, true, 0)
comment_box.pack_start(comment_other_box, true, true, 0)

# button area
button1 = Gtk::Button.new("新規 New")
button1.signal_connect("clicked") do
  id_entry.text = ""
  image.pixbuf = pixbuf_msg_scan
  msg_label.set_markup(markup_msg_scan)
  comment_retry.active = false
  comment_masking.active = false
  comment_after_patch.active = false
  comment_after_med.active = false
  comment_other_check.active = false
  comment_other_entry.text = ""
  transmit_data[:hp_id] = ''
  transmit_data[:examdate] = ''
  transmit_data[:data] = ''
  transmit_data[:comment] = ''
  window.set_focus(id_entry)
end

button2 = Gtk::Button.new("送信 Transmit")
button2.signal_connect("clicked") do
  if transmit_data[:id] != ''
    comment = ""
    comment += "RETRY_" if comment_retry.active?
    comment += "MASK_"  if comment_masking.active?
    comment += "PATCH_" if comment_after_patch.active?
    comment += "MED_"   if comment_after_med.active?
    comment += "OTHER:#{comment_other_entry.text}_" if comment_other_check.active?
    transmit_data[:comment] = comment

    Net::HTTP.version_1_2
    #Net::HTTP.start('172.16.41.20', 3000) do |http|
    Net::HTTP.start('192.168.1.6', 3000) do |http|
      response = http.post("/direct_create/#{transmit_data[:hp_id]}", \
  		       "examdate=#{transmit_data[:examdate]}&data=#{transmit_data[:data]}&comment=#{transmit_data[:comment]}")
      puts response.body
    end

  else
    msg_label.set_markup(markup_msg_no_data)
  end
end

button3 = Gtk::Button.new("終了 Quit")
button3.signal_connect("clicked") do
  Gtk.main_quit
end

button_box = Gtk::HBox.new(false, 0)
button_box.pack_start(button1, true, true, 0)
button_box.pack_start(button2, true, true, 0)
button_box.pack_start(button3, true, true, 0)

# packing box
pack_box1 = Gtk::VBox.new(false, 0)
pack_box1.pack_start(id_box, true, true, 0)
pack_box1.pack_start(Gtk::HSeparator.new, true, true, 0)
pack_box1.pack_start(msg_label, true, true, 0)
pack_box1.pack_start(separator, true, true, 0)
pack_box1.pack_start(comment_box, true, true, 0)
pack_box1.pack_start(button_box, true, true, 0)

pack_box = Gtk::HBox.new(false, 0)
pack_box.pack_start(image, true, true, 0)
pack_box.pack_start(pack_box1, true, true, 0)

# id_enter_button.can_default = true # Casting spells to make default widget
# id_enter_button.grab_default       # [Enter] key activates this widget

id_enter_button.signal_connect("clicked") do
  id_entry.text = id_entry.text.delete("^0-9") # remove non-number
  if valid_id?(id_entry.text) and id_entry.text != ""
    image.pixbuf = pixbuf_msg_recieve
    msg_label.set_markup(markup_msg_recieve)
    transmit_data[:hp_id] = id_entry.text
    transmit_data[:examdate] = Time.now.strftime("%Y:%m:%d-%H:%M:%S")  # 2008:09:27-12:50:00 といった形式
    transmit_data[:data] = recieve_data
    #pixbuf_test_data    = Gdk::Pixbuf.new("./result.ppm")
    pixbuf_test_data    = Gdk::Pixbuf.new("./result.png")
    image.pixbuf = pixbuf_test_data
    msg_label.set_markup(markup_msg_transmit)
  else
    puts "invalid"
    msg_label.set_markup(markup_msg_invalid_id)
  end
end

# ID enterance trigger : write data recieving procedure here
def recieve_data

  actual_code = false # or true

  # actual code start
  if actual_code
    raw_data = get_data_from_audiometer
  else
  # dummy code start
    datafile = "./Data/data_with_mask.dat"
    raw_data = String.new
    File.open(datafile, "r") do |f|
      raw_data = f.read
    end
  end

  r = Audiodata.new("raw", raw_data)
  a = Audio.new(r)
  
  a.draw
  a.output("./result.ppm")
  system("convert ./result.ppm ./result.png")   # convert with ImageMagick
    
  return raw_data
end

window.add(pack_box)
window.show_all
Gtk.main
