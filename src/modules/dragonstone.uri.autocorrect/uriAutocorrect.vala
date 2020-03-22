public class Dragonstone.Mod.UriAutocorrect.Factory : Dragonstone.ModuleFactory {
	
	construct{
		this.module_type = "dragonstone.uri.autocorrect";
		this.module_dependencies = {};
	};
	
	public abstract Dragonstone.IModule makeModule(){
		return new Dragonstone.Mod.UriAutocorrect.Module
	}
}

public class Dragonstone.Mod.UriAutocorrect.Module : Dragonstone.Module {
	
	public List<Dragonstone.Util.UriAutoprefixEntry> entrys = new List<Dragonstone.Util.UriAutoprefixEntry>();
	
	construct{
		this.module_type = "dragonstone.uri.autocorrect";
	};
	
	public abstract bool initalize(Dragonstone.ModuleRegistry registry){
		//load some defaults //TODO: break out into submodules
		add("gopher.","gopher://gopher.");
		add("gopher:","gopher://");
		add("gemini.","gemini://gemini.");
		add("gemini:","gemini://");
		add("file:","file://");
		add("/","file:///");
		add("~/","file://"+GLib.Environment.get_home_dir()+"/");
		return true;
	}
	
	public void shutdown(){
		this.on_shutdown();
	}
	
	public void add(string prefix, string replacement){
		entrys.append(new Dragonstone.Util.AutoprefixEntry(prefix, replacement));
	}
	
	public string try_autoprefix(string uri){
		print(@"[try_autoprefix] $uri\n");
		string best_match = uri;
		uint closest_match_length = 0;
		foreach(Dragonstone.Util.AutoprefixEntry entry in entrys){
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

public class Dragonstone.Mod.UriAutocorrect.AutoprefixEntry {
	public string prefix;
	public string replacement;
	
	public AutoprefixEntry(string prefix,string replacement){
		this.prefix = prefix;
		this.replacement = replacement;
	}
}
