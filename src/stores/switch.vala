class Dragonstone.Store.Switch : Object, Dragonstone.ResourceStore {

	private string cacheDirectory = "/tmp";
	private Dragonstone.Registry.StoreRegistry storeRegistry;
	private Dragonstone.Cache? cache = null;
	//private List<Dragonstone.Request> hooked_requests = new Listy<Dragonstone.Request>();
	
	public Switch(string cacheDirectory,Dragonstone.Registry.StoreRegistry storeRegistry,Dragonstone.Cache? cache = null){
		this.cache = cache;
		this.storeRegistry = storeRegistry;
		this.cacheDirectory = cacheDirectory;
		GLib.DirUtils.create_with_parents(this.cacheDirectory,16832);
	}
	
	public Switch.default_configuration(){
		this.storeRegistry = new Dragonstone.Registry.StoreRegistry.default_configuration();
		string cachedir = GLib.Environment.get_user_cache_dir();
		this.cacheDirectory = cachedir+"/dragonstone";
		GLib.DirUtils.create_with_parents(this.cacheDirectory,16832);
	}
	
	public void request(Dragonstone.Request request,string? filepath = null){
		print(@"[switch] Loading uri: '$(request.uri)'\n");
		if (cache != null && (!request.reload)){
			if (cache.can_serve_request(request.uri)){
				print(@"[switch] Serving from cache!\n");
				cache.request(request);
				return;
			}
		}
		load_from_store(request);
	}
	
	private void load_from_store(Dragonstone.Request request,string? filepath = null){
		string filepathx = filepath;
		var store = storeRegistry.get_closest_match(request.uri);
		if (filepathx == null){filepathx=this.cacheDirectory+"/temp_"+GLib.Uuid.string_random();}
		if (store != null){store.request(request,filepathx);}
		else {
			request.setStatus("error/uri/unknownScheme");
		}
	}
	
}
