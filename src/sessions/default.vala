public class Fossil.Session.Default : Fossil.Interface.Session, Object {
	private Fossil.Interface.ResourceStore backend;
	private Fossil.Store.Cache cache = new Fossil.Store.Cache();
	private string _name = "Default";
	
	public Default(Fossil.Interface.ResourceStore backend){
		this.backend = backend;
	}
	
	public Fossil.Request make_download_request(string uri, bool reload=false){
		if (uri == "about:cache"){
			var request = new Fossil.Request(uri,reload);
			request.setStatus("interactive/cache");
			request.finish();
			return request;
		}
		print(@"[session.default] making request to $uri\n");
		Fossil.Request? request = null;
		request = new Fossil.Request(uri,reload);
		if (!reload){
			print("[session.default] checking cache\n");
			if (cache.can_serve_request(request.uri)){
				print(@"[session.default] Serving from cache!\n");
				cache.request(request);
				return request;
			}
		}
		print("[session.default] making request to outside world\n");
		request.finished.connect(reqest_finished_cachehook);
		backend.request(request);
		return request;
	}
	
	public Fossil.Request make_upload_request(string uri, Fossil.Resource resource, out string upload_urn = null){
		upload_urn = "urn:upload:"+GLib.Uuid.string_random();
		var request = new Fossil.Request(uri).upload(resource,upload_urn);
		request.finished.connect(reqest_finished_cachehook);
		backend.request(request,null,true);
		return request;
	}
	
	private void reqest_finished_cachehook(Fossil.Request outrequest){
		if (outrequest.resource != null){
			if (outrequest.resource.valid_until != 0){
				cache.put_resource(outrequest.resource);
			}
			outrequest.finished.disconnect(reqest_finished_cachehook);
		}
	}
	
	public bool set_default_backend(Fossil.Interface.ResourceStore store){
		backend = store;
		return true;
	}
	
	public Fossil.Interface.ResourceStore? get_default_backend(){
		return backend;
	}
	
	public Fossil.Interface.Cache? get_cache() {
		return cache;
	}
	
	public void erase_cache() {
		cache.erase();
	}
	
	public void set_name(string name){ _name = name; }
	public string get_name(){ return _name; }
	
}
