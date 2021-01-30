public class Dragonstone.Session.Uncached : Dragonstone.Interface.Session, Object {
	private Dragonstone.Interface.ResourceStore backend;
	private string _name = "Uncached";
	
	public Uncached(Dragonstone.Interface.ResourceStore backend){
		this.backend = backend;
	}
	
	public Dragonstone.Request make_download_request(string uri, bool reload=false){
		print(@"[session.uncached] making request to $uri\n");
		var request = new Dragonstone.Request(uri,reload);
		backend.request(request);
		return request;
	}
	
	public Dragonstone.Request make_upload_request(string uri, Dragonstone.Resource resource, out string upload_urn = null){
		upload_urn = "urn:upload:"+GLib.Uuid.string_random();
		var request = new Dragonstone.Request(uri).upload(resource,upload_urn);
		backend.request(request,null,true);
		return request;
	}
	
	public bool set_default_backend(Dragonstone.Interface.ResourceStore store){
		backend = store;
		return true;
	}
	
	public Dragonstone.Interface.ResourceStore? get_default_backend(){
		return backend;
	}
	
	public void set_name(string name){ _name = name; }
	public string get_name(){ return _name; }
	
}
