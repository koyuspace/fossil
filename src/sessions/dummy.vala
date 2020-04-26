public class Dragonstone.Session.Dummy : Dragonstone.ISession, Object {
	private string _name = "Dummy";
	
	public Dragonstone.Request make_request(string uri, bool reload=false){
		var request = new Dragonstone.Request(uri,reload);
			request.setStatus("error/dummySession");
			return request;
	}
	
	public bool set_default_backend(Dragonstone.ResourceStore store){
		return false;
	}
	
	public Dragonstone.ResourceStore? get_default_backend(){
		return null;
	}
	
	public Dragonstone.Cache? get_cache() {
		return null;
	}
	
	public void erase_cache() {}
	
	public void set_name(string name){ _name = name; }
	public string get_name(){ return _name; }
	
}
