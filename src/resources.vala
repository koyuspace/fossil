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
	
	public virtual void preload(string uri,Dragonstone.SessionInformation? session = null) {;} //should load a resource into cache
	public abstract void reload(string uri,Dragonstone.SessionInformation? session = null); //must reaload a resource
	public abstract Dragonstone.Resource request(string uri,Dragonstone.SessionInformation? session = null); //returns a resource object for the supplied uri
}

public enum Dragonstone.ResourceType {
	//a resource, that is still loading
	//subtype: reserved (empty string)
	LOADING,
	//a blob that won't change in the near future
	//subtype: mimetype
	STATIC,
	//a blob that will probably change when refetched from the server
	//subtype: mimetype
	DYNAMIC,
	//an interative resource form/upload/chat (means that an active connection to the server is required for this to be useful)
	//subtype: specified by the resource implementation (should be unique)(must be static)
	INTERACTIVE,
	//This resource redirects to another resource
	//subtype: the new uri
	REDIRECT,
	//multiple resources in one place
	CONFLICTING,
	//an error occourred while fetching the resources
	//subtype: defined by the resource implementation (should be unique)(must be static)
	ERROR,
	//client internal error
	//subtype:debug information
	ERROR_INTERNAL,
	//There is either nobody listening, or the hostname is not registred
	//subtype: hostname
	ERROR_NO_HOST,
	//the server isn't listening on the port specified
	//subtype: reserved (empty string)
	ERROR_CONNECTION_REFUSED,
	//The server does not speak the expected protocol
	//subtype: the expected protocol
	ERROR_GIBBERISH,
	//the server currently cannot serve the resource
	//subtype: reserved (empty string)
	ERROR_TEMPORARILY_UNAVAIABLE,
	//the resource is unavaiable, unknown if it ever was or will be
	//subtype: reserved (empty string)
	ERROR_UNAVAIABLE,
	//The client has a problem reaching the server
	//subtype: reserved (empty string)
	//not to be cofused with: 
	// the server rejects the connection, then the resource is unavaiable
	ERROR_OFFLINE,
	//when there is no handler for the uri scheme
	//subtype: expected uri scheme
	ERROR_URI_SCHEME_NOT_SUPPORTED,
	//server requested to start a session
	//should prompt the user (for example gemini session with authorized key,Login with username and password)
	//subtype: the type of session requested (defined by protocol handler)
	SESSION_REQUESTED,
	//server requested to end a session
	//(just don't send the session information with the requests anymore)
	//may prompt the user
	//subtype: the same as used for starting the session
	SESSION_END_REQUESTED,
	
}

public class Dragonstone.Resource : Object {
	public Dragonstone.ResourceType resourcetype { get; protected set; }
	public string subtype { get; protected set; } //specifies excactly of what type this resource is
	public bool requires_authentication { get; protected set; default = false; } //whether you have to authenticate with this resource before you can use it
	public string name { get; protected set; } //A name to display to the user
}

public class Dragonstone.SessionInformation : Object {
	private HashTable<string, Object> table = new HashTable<string, Object> (str_hash, str_equal);
	
	public void set_information(string key,Object information){
		if (table.contains(key)){
			table.remove(key);
		}
		if (information != null){
			table.set(key,information);
		}
	}
	
	//returns null if the key does not exist
	public Object get_information(string key){
		return table.get(key);
	}
	
}

///////////////////////////////////////////////////////////////////////////////
//////////////   IMPLEMENTATIONS   ///////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

public class Dragonstone.ResourceUriSchemeError : Dragonstone.Resource {
	public ResourceUriSchemeError(string scheme){
		Object(
			resourcetype: Dragonstone.ResourceType.ERROR_URI_SCHEME_NOT_SUPPORTED,
			subtype: scheme,
			name: "Schema Error" //TOTRANSLATE
		);
	}
}

public class Dragonstone.SimpeleResource : Dragonstone.Resource {
	public SimpeleResource(Dragonstone.ResourceType type,string subtype,string name){
		Object(
			resourcetype: type,
			subtype: subtype,
			name: name
		);
	}
}

public class Dragonstone.SimpeleStaticTextResource : Dragonstone.Resource , Dragonstone.IResourceText {
	public string text { get; construct; }
	public SimpeleStaticTextResource(string mimetype,string name,string text){
		Object(
			resourcetype: Dragonstone.ResourceType.STATIC,
			subtype: mimetype,
			name: name,
			text: text
		);
	}
	
	public string? getText(){
		return text;
	}
}

public class Dragonstone.ResourceRedirect : Dragonstone.Resource {
	public ResourceRedirect(string uri){
		Object(
			resourcetype: Dragonstone.ResourceType.REDIRECT,
			subtype: uri,
			name: @"Redirect to $uri" //TOTRANSLATE
		);
	}
}

public class Dragonstone.ResourceTemporaryRedirect : Dragonstone.Resource {
	public ResourceTemporaryRedirect(string uri){
		Object(
			resourcetype: Dragonstone.ResourceType.REDIRECT,
			subtype: uri,
			name: @"Redirect to $uri" //TOTRANSLATE
		);
	}
}
