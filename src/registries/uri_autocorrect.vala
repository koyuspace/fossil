public class Fossil.Registry.UriAutoprefix : Object {

	public List<Fossil.Util.UriAutoprefixEntry> entries = new List<Fossil.Util.UriAutoprefixEntry>();
	
	public void add(string prefix, string replacement){
		entries.append(new Fossil.Util.UriAutoprefixEntry(prefix, replacement));
	}
	
	public string try_autoprefix(string uri){
		//print(@"[try_autoprefix] $uri\n");
		string best_match = uri;
		uint closest_match_length = 0;
		foreach(Fossil.Util.UriAutoprefixEntry entry in entries){
			//print(@"[try_autoprefix] '$uri'.has_prefix('$(entry.prefix)') = ?\n");
			if (uri.has_prefix(entry.prefix) && entry.prefix.length > closest_match_length){
				//print(@"[try_autoprefix] match: $(entry.prefix)\n");
				best_match = entry.replacement+uri.substring(entry.prefix.length);
				closest_match_length = entry.prefix.length;
			}
		}
		//print(@"[try_autoprefix] best match: $best_match\n");
		return best_match;
	}
	
}

public class Fossil.Util.UriAutoprefixEntry {
	public string prefix;
	public string replacement;
	
	public UriAutoprefixEntry(string prefix,string replacement){
		this.prefix = prefix;
		this.replacement = replacement;
	}
}
