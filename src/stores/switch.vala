class Dragonstone.Store.Switch : Object, Dragonstone.ResourceStore {

	private List<Dragonstone.Store.SwitchEntry> stores = new List<Dragonstone.Store.SwitchEntry>();
	private string cacheDirectory = "/tmp";
	
	public Switch(string cacheDirectory){
		this.cacheDirectory = cacheDirectory;
		GLib.DirUtils.create_with_parents(this.cacheDirectory,16877);
	}
	
	public Switch.default_configuration(){
		string cachedir = GLib.Environment.get_user_cache_dir();
		this.cacheDirectory = cachedir+"/dragonstone";
		GLib.DirUtils.create_with_parents(this.cacheDirectory,16877);
		this.add_resource_store("test://",new Dragonstone.Store.Test());
		this.add_resource_store("gopher://",new Dragonstone.Store.Gopher());
		this.add_resource_store("gemini://",new Dragonstone.Store.Gemini());
		this.add_resource_store("about:",new Dragonstone.Store.About());
		var filestore = new Dragonstone.Store.File();
		this.add_resource_store("file://",filestore);
		this.add_resource_store("/",filestore);
	}
	
	public void add_resource_store(string prefix,Dragonstone.ResourceStore store){
		stores.append(new Dragonstone.Store.SwitchEntry(prefix,store));
	}
	
	public Dragonstone.ResourceStore? get_closest_match(string uri){
		Dragonstone.ResourceStore best_match = null;
		uint closest_match_length = 0;
		foreach(Dragonstone.Store.SwitchEntry entry in stores){
			if (uri.has_prefix(entry.prefix) && entry.prefix.length > closest_match_length){
				best_match = entry.store;
				closest_match_length = entry.prefix.length;
			}
		}
		return best_match;
	}
	
	public void request(Dragonstone.Request request,string? filepath = null){
		print(@"[switch] Loading uri: '$(request.uri)'\n");
		string filepathx = filepath;
		var store = get_closest_match(request.uri);
		if (filepathx == null){filepathx=this.cacheDirectory+"/"+GLib.Uuid.string_random();}
		if (store != null){store.request(request,filepathx);}
		else {
			request.setStatus("error/uri/unknownScheme");
		}
	}
	
}

private class Dragonstone.Store.SwitchEntry {
	public string prefix;
	public Dragonstone.ResourceStore store;
	
	public SwitchEntry(string prefix,Dragonstone.ResourceStore store){
		this.prefix = prefix;
		this.store = store;
	}
}
