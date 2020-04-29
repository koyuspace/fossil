public class Dragonstone.Session.Uncached : Dragonstone.ISession, Object {
	private Dragonstone.ResourceStore backend;
	private HashTable<string,Dragonstone.Request> outgoing_requests = new HashTable<string,Dragonstone.Request>(str_hash,str_equal);
	private List<Dragonstone.Request> requests = new List<Dragonstone.Request>();
	private string _name = "Uncached";
	
	public Uncached(Dragonstone.ResourceStore backend){
		this.backend = backend;
	}
	
	public Dragonstone.Request make_request(string uri, bool reload=false){
		lock (outgoing_requests) {
			print(@"[session.uncached] making request to $uri\n");
			Dragonstone.Request? request = outgoing_requests.get(uri);
			bool make_request = request == null;
			request = new Dragonstone.Request(uri,reload);
			requests.append(request);
			if (make_request){
				print("[session.uncached] making request to outside world\n");
				var outrequest = new Dragonstone.Request(uri,reload);
				outrequest.status_changed.connect(request_status_changed);
				outrequest.resource_changed.connect(reqest_reource_changed);
				outgoing_requests.set(uri,outrequest);
				backend.request(outrequest);
			}
			return request;
		}
	}
	
	private void request_status_changed(Dragonstone.Request outrequest){
		//print(@"[session.uncached] status for $(outrequest.uri) changed to $(outrequest.status)\n");
		bool remove = false;
		if (outrequest.status == "routing" || outrequest.status == "connecting" || outrequest.status == "loading"){
			//print("[session.uncached] still working\n");
		} else {
			outrequest.status_changed.disconnect(request_status_changed);
			outrequest.resource_changed.disconnect(reqest_reource_changed);
			lock (outgoing_requests) {
				outgoing_requests.remove(outrequest.uri);
			}
			remove = true;
		}
		foreach (Dragonstone.Request request in requests) {
			if (request.uri == outrequest.uri){
				//print("[session.uncached] setting status on resource\n");
				request.setStatus(outrequest.status,outrequest.substatus);
				if (remove) {
					requests.remove(request);
				}
			}
		}
	}
	
	private void reqest_reource_changed(Dragonstone.Request outrequest){
		//print(@"[session.uncached] resource for $(outrequest.uri) changed\n");
		foreach (Dragonstone.Request request in requests) {
			if (request.uri == outrequest.uri){
				request.setResource(outrequest.resource,outrequest.store,outrequest.status,outrequest.substatus);
			}
		}
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
