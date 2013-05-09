require 'uri'
require 'json'
load './httpget.rb'
require 'rchart'

def get_friends(uid)
	hc = get_html_content("https://api.vk.com/method/friends.get?fields=uid,first_name,last_name&uid="+uid)
	j = JSON.parse hc.body
	return j["response"]
end
def get_audio(uid)
	hc = get_html_content("https://api.vk.com/method/audio.get?uid="+uid)
	j = JSON.parse hc.body
	return j["response"]
end

def get_wall(uid, filter="",count=20)
	filter = "&filter=#{filter}" if filter != ""
	count = "&count=#{count}" if count != 20
	hc = get_html_content("https://api.vk.com/method/wall.get?owner_id="+uid+filter+count)
	j = JSON.parse hc.body
	return j["response"]
end

def print_wall(uid)
	w = get_wall(uid)
	w.drop(1).each do |ent|
		puts ent["from id"]
		puts ent["date"]
		puts ent["text"]
	end
end

def scan_friends_reposts(uid,count)
	hcf = get_html_content("https://api.vk.com/method/friends.get?uid="+uid+"&fields=uid,first_name,last_name")
	jf = JSON.parse hcf.body
	ids_a = jf["response"]
	ids_a.each do |fnd|
		fid = fnd["uid"]
		wall = get_wall(fid.to_s, "owner",count)
		next if wall.nil?
		next if wall[0] == 0
		id = wall[1]["from_id"]
		post_count = wall.size - 1
		repost_count = 0
		wall.drop(1).each do |entry|
			if !entry["copy_owner_id"].nil? 
				repost_count+=1
			end
		end
		puts "Person:#{fnd["first_name"]} #{fnd["last_name"]} \t Post count:#{post_count} \t Repost percent: #{repost_count.to_f/post_count.to_f * 100}%"
	end
end

def get_group_name_by_id(id)
	hc = get_html_content("https://api.vk.com/method/groups.getById?gids="+id+"&fields=title")
	j = JSON.parse hc.body
	return j["response"][0]["name"]
end

def repost_chart(uid,post_count,treshold)
	hcf = get_html_content("https://api.vk.com/method/friends.get?uid="+uid+"&fields=uid,first_name,last_name")
	jf = JSON.parse hcf.body
	ids_a = jf["response"]
	r_id_c = Hash.new
	ids_a.each do |fnd|
		fid = fnd["uid"]
		wall = get_wall(fid.to_s, "owner",post_count)
		next if wall.nil?
		next if wall[0] == 0
		id = wall[1]["from_id"]
		wall.drop(1).each do |entry|
			if !entry["copy_owner_id"].nil? 
				r_id_c[entry["copy_owner_id"]] = 0 if r_id_c[entry["copy_owner_id"]].nil?
				r_id_c[entry["copy_owner_id"]] += 1
			end
		end
	end
	r_id_c_a = r_id_c.to_a
	r_id_c_a.sort! {|a1,a2| a1[1] <=> a2[1]}
	r_id_c_a.reverse!
	result = r_id_c_a.map do |k,v|
		name = ""
		if k >= 0
			name,v = get_user_name(k.to_s),v
		else
			name,v = get_group_name_by_id((-k).to_s),v
		end

	end
	result.select {|k,v| v >= treshold}
end

def get_users(uid)
	hc = get_html_content("https://api.vk.com/method/users.get?uids="+uid+"&fields=uid,first_name,last_name,nickname,screen_name,sex,bdate,city,country,timezone,photo,photo_medium,photo_big,has_mobile,rate,contacts,education,online,counters")
	jf = JSON.parse hc.body
	return jf
end
def get_user_name(uid)
	hc = get_html_content("https://api.vk.com/method/users.get?uids="+uid+"&fields=first_name,last_name")
	jf = (JSON.parse hc.body)["response"][0]
	return jf["first_name"] + " " + jf["last_name"]
end

def users_search(q)
	q = URI.encode_www_form(["q" => q])
	hc = get_html_content("https://api.vk.com/method/users.search?q="+q+"&fields=uid,first_name,last_name")
	jf = JSON.parse hc.body
	return jf
end

def get_subscriptions(uid)
	hc = get_html_content("https://api.vk.com/method/subscriptions.get?uid="+uid)
	j = JSON.parse hc.body
	return j["response"]
end

if __FILE__ == $0
	data = repost_chart("11559302",6,2)
	data1 = data.map {|n,c| c}
	#puts data1.to_s
	data2 = data.map {|n,c| n}
	#puts data2.to_s

	#p = Rdata.new
	#p.add_point(data1,"Serie1")
	#p.add_point(data2,"Serie2")
	#p.add_all_series
	#p.set_abscise_label_serie("Serie2")

	#ch = Rchart.new(300,200)
	##ch.draw_filled_rounded_rectangle(7,7,293,193,5,240,240,240)
	##ch.draw_rounded_rectangle(5,5,295,195,5,230,230,230)

	##Load palette from array [[r,g,b],[r1,g1,b1]]
	#ch.load_color_palette([[168,188,56],[188,208,76],[208,228,96],[228,245,116],[248,255,136]])
	#ch.draw_filled_circle(122,102,70,200,200,200)

	##ch.set_font_properties("tahoma.ttf",8)

	## Draw Basic Pie Graph
	#ch.draw_basic_pie_graph(p.get_data,p.get_data_description,120,100,70,Rchart::PIE_PERCENTAGE,255,255,218)
	##ch.draw_pie_legend(230,15,p.get_data,p.get_data_description,250,250,250)

	#ch.render_png("basic-pie")
	#data1 = [1,2,3,4,5,6,7,8]
	#data2 = ["A", "b", "c", "d", "e", "f", "g", "h"]
	p = Rdata.new
	p.add_point(data1,"Serie1")
	p.add_point(data2,"Serie2")
	p.add_all_series
	p.set_abscise_label_serie("Serie2")

	ch = Rchart.new(300,200)
	ch.draw_filled_rounded_rectangle(7,7,293,193,5,240,240,240)
	ch.draw_rounded_rectangle(5,5,295,195,5,230,230,230)

	#Load palette from array [[r,g,b],[r1,g1,b1]]
	ch.load_color_palette([[168,188,56],[188,208,76],[208,228,96],[228,245,116],[248,255,136]])
	ch.draw_filled_circle(122,102,70,200,200,200)

	ch.set_font_properties("tahoma.ttf",6)

	# Draw Basic Pie Graph
	ch.draw_basic_pie_graph(p.get_data,p.get_data_description,120,100,70,Rchart::PIE_PERCENTAGE,255,255,218)
	ch.draw_pie_legend(230,15,p.get_data,p.get_data_description,250,250,250)

	ch.render_png("basic-pie")
end
