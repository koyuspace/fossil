public class Dragonstone.Util.Uri {
	//Note:this function returns the relativeuri if the first ':' comes before the first '/'
	//if there is no slash and no colon the relativeuri is treated as relative
	//returns null if it can't join the two uris
	public static string? join(string baseuri,string relativeuri){
		if (is_absulute(relativeuri)){ //alternative: turn rel into bse and make rel empty
			return relativeuri;
		}
		
		print("==== joining uris ====\n");
		print(@"baseuri: $baseuri\n");
		print(@"relativeuri: $relativeuri\n");
		
		string? absolute_path = null;
		string? absolute_host = null;
		
		//detect if the relative part does not specify a scheme/protocol but is a full path
		if (relativeuri.has_prefix("//")){
			var indexofhostend = relativeuri.index_of_char('/',2);
			if (indexofhostend < 0){
				absolute_host = relativeuri;
				absolute_path = "";
			} else {
				absolute_host = relativeuri.substring(0,indexofhostend);
				absolute_path = relativeuri.substring(indexofhostend);
			}
			print("relative uri specifies an abolute host and path\n");
		} else if (relativeuri.has_prefix("/")){
			//absolute path
			absolute_path = relativeuri;
			print("relative uri specifies an absolute path\n");
		}
		
		if (absolute_path != null){
			//treat as "normal" relative uri and add the special effects at the end
			relativeuri = absolute_path;
		}
		
		//find pathends
		print("finding end of path in relative uri\n");
		unichar[] pathends = {'?','#'};
		var relpathend = relativeuri.length;
		foreach(unichar pathend in pathends){
			var index = relativeuri.index_of_char(pathend);
			if (index < relpathend && index >= 0){relpathend = index;}
		}
		var basepathend = baseuri.length; //conveniently also the length of the base path
		foreach(unichar pathend in pathends){
			var index = baseuri.index_of_char(pathend);
			if (index < basepathend && index >= 0){basepathend = index;}
		}
		//find basepath start
		print("finding start of path in base uri\n");
		var basepathstart = baseuri.index_of_char(':')+1;
		if(baseuri.substring(basepathstart).has_prefix("//")){
			basepathstart = baseuri.index_of_char('/',basepathstart+2)+1;
		}
		if(basepathstart == 0){basepathstart = baseuri.length;}
		//Note: at this point basepathstart may be 0 wich means that this is not a
		//      valid uri, but since you can assume the protocol and still treat the
		//      rest as if it was valid, this is not an issue
		print(@"  basepath = baseuri('$baseuri')[$basepathstart,$(basepathend-basepathstart)]\n");
		var basepath = baseuri.substring(basepathstart,basepathend-basepathstart);
		var baseurischemeandhost = baseuri.substring(0,basepathstart);
		print(@"  basepath: $basepath\n");
		print(@"  baseurischemeandhost: $baseurischemeandhost\n");
		print("doing some stackwork\n");
		Dragonstone.Util.Stack<string> pathtokens = new Dragonstone.Util.Stack<string>();
		//one littleexception for relative paths
		if(absolute_path == null){
			//put basepath on the stack
			print("putting tokens of the basepath on the stack\n");
			foreach(string token in basepath.split("/")){
				if (token == "."){ //ignore
				} else if (token == ".."){
					pathtokens.pop();
				} else {
					pathtokens.push(token); //let's assume that this does not contain ".."
				}
			}
			print("popping topmost token off the stack\n");
			// if the path ends in a / the empty thingy is removed, if it doesn't
			// it should replace the filename anyway (and tha topmost item in this case is the filename)
			pathtokens.pop();
		}
		print(@"putting tokens of the relativepath on the stack\n");
		foreach(string token in relativeuri.substring(0,relpathend).split("/")){
			if (token == "." || token == ""){ //ignore
			} else if (token == ".."){
				pathtokens.pop();
			} else {
				//print(@"reltoken: $token\n");
				pathtokens.push(token);
			}
		}
		print("putting uri back together\n");
		string finaluri = baseurischemeandhost;
		if (!finaluri.has_suffix("/")){
			finaluri = finaluri+"/";
		}
		if (absolute_host != null){
			print("using the relative uris host\n");
			finaluri = baseuri.substring(0,baseuri.index_of_char(':')+1)+absolute_host+"/";
		}
		print("appending the tokens from the stack\n");
		bool first = true;
		foreach(string token in pathtokens.list){
			if (first){
				first = false;
				finaluri = finaluri+token;
			} else {
				finaluri = finaluri+"/"+token;
			} 
		}
		print("testing if the relativepath ends with a /\n");
		if(relativeuri.get(relpathend-1) == '/'){
			print(" yes it does, appending a / to the final uri\n");
			finaluri = finaluri+"/";
		}
		print("appending everything, that came after the pathend in the relative uri\n");
		finaluri = finaluri+relativeuri.substring(relpathend);
		//print(@"not quite final uri: $(finaluri)\nrelpathend: $relpathend\n");
		//print(@"final uri: $(finaluri+relativeuri.substring(relpathend))\n");
		print("==== done joining uris ====\n");
		return finaluri;
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
