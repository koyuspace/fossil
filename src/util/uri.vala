public class Fossil.Util.Uri {
	
	public static string join(string baseuri,string relativeuri){
		if (is_absulute(relativeuri)){ //alternative: turn rel into base and make rel empty
			return relativeuri;
		}
		//pare both uris
		//print("== Joing uri parsing base ==\n");
		var base_parsed = new ParsedUri(baseuri);
		//print("== Joing uri parsing relative ==\n");
		var relative_parsed = new ParsedUri("none:"+relativeuri);
		//print("== Joing uri done parsing ==\n");
		//analyze relative uri
		bool relative_starts_at_authority = false;
		bool relative_has_absolute_path = false;
		bool relative_specifies_path = true;
		bool relative_specifies_query = true;
		if (relativeuri.has_prefix("//")){
			relative_starts_at_authority = true;
			relative_has_absolute_path = true;
		} else if (relativeuri.has_prefix("/")){
			relative_has_absolute_path = true;
		} else if (relativeuri.has_prefix("?")){
			relative_specifies_path = false;
		} else if (relativeuri.has_prefix("#")){
			relative_specifies_path = false;
			relative_specifies_query = false;
		}
		//collect parts
		string? scheme = base_parsed.scheme;
		string? new_authority = base_parsed.authority;
		string? new_username = base_parsed.username;
		if (relative_starts_at_authority){
			new_authority = relative_parsed.authority;
			new_username = relative_parsed.username;
		}
		string path = "";
		if (relative_has_absolute_path){
			path = join_paths("",relative_parsed.path);
		} else if (relative_specifies_path){
			path = join_paths(base_parsed.path,relative_parsed.path);
		} else {
			path = base_parsed.path;
		}
		string? query = relative_parsed.query;
		if (!relative_specifies_query){
			query = base_parsed.query;
		}
		string? index = relative_parsed.index;
		//make an uri again
		string finaluri = "";
		if (scheme != null){
			finaluri = finaluri+scheme+":";
		}
		if (new_authority != null){
			finaluri = finaluri+"//";
			if (new_username != null){
				finaluri = finaluri+new_username+"@";
			}
			finaluri = finaluri+new_authority;
			if (!path.has_prefix("/")){
				path = "/"+path;
			}
		}
		finaluri = finaluri+path;
		if (query != null){
			finaluri = finaluri+"?"+query;
		}
		if (index != null){
			finaluri = finaluri+"#"+index;
		}
		//print("== Joing uri done ==\n");
		return finaluri;
	}
	
	public static string join_paths(string basepath,string relativepath){
		Fossil.Util.Stack<string> pathtokens = new Fossil.Util.Stack<string>();
		if (basepath != ""){
			foreach(string token in basepath.split("/")){
				if (token == "."){ //ignore
				} else if (token == ".."){
					pathtokens.pop();
				} else {
					pathtokens.push(token); //let's assume that this does not contain ".."
				}
			}
			pathtokens.pop();
		}
		if (relativepath != ""){
			foreach(string token in relativepath.split("/")){
				if (token == "."){ //ignore
				} else if (token == ".."){
					pathtokens.pop();
				} else {
					pathtokens.push(token); //let's assume that this does not contain ".."
				}
			}
		}
		string new_path = "";
		bool first = true;
		foreach(string token in pathtokens.list){
			if (first){
				first = false;
				new_path = token;
			} else {
				new_path = new_path+"/"+token;
			} 
		}
		if (relativepath.has_suffix("/") && !new_path.has_suffix("/")){
			new_path = new_path+"/";
		}
		return new_path;
	}
	
	public static bool is_absulute(string uri){
		var slashindex = uri.index_of_char('/');
		var colonindex = uri.index_of_char(':');
		if (slashindex > 0 && slashindex+1 < uri.length){
			return colonindex > 0 && colonindex+1==slashindex && uri[slashindex+1] == '/';
		}
		if (slashindex < 0 && colonindex >= 0){
			return true;
		}
		return false;
	}
	
	public static string strip_querys(string uri){
		unichar[] pathends = {'?','#','\t'};
		var pathend = uri.length;
		foreach(unichar end in pathends){
			var index = uri.index_of_char(end);
			if (index < pathend && index >= 0){pathend = index;}
		}
		return uri[0:pathend];
	}
	
	public static string get_filename(string uri){
		var tokens = strip_querys(uri).split("/");
		return tokens[tokens.length-1];
	}
	
	public static string get_scheme(string uri){
		var index = strip_querys(uri).index_of_char(':');
		if (index<0) { return ""; }
		return uri[0:index];
	}
	
}

public class Fossil.Util.ParsedUri : Object {
	private string? _uri = null;
	private string? _scheme = null;
	private string? _authority = null;
	private string? _index = null; // ..#<index>
	private string? _query = null; // ..?<query>
	private string? _path = null;
	private string? _username = null;
	//parse authority
	private string? _host = null;
	private string? _port = null;

	public string uri {
		get {
			//print("[parsed_uri] get uri\n");
			on_uri_get();
			return _uri;
		}
		set {
			//print("[parsed_uri] set uri\n");
			on_uri_set();
			this._uri = value;
		}
	}
	public string? scheme {
		get {
			//print("[parsed_uri] get scheme\n");
			on_uri_component_get();
			return _scheme;
		}
		set {
			//print("[parsed_uri] set scheme\n");
			on_uri_component_set();
			this._scheme = value;
		}
	}
	public string? authority {
		get {
			//print("[parsed_uri] get authority\n");
			on_authority_get();
			return _authority;
		}
		set {
			//print("[parsed_uri] set authority\n");
			on_authority_set();
			_authority = value;
		}
	}
	public string? index {
		get {
			//print("[parsed_uri] get index\n");
			on_uri_component_get();
			return _index;
		}
		set {
			//print("[parsed_uri] set index\n");
			on_uri_component_set();
			_index = value;
		}
	}
	public string? query {
		get {
			//print("[parsed_uri] get query\n");
			on_uri_component_get();
			return _query;
		}
		set {
			//print("[parsed_uri] set query\n");
			on_uri_component_set();
			_query = value;
		}
	}
	public string? path {
		get {
			//print("[parsed_uri] get path\n");
			on_uri_component_get();
			return _path;
		}
		set {
			//print("[parsed_uri] set path\n");
			on_uri_component_set();
			_path = value;
		}
	}
	public string? username {
		get {
			//print("[parsed_uri] get username\n");
			on_uri_component_get();
			return _username;
		}
		set {
			//print("[parsed_uri] set username\n");
			on_uri_component_set();
			_username = value;
		}
	}
	//parse authority
	public string? host {
		get {
			//print("[parsed_uri] get host\n");
			on_authority_component_get();
			return _host;
		}
		set {
			//print("[parsed_uri] set host\n");
			on_authority_component_set();
			_host = value;
		}
	}
	public string? port {
		get {
			//print("[parsed_uri] get port\n");
			on_authority_component_get();
			return _port;
		}
		set {
			//print("[parsed_uri] set port\n");
			on_authority_component_set();
			_port = value;
		}
	}
	
	private bool uri_modified = false;
	private bool uri_component_modified = false;
	private bool authority_component_modified = false;
	private bool authority_modified = false;
	
	private void process_authority_component_modified(){
		//print(@"authority component was modified: $authority_component_modified\n");
		if (authority_component_modified){
			update_authority();
			uri_component_modified = true;
			authority_component_modified = false;
		}
	}
	
	private void process_uri_component_modified(){
		process_authority_component_modified();
		//print(@"uri component was modified: $uri_component_modified\n");
		if (uri_component_modified){
			update_uri();
			uri_component_modified = false;
		}
	}
	
	private void process_uri_modified(){
		//print(@"uri was modified: $uri_modified (uri == null = $(_uri==null))\n");
		if (uri_modified){
			parse_uri();
			uri_modified = false;
			authority_modified = true;
		}
	}
	
	private void process_authority_modified(){
		process_uri_modified();
		//print(@"authority was modified: $authority_modified\n");
		if (authority_modified){
			parse_authority();
			authority_modified = false;
		}
	}
	
	private void on_uri_set(){
		uri_modified = true;
		authority_component_modified = false;
		uri_component_modified = false;
		authority_modified = false;
	}
	
	private void on_uri_component_set(){
		process_uri_modified();
		uri_component_modified = true;
	}
	
	private void on_authority_set(){
		on_uri_component_set();
		authority_modified = true;
	}
	
	private void on_authority_component_set(){
		process_authority_modified();
		authority_component_modified = true;
	}
	
	private void on_uri_get(){
		process_uri_component_modified();
	}
	
	private void on_uri_component_get(){
		process_uri_modified();
	}
	
	private void on_authority_get(){
		process_uri_modified();
		process_authority_component_modified();
	}
	
	private void on_authority_component_get(){
		process_authority_modified();
	}
	
	public bool parse_query = true;
	public bool parse_index = true;
	
	//<scheme>:<path>?query#<index>
	//<scheme>://<authority>/<path>?<query>#<index>
	
	public ParsedUri(string uri, bool parse_query = true, bool parse_index = true){
		this.parse_query = parse_query;
		this.parse_index = parse_index;
		this.uri = uri;
	}
	
	public ParsedUri.blank(){
		//effective nop
		//all values initalized to null
	}
	
	private void parse_uri(){
		if (this._uri == null){ return; }
		//print("=== Parsing uri ===\n");
		//print(@"URI: $_uri\n");
		var index_of_hash = _uri.index_of_char('#'); //end of query
		var index_of_questionmark = _uri.index_of_char('?'); //end of path
		if (index_of_hash >= 0 && parse_index){
			this._index = _uri.substring(index_of_hash+1);
			//print(@"index: '$_index'\n");
		} else {
			index_of_hash = _uri.length;
		}
		if (index_of_questionmark >= 0 && parse_query){
			this._query = _uri.substring(index_of_questionmark+1,index_of_hash-index_of_questionmark-1);
			//print(@"query: '$_query'\n");
		} else {
			index_of_questionmark = index_of_hash;
		}
		var index_of_colon = _uri.index_of_char(':');
		if (index_of_colon >= 0 && index_of_colon < index_of_questionmark){
			this._scheme = _uri.substring(0,index_of_colon);
			//print(@"scheme: '$_scheme'\n");
		} else {
			index_of_colon = 0;
		}
		string part_uri = _uri.substring(index_of_colon+1,index_of_questionmark-index_of_colon-1);
		//print(@"Partial uri: '$part_uri'\n");
		if (part_uri.has_prefix("//")){
			if(part_uri.length == 2){
				this._authority = "";
				part_uri = "";
			} else {
				var index_of_at = part_uri.index_of_char('@'); //start of authority
				int start_of_authority = index_of_at+1;
				if (index_of_at >= 0){
					this._username = part_uri.substring(2,index_of_at-2);
					//print(@"username: '$_username'\n");
				}	else {
					index_of_at = 2;
					start_of_authority = index_of_at;
				}
				var index_of_slash = part_uri.index_of_char('/',index_of_at);
				if (index_of_slash < 0){
					index_of_slash = part_uri.length;
				}
				this._authority = part_uri.substring(start_of_authority,index_of_slash-start_of_authority);
				part_uri = part_uri.substring(index_of_slash);
			}
			//print(@"authority: '$_authority'\n");
		}
		this._path = part_uri;
		//print(@"path: '$_path'\n");
		//print("=== DONE ===\n");
	}
	
	private void parse_authority(){
		//print("=== Parsing authority ===\n");
		if (this._authority != null){
			var index_of_colon = this._authority.last_index_of_char(':');
			if (index_of_colon >= 0){
				this._host = this._authority.substring(0,index_of_colon);
				//print(@"host?: '$_host'\n");
				if (this._host.has_prefix("[") == this._host.has_suffix("]")){
					if (this._host.has_prefix("[") /*&& this._host.has_suffix("]")*/){
						this._host = this._host.substring(1,_host.length-2);
					}
					this._port = this._authority.substring(index_of_colon+1);
					//print(@"host: '$_host'\n");
					//print(@"port: '$_port'\n");
					return;
				}
			}
			this._host = this._authority;
			if (this._host.has_prefix("[") && this._host.has_suffix("]")){
				this._host = this._host.substring(1,_host.length-2);
			}
			//print(@"host: '$_host'\n");
		}
		//print("=== DONE ===\n");
	}
	
	private void update_uri(){
		string path = _path;
		if (path == null){
			path = "";
		} else if (!_path.has_prefix("/") && _authority != null){
			_path = "/"+_path;
		}
		//what when sceme is null?
		string finaluri = "";
		string scheme = _scheme;
		if (scheme != null){
			finaluri = finaluri+scheme+":";
		}
		if (_authority != null){
			finaluri = finaluri+"//";
			if (_username != null){
				finaluri = finaluri+_username+"@";
			}
			finaluri = finaluri+_authority;
		}
		finaluri = finaluri+_path;
		if (_query != null){
			finaluri = finaluri+"?"+_query;
		}
		if (_index != null){
			finaluri = finaluri+"#"+_index;
		}
		this._uri = finaluri;
	}
	
	private void update_authority(){
		if (this._host == null){
			return;
		}
		string host = _host;
		if (host.contains(":")){
			host = @"[$host]";
		}
		if (this._port != null){
			this._authority = host+":"+_port;
		} else {
			this._authority = host;
		}
	}
	
	//resets the internal state except for the parser settings
	public void reset(){
		_uri = null;
		_scheme = null;
		_authority = null;
		_index = null; // ..#<index>
		_query = null; // ..?<query>
		_path = null;
		_username = null;
		//parse authority
		_host = null;
		_port = null;
	}
	
	public uint16? get_port_number(){
		if (this.port != null){
			uint64 result;
			if (Fossil.Util.Intparser.try_parse_unsigned(this.port,out result)) {
				if (result >= 0 && result <= uint16.MAX){
					return (uint16) result;
				}
			}
		}
		return null;
	}
}
