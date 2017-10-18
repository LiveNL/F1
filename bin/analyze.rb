require 'multi_json'

def json
  @json ||= MultiJson.load File.open('crashes-final.json'), symbolize_keys: true
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

brake_at = json[:crashes].group_by{|x| [x[:brake_at], x[:circuit]]}.map{|k,v| [k,v.count]}.sort
brake_at.map {|k,v| "(#{k[0]},#{v})"}.join

belgium = json[:crashes].find_all{|x| x[:circuit] == "Belgium"}
belgium.group_by{|x| x[:m].to_i}.map{|k,v| [k, v.count]}.sort

mexico = json[:crashes].find_all{|x| x[:circuit] == "Mexico"}.group_by{|x| x[:m].to_i}.map{|k,v| [k, v.count]}.sort.map {|k,v| "(#{k},#{v})"}.join
mexico = json[:crashes].find_all{|x| x[:circuit] == "Bahrain"}.group_by{|x| x[:m].to_i}.map{|k,v| [k, v.count]}.sort.map {|k,v| "(#{k},#{v})"}.join

require'pry';binding.pry;
