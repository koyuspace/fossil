public class Fossil.Session.Tls : Fossil.Interface.Session, Object {
	private Fossil.Interface.ResourceStore backend;
	private Fossil.Store.Cache cache = new Fossil.Store.Cache();
	private string _name = "Tls (experimental)";
	
	//key and certificate pems appended to reach other
	public string? tls_certificate_pems = null;
	public bool use_cache = true;
	
	public Tls(Fossil.Interface.ResourceStore backend){
		this.backend = backend;
	}
	
	public Fossil.Request make_download_request(string uri, bool reload=false){
		var request = new Fossil.Request(uri,reload);
		if (uri == "about:cache"){
			request.setStatus("interactive/cache");
			request.finish();
			return request;
		}
		if (uri == "session://"){
			request.setStatus("interactive/tls_session");
			request.finish();
			return request;
		}
		/*
		if (uri.has_prefix("session://upload_certificate_pem?")){
			var parsed_uri = new Fossil.Util.ParsedUri(uri);
			this.tls_certificate_pems = Uri.unescape_string(parsed_uri.query);
			request.setStatus("success/uploaded");
			return request;
		}
		if (uri == "session://generate_certificate"){
			var pems = Fossil.Util.TlsCertficateGenerator.generate_signed_certificate_key_pair_pem();
			if (pems != null){
				this.tls_certificate_pems = pems;
				request.setStatus("error/internal","Certificate successfully generated (not an error)");
			} else {
				request.setStatus("error/internal","Something went wrong while generating the tls certificate");
			}
			return request;
		}
		*/
		print(@"[session.tls] making request to $uri\n");
		if (this.tls_certificate_pems != null){
			request.arguments.set("tls.client.certificate",this.tls_certificate_pems);
		}
		if (!reload && use_cache){
			print("[session.tls] checking cache\n");
			if (cache.can_serve_request(request.uri)){
				print(@"[session.tls] Serving from cache!\n");
				cache.request(request);
				return request;
			}
		}
		print("[session.tls] making request to outside world\n");
		backend.request(request);
		if (use_cache){
			request.finished.connect(reqest_finished_cachehook);
		}
		return request;
	}
	
	public Fossil.Request make_upload_request(string uri, Fossil.Resource resource, out string upload_urn = null){
		upload_urn = "urn:upload:"+GLib.Uuid.string_random();
		var request = new Fossil.Request(uri).upload(resource,upload_urn);
		if (this.tls_certificate_pems != null){
			request.arguments.set("tls.client.certificate",this.tls_certificate_pems);
		}
		request.finished.connect(reqest_finished_cachehook);
		backend.request(request,null,true);
		return request;
	}
	
	//used when requestcache is diabled
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
