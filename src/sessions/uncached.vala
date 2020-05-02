public class Dragonstone.Session.Uncached : Dragonstone.ISession, Object {
	private Dragonstone.ResourceStore backend;
	private string _name = "Uncached";
	
	public Uncached(Dragonstone.ResourceStore backend){
		this.backend = backend;
	}
	
	public Dragonstone.Request make_request(string uri, bool reload=false){
		print(@"[session.uncached] making request to $uri\n");
		var request = new Dragonstone.Request(uri,reload);
		backend.request(request);
		return request;
	}
	
	public bool set_default_backend(Dragonstone.ResourceStore store){
		backend = store;
		return true;
	}
	
	public Dragonstone.ResourceStore? get_default_backend(){
		return backend;
	}
	
	public void set_name(string name){ _name = name; }
	public string get_name(){ return _name; }
	
}
