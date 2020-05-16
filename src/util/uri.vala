public class Dragonstone.Util.Uri {
	
	public static string join(string baseuri,string relativeuri){
		if (is_absulute(relativeuri)){ //alternative: turn rel into bse and make rel empty
			return relativeuri;
		}
		//pare both uris
		var base_parsed = new ParsedUri(baseuri);
		var relative_parsed = new ParsedUri("none:"+relativeuri);
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
		string scheme = base_parsed.scheme;
		string? new_authority = base_parsed.authority;
		string? new_user_credentials = base_parsed.user_credentials;
		if (relative_starts_at_authority){
			new_authority = relative_parsed.authority;
			new_user_credentials = relative_parsed.user_credentials;
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
		string finaluri = scheme+":";
		if (new_authority != null){
			finaluri = finaluri+"//";
			if (new_user_credentials != null){
				finaluri = finaluri+new_user_credentials+"@";
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
		return finaluri;
	}
	
	public static string join_paths(string basepath,string relativepath){
		Dragonstone.Util.Stack<string> pathtokens = new Dragonstone.Util.Stack<string>();
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
				new_path = new_path+token;
			} else {
				new_path = new_path+"/"+token;
			} 
		}
		return new_path;
	}
	
	public static string naive_join(string baseuri,string relativeuri){
		if(baseuri.has_suffix("/") && relativeuri.has_prefix("/")){
			return baseuri+relativeuri.substring(1);
		}else{
			return baseuri+relativeuri;
		}
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

public class Dragonstone.Util.ParsedUri : Object {
	public string uri;
	public string? scheme = null;
	public string? authority = null;
	public string? index = null; // ..#<index>
	public string? query = null; // ..?<query>
	public string? path = null;
	public string? user_credentials = null;
	//parse authority
	public string? host = null;
	public string? port = null;
	//parse user_credentials
	public string? username = null;
	public string? password = null;
	
	//<scheme>:<path>?query#<index>
	//<scheme>://<authority>/<path>?<query>#<index>
	
	public ParsedUri(string uri, bool parse_query = true, bool parse_index = true){
		this.uri = uri;
		print("=== Parsing uri ===\n");
		print(@"URI: $uri\n");
		var index_of_hash = uri.index_of_char('#'); //end of query
		var index_of_questionmark = uri.index_of_char('?'); //end of path
		if (index_of_hash >= 0 && parse_index){
			this.index = uri.substring(index_of_hash+1);
			print(@"index: '$index'\n");
		} else {
			index_of_hash = uri.length;
		}
		if (index_of_questionmark >= 0 && parse_query){
			this.query = uri.substring(index_of_questionmark+1,index_of_hash-index_of_questionmark-1);
			print(@"query: '$query'\n");
		} else {
			index_of_questionmark = index_of_hash;
		}
		var index_of_colon = uri.index_of_char(':');
		if (index_of_colon >= 0 && index_of_colon < index_of_questionmark){
			this.scheme = uri.substring(0,index_of_colon);
			print(@"scheme: '$scheme'\n");
		} else {
			index_of_colon = 0;
		}
		string part_uri = uri.substring(index_of_colon+1,index_of_questionmark-index_of_colon-1);
		print(@"Partial uri: '$part_uri'\n");
		if (part_uri.has_prefix("//")){
			if(part_uri.length == 2){
				this.authority = "";
				part_uri = "";
			} else {
				var index_of_at = part_uri.index_of_char('@'); //start of authority
				int start_of_authority = index_of_at+1;
				if (index_of_at >= 0){
					this.user_credentials = part_uri.substring(2,index_of_at-2);
					print(@"user_credentials: '$user_credentials'\n");
				}	else {
					index_of_at = 2;
					start_of_authority = index_of_at;
				}
				var index_of_slash = part_uri.index_of_char('/',index_of_at);
				if (index_of_slash < 0){
					index_of_slash = part_uri.length;
				}
				this.authority = part_uri.substring(start_of_authority,index_of_slash-start_of_authority);
				part_uri = part_uri.substring(index_of_slash);
			}
			print(@"authority: '$authority'\n");
		}
		this.path = part_uri;
		print(@"path: '$path'\n");
		print("=== DONE ===\n");
		parse_authority();
		parse_user_credentials();
	}
	
	public void parse_authority(){
		print("=== Parsing authority ===\n");
		if (this.authority != null){
			var index_of_colon = this.authority.last_index_of_char(':');
			if (index_of_colon >= 0){
				this.host = this.authority.substring(0,index_of_colon);
				print(@"host?: '$host'\n");
				if (this.host.has_prefix("[") == this.host.has_suffix("]")){
					this.port = this.authority.substring(index_of_colon+1);
					print(@"host: '$host'\n");
					print(@"port: '$port'\n");
					return;
				}
			}
			host = this.authority;
			print(@"host: '$host'\n");
		}
		print("=== DONE ===\n");
	}
	
	public void parse_user_credentials(){
		print("=== Parsing user credentials ===\n");
		if (this.user_credentials != null){
			var index_of_colon = this.user_credentials.index_of_char(':');
			if (index_of_colon >= 0){
				this.username = this.user_credentials.substring(0,index_of_colon);
				this.password = this.user_credentials.substring(index_of_colon+1);
				print(@"username: '$username'\n");
				print(@"password: '$password'\n");
			} else {
				this.username = this.user_credentials;
				print(@"username: '$username'\n");
			}
		}
		print("=== DONE ===\n");
	}
	
	public uint16? get_port_number(){
		if (this.port != null){
			uint64 result;
			if (Dragonstone.Util.Intparser.try_parse_unsigned(this.port,out result)) {
				if (result >= 0 && result <= uint16.MAX){
					return (uint16) result;
				}
			}
		}
		return null;
	}
}
