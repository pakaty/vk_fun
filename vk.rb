require 'uri'
require 'json'
load './httpget.rb'

def get_friends(uid)
	hc = get_html_content("https://api.vk.com/method/friends.get?fields=uid,first_name,last_name&uid="+uid)
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

if __FILE__ == $0
	scan_friends_reposts("11559302",100)
end
