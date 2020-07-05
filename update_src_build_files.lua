#!/usr/bin/lua5.3

files = {}

p = io.popen("find src/ -name \"*.vala\" | cut -d/ -f2-")

while true do
	local i = p:read()
	if not i then break end
	files[#files+1] = i
end

p:close()

function compare_files(a,b)
	local as = not not a:find("/",1,true)
	local bs = not not b:find("/",1,true)
	if not (as == bs) then
		return not as
	end
	return a < b
end

table.sort(files,compare_files)

function print_files()
	for _,f in pairs(files) do
		print("\t'"..f:gsub("'","\\'").."', #AUTOUPDATE_FILE")
	end
end


p = io.popen("cat src/meson.build | grep -v -F \"#AUTOUPDATE_FILE\"")
while true do
	local i = p:read()
	if not i then break end
	print(i)
	if i:find("##_FILES_##",1,true) then
		print_files();
	end	
end

p:close()
