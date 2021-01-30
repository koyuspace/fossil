sed = ...

if not sed then
	print("Usage:")
	print("  bulksed <sed command>")
	print("  Handle with care and have a backup ready!")
end

while true do
	local i = io.read();
	if not i then break end
	os.execute("sed -i '"..sed.."' '"..i.."'")
end
