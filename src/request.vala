public class Dragonstone.Request : Object {
	//request
	public string uri { get; protected set; default = "";} //what exactly do you want?
	public bool reload { get; protected set; default = false; } //if the resource should not be fetched from cache
	//feedback
	public string? upload_result_uri { get; protected set; default = null; } //use this to store the upload_result in cache
	public string status { get; protected set; default = "routing";} //how's it going?
	public string substatus { get; protected set; default = "";} //what?
	public string? store { get; protected set; default = null;} //who processed the request?
	public Dragonstone.Resource? resource { get; protected set; default = null;} //what was the result?
	public Dragonstone.Resource? upload_resource { get; protected set; default = null;} //what was the result?
	public signal void status_changed(Dragonstone.Request request);
	public signal void resource_changed(Dragonstone.Request request);
	//writing to this table after passing on the request will result in undefined bahaviour
	public HashTable<string,string> arguments = new HashTable<string,string>(str_hash, str_equal);
	
	
	//advanced feedback
	public bool done { get; protected set; default = false;}
	public bool cancelled { get; protected set; default = false;} //set to true to cancel download  or upload(no effect if resource was alredy fetched)
	// sucess meaning no error (redirects and intentionally empty are a sucess)
	public bool download_success { get; protected set; default = false;}
	public bool upload_success { get; protected set; default = false;}
	
	public signal void finished(Dragonstone.Request request);
	
	public Request(string uri, bool reload = false){
		this.uri = uri;
		this.reload = reload;
	}
	
	public void finish(bool download_success = false, bool upload_success = false){
		lock (done) {
			if (!done) {
				this.download_success = download_success;
				this.upload_success = upload_success;
				this.done = true;
				this.finished(this);
			}
		}
	}
	
	//turns this into an upload request
	//returns itself for chaining it onto a constructor
	public Request upload(Dragonstone.Resource upload_resource, string upload_result_uri){
		this.upload_resource = upload_resource;
		this.upload_result_uri = upload_result_uri;
		return this;
	}
	
	public void setStatus(string status, string substatus = ""){
		if (status == null || substatus == null){
			print(@"[request][error] status or substatus was attempted to be set to null (status==null=$(status==null)|substatus==null=$(substatus==null)) (status was not changed)");
			return;
		}
		bool changed = this.status != status;
		this.status = status;
		this.substatus = substatus;
		if(changed){
			status_changed(this);
		}
	}
	
	public void setResource(Dragonstone.Resource resource, string store, string status = "success", string substatus = "", bool finish = true){
		this.resource = resource;
		this.store = store;
		this.resource_changed(this);
		this.setStatus(status,substatus);
		if (finish){
			this.finish(true,this.upload_success);
		}
	}
	
	public void cancel(){
		lock (done) {
			if (!done) {
				cancelled = true;
			}
		}
	}
	
}

/*
	STATUS CODES
	"routing" - request gets routed to the appropriate store
	"connecting" - store is connecting to a remote server
	"loading" - request gets processed, file is downloading
	            substatus contains %x/%x,size downloaded,size total
	            a total size of 0 meas unknown
	            a downloaded size of 0 means unknown
	            Example: 1FB/0 ; 78/2F0 ; 0/0 ; 0/28F
	            Parsers should stop at a " " to leave space for future expansion
	"uploading" - like loading, but indicates an upload
	"success" - request completed, resource is not null and contains requested data
	"cancelled" - request was cancelled before the download finished
	"redirect/permanent" - permanent redirect, site moved, may ask user to update bookmarks etc.
	                        substatus contains new uri
	"redirect/temporary" - temporary redirect
	                       substatus contains new uris
	"error/timeout" - server took too long to respond
	"error/noHost" - server not found
	"error/connecionRefused" - connection refused
	"error/gibberish" - server does not speak the expected protocol
	"error/internal" - client internal error
	                   substatus contains debug information
	"error/resourceUnavaiable" - The resource is not avaiable
	                             substatus contains message from the server  
	"error/resourceUnavaiable/temporary" - The resource is temporarely not avaiable
	                                       substatus contains message from the server 
	"error/uri/unknownScheme" - The uri Scheme is unknown
	"error/uri/invalid" - The uri is invalid and does not follow the scheme
	"error/sessionRequired" - The server expects some authentication
	                          substatus contains the types of session, that are supported, seperated by a ";"
*/

public enum Dragonstone.RequestArgumentSeverity {
	UNKNOWN, //Use default
	IGNORE,
	WARNING,
	ERROR
}
