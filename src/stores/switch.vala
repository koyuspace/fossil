class Fossil.Store.Switch : Object, Fossil.Interface.ResourceStore {

	private string cacheDirectory = "/tmp";
	private Fossil.Registry.StoreRegistry storeRegistry;
	private Fossil.Interface.Cache? cache = null;
	//private List<Fossil.Request> hooked_requests = new Listy<Fossil.Request>();
	
	public Switch(string? cacheDirectory,Fossil.Registry.StoreRegistry storeRegistry,Fossil.Interface.Cache? cache = null){
		this.cache = cache;
		this.storeRegistry = storeRegistry;
		if (cacheDirectory != null){
			this.cacheDirectory = cacheDirectory;
			GLib.DirUtils.create_with_parents(this.cacheDirectory,16832);
		}
	}
	
	public Switch.default_configuration(){
		this.storeRegistry = new Fossil.Registry.StoreRegistry.default_configuration();
		string cachedir = GLib.Environment.get_user_cache_dir();
		this.cacheDirectory = cachedir+"/fossil";
		GLib.DirUtils.create_with_parents(this.cacheDirectory,16832);
	}
	
	public void request(Fossil.Request request,string? filepath = null, bool upload = false){
		print(@"[switch] Loading uri: '$(request.uri)'\n");
		if (cache != null && (!request.reload) && (!upload)){
			if (cache.can_serve_request(request.uri)){
				print(@"[switch] Serving from cache!\n");
				cache.request(request);
				return;
			}
		}
		load_from_store(request, filepath, upload);
	}
	
	private void load_from_store(Fossil.Request request,string? filepath = null, bool upload = false){
		var store = storeRegistry.get_closest_match(request.uri);
		if (store != null){
			string filepathx = filepath;
			if (filepathx == null){filepathx=this.cacheDirectory+"/temp_"+GLib.Uuid.string_random();}
			store.request(request,filepathx,upload);
		} else {
			request.setStatus("error/uri/unknownScheme");
			request.finish();
		}
	}
	
}
