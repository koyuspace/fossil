public class Dragonstone.Session.Dummy : Dragonstone.Interface.Session, Object {
	private string _name = "Dummy";
	
	public Dragonstone.Request make_download_request(string uri, bool reload=false){
		var request = new Dragonstone.Request(uri,reload);
		request.setStatus("error/dummySession");
		return request;
	}
	
	public Dragonstone.Request make_upload_request(string uri, Dragonstone.Resource resource, out string upload_urn = null){
		upload_urn = "urn:upload:"+GLib.Uuid.string_random();
		var request = new Dragonstone.Request(uri).upload(resource,upload_urn);;
		request.setStatus("error/dummySession");
		return request;
	}
	
	public bool set_default_backend(Dragonstone.Interface.ResourceStore store){
		return false;
	}
	
	public Dragonstone.Interface.ResourceStore? get_default_backend(){
		return null;
	}
	
	public Dragonstone.Interface.Cache? get_cache() {
		return null;
	}
	
	public void erase_cache() {}
	
	public void set_name(string name){ _name = name; }
	public string get_name(){ return _name; }
	
}
