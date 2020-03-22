class Dragonstone.Store.Switch : Object, Dragonstone.ResourceStore {

	private string cacheDirectory = "/tmp";
	private Dragonstone.Registry.StoreRegistry storeRegistry;
	
	public Switch(string cacheDirectory,Dragonstone.Registry.StoreRegistry storeRegistry){
		this.storeRegistry = storeRegistry;
		this.cacheDirectory = cacheDirectory;
		GLib.DirUtils.create_with_parents(this.cacheDirectory,16877);
	}
	
	public Switch.default_configuration(){
		this.storeRegistry = new Dragonstone.Registry.StoreRegistry.default_configuration();
		string cachedir = GLib.Environment.get_user_cache_dir();
		this.cacheDirectory = cachedir+"/dragonstone";
		GLib.DirUtils.create_with_parents(this.cacheDirectory,16877);
	}
	
	public void request(Dragonstone.Request request,string? filepath = null){
		print(@"[switch] Loading uri: '$(request.uri)'\n");
		string filepathx = filepath;
		var store = storeRegistry.get_closest_match(request.uri);
		if (filepathx == null){filepathx=this.cacheDirectory+"/"+GLib.Uuid.string_random();}
		if (store != null){store.request(request,filepathx);}
		else {
			request.setStatus("error/uri/unknownScheme");
		}
	}
	
}
