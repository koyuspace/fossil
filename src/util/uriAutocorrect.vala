public class Dragonstone.Util.UriAutoprefix : Object {

	public List<Dragonstone.Util.UriAutoprefixEntry> entrys = new List<Dragonstone.Util.UriAutoprefixEntry>();
	
	public UriAutoprefix.default_configuration(){
		add("gopher.","gopher://gopher.");
		add("gopher:","gopher://");
		add("gemini.","gemini://gemini.");
		add("gemini:","gemini://");
		add("file:","file://");
		add("/","file:///");
		add("~/","file://"+GLib.Environment.get_home_dir()+"/");
	}
	
	public void add(string prefix, string replacement){
		entrys.append(new Dragonstone.Util.UriAutoprefixEntry(prefix, replacement));
	}
	
	public string try_autoprefix(string uri){
		print(@"[try_autoprefix] $uri\n");
		string best_match = uri;
		uint closest_match_length = 0;
		foreach(Dragonstone.Util.UriAutoprefixEntry entry in entrys){
			print(@"[try_autoprefix] '$uri'.has_prefix('$(entry.prefix)') = ?\n");
			if (uri.has_prefix(entry.prefix) && entry.prefix.length > closest_match_length){
					print(@"[try_autoprefix] match: $(entry.prefix)\n");
					best_match = entry.replacement+uri.substring(entry.prefix.length);
					closest_match_length = entry.prefix.length;
			}
		}
		print(@"[try_autoprefix] best match: $best_match\n");
		return best_match;
	}
	
}

public class Dragonstone.Util.UriAutoprefixEntry {
	public string prefix;
	public string replacement;
	
	public UriAutoprefixEntry(string prefix,string replacement){
		this.prefix = prefix;
		this.replacement = replacement;
	}
}
