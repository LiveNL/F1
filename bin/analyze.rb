require 'multi_json'

def json
  @json ||= MultiJson.load File.open('crashes.json'), symbolize_keys: true
end

def sec
  by_sec = json[:crashes].group_by{|x| x[:sec]}.sort
  by_sec.map {|k,v| [k,v.count]}
end

def dst
  by_dst = json[:crashes].group_by{|x| x[:distance]}.sort
  by_dst.map {|k,v| [k,v.count, v.first[:speed], v.first[:circuit]]}
end

def brk
  by_brk = json[:crashes].group_by{|x| x[:distance] - x[:brake_at] }.sort
  by_brk.map {|k,v| [k,v.count, v.first[:speed], v.first[:circuit]]}
end

def brkat
  by_brk = json[:crashes].group_by{|x| [x[:brake_at], x[:circuit]] }.sort
  by_brk.map {|k,v|
    "(#{k[0]},#{v.first[:distance]},#{v.count})"
  }
end

def pos
  by_pos = json[:crashes].group_by{|x| x[:position]}.sort
  by_pos.map {|k,v| [k,v.count]}
end

def start
  by_pos = json[:crashes].group_by{|x| x[:start]}.sort
  by_pos.map {|k,v| [k,v.count]}
end


def speed
  by_spd = json[:crashes].group_by{|x| [x[:speed], x[:distance]]}.sort
  by_spd.map {|k,v| [k,v.count]}
end
require'pry';binding.pry;
