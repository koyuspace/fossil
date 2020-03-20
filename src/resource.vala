public interface Dragonstone.ResourceStore : Object  {
	// this thing has to be able to
	// preload resources (basically put them in cache)
	// handle errors (offline,unavaiable resources,authentication required)
	// handle interactive resources (gopher searches,gemini forms,authentication)
	//  possible solution: attach a context to the query
	// save resources to a downloads directory
	// handle multiple resources at the same address
	//  provide some kind of directory with labled uris
	// retrieve a list of all cached versions with information of when they were cached
	// attach a unique identifier to all cached resources
	//  access to cached resources should be implemented using the cache://<id> uri sceme
	
	//resource querys are handled with resource objects, that have a type attached
	//views will be selected based on these types, also dynamic content can be handled quite easily with resource types
	
	public abstract void request(Dragonstone.Request request,string? filepath = null); //returns a resource object for the supplied uri
}

public class Dragonstone.Resource : Object {
	//requester
	public string uri { get; protected set; default = null;} //where did you find that one?
	public string filepath { get; protected set; default = null;} //the file, that contains the information
	//store
	public string mimetype { get; protected set; default = null;} //what does it contain?
	public int64 timestamp { get; set; default = 0;} //The unix time in milliseconds when the resource was fully loaded
	public string origin { get; protected set; default = null;} //who made it?
	public string metadata { get; protected set; default = null;} //cookies, certificates, identifiers
	public string name { get; protected set; default = "";}
	//cache
	public int64 validUntil { get; set; default = 0;} //The unix time in milliseconds when the resource is invlid in cache, do not cache if 0, valid for forever if 1
	public bool isTemporary { get; protected set; default = false;} //only for cache, if the file may be deleted
	public int users { get; protected set; default=0; } //how many systems use this resource
	
	public Resource(string uri,string filepath,bool isTemporary){
		Object(
			uri:uri,
			filepath:filepath,
			isTemporary:isTemporary
		);
	}
	
	public void increment_users(){
		print(@"[res] Users increment: URI:$(this.uri) FILEPATH:$(this.filepath)\n");
		this.users++;
	}
	
	public void decrement_users(){
		print(@"[res] Users decrement: URI:$(this.uri) FILEPATH:$(this.filepath)\n");
		this.users--;
		if (this.users <= 0 && this.isTemporary){
			var file = File.new_for_path(this.filepath);
			try{
				file.delete();
			}catch( Error e ){
				;
			}
			
			print(@"[res] Resource free: URI:$(this.uri) FILEPATH:$(this.filepath)\n");
		}
	}
	
	public void add_metadata(string mimetype, string name, string metadata=""){
		if (this.timestamp != 0){return;}
		this.mimetype = mimetype;
		this.name = name;
		this.metadata = metadata;
		this.timestamp = GLib.get_real_time();
	}
}
