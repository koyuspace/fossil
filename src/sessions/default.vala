public class Dragonstone.Session.Default : Dragonstone.ISession, Object {
	private Dragonstone.ResourceStore backend;
	private Dragonstone.Store.Cache cache = new Dragonstone.Store.Cache();
	private string _name = "Default";
	
	public Default(Dragonstone.ResourceStore backend){
		this.backend = backend;
	}
	
	public Dragonstone.Request make_download_request(string uri, bool reload=false){
		if (uri == "about:cache"){
			var request = new Dragonstone.Request(uri,reload);
			request.setStatus("interactive/cache");
			return request;
		}
		print(@"[session.default] making request to $uri\n");
		Dragonstone.Request? request = null;
		request = new Dragonstone.Request(uri,reload);
		if (!reload){
			print("[session.default] checking cache\n");
			if (cache.can_serve_request(request.uri)){
				print(@"[session.default] Serving from cache!\n");
				cache.request(request);
				return request;
			}
		}
		print("[session.default] making request to outside world\n");
		request.resource_changed.connect(reqest_reource_changed_cachehook);
		backend.request(request);
		return request;
	}
	
	public Dragonstone.Request make_upload_request(string uri, Dragonstone.Resource resource, out string upload_urn = null){
		upload_urn = "urn:upload:"+GLib.Uuid.string_random();
		var request = new Dragonstone.Request(uri).upload(resource,upload_urn);
		request.resource_changed.connect(reqest_reource_changed_cachehook);
		backend.request(request,null,true);
		return request;
	}
	
	private void reqest_reource_changed_cachehook(Dragonstone.Request outrequest){
		if (outrequest.resource != null){
			if (outrequest.resource.valid_until != 0){
				cache.put_resource(outrequest.resource);
			}
			outrequest.resource_changed.disconnect(reqest_reource_changed_cachehook);
		}
	}
	
	public bool set_default_backend(Dragonstone.ResourceStore store){
		backend = store;
		return true;
	}
	
	public Dragonstone.ResourceStore? get_default_backend(){
		return backend;
	}
	
	public Dragonstone.Cache? get_cache() {
		return cache;
	}
	
	public void erase_cache() {
		cache.erase();
	}
	
	public void set_name(string name){ _name = name; }
	public string get_name(){ return _name; }
	
}
