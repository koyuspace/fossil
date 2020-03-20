public class Dragonstone.Request : Object {
	//request
	public string uri { get; protected set; default = null;} //what exactly do you want?
	public string queryMetadata { get; protected set; default = null;} //here, have a cookie, or a certificate, or a preferend mimetype ...
	public bool reload { get; set; default = false; } //if the resource should not be fetched from cache
	//feedback
	public string cacheId { get; set; default = null; } //use this to request it from the cache
	public string status { get; protected set; default = "routing";} //how's it going?
	public string substatus { get; protected set; default = "";} //what?
	public string store { get; protected set; default = null;} //who processed the request?
	public Dragonstone.Resource resource { get; protected set; default = null;} //what was the result?
	
	public Request(string uri, string queryMetadata="", bool reload = false){
		this.uri = uri;
		this.queryMetadata = queryMetadata;
		this.reload = reload;
	}
	
	public void setStatus(string status, string substatus = ""){
		this.status = status;
		this.substatus = substatus;
	}
	
	public void setResource(Dragonstone.Resource resource, string store, string status = "success", string substatus = ""){
		this.resource = resource;
		this.store = store;
		this.setStatus(status,substatus);
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
	"success" - request completed, resource is not null and contains requested data
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