public class Fossil.Session.Uncached : Fossil.Interface.Session, Object {
	private Fossil.Interface.ResourceStore backend;
	private string _name = "Uncached";
	
	public Uncached(Fossil.Interface.ResourceStore backend){
		this.backend = backend;
	}
	
	public Fossil.Request make_download_request(string uri, bool reload=false){
		print(@"[session.uncached] making request to $uri\n");
		var request = new Fossil.Request(uri,reload);
		backend.request(request);
		return request;
	}
	
	public Fossil.Request make_upload_request(string uri, Fossil.Resource resource, out string upload_urn = null){
		upload_urn = "urn:upload:"+GLib.Uuid.string_random();
		var request = new Fossil.Request(uri).upload(resource,upload_urn);
		backend.request(request,null,true);
		return request;
	}
	
	public bool set_default_backend(Fossil.Interface.ResourceStore store){
		backend = store;
		return true;
	}
	
	public Fossil.Interface.ResourceStore? get_default_backend(){
		return backend;
	}
	
	public void set_name(string name){ _name = name; }
	public string get_name(){ return _name; }
	
}
