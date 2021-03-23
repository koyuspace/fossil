public class Fossil.Session.Dummy : Fossil.Interface.Session, Object {
	private string _name = "Dummy";
	
	public Fossil.Request make_download_request(string uri, bool reload=false){
		var request = new Fossil.Request(uri,reload);
		request.setStatus("error/dummySession");
		return request;
	}
	
	public Fossil.Request make_upload_request(string uri, Fossil.Resource resource, out string upload_urn = null){
		upload_urn = "urn:upload:"+GLib.Uuid.string_random();
		var request = new Fossil.Request(uri).upload(resource,upload_urn);;
		request.setStatus("error/dummySession");
		return request;
	}
	
	public bool set_default_backend(Fossil.Interface.ResourceStore store){
		return false;
	}
	
	public Fossil.Interface.ResourceStore? get_default_backend(){
		return null;
	}
	
	public Fossil.Interface.Cache? get_cache() {
		return null;
	}
	
	public void erase_cache() {}
	
	public void set_name(string name){ _name = name; }
	public string get_name(){ return _name; }
	
}
