seed = Random.new_seed
rng = Random.new(seed)
a = (0..50000).to_a.map do rng.rand(6) end
b = a.group_by{|x| x}.values
puts b.sort.map{|x| [x.first, x.count]}
