public class Dragonstone.Store.Gopher : Object, Dragonstone.ResourceStore {
	
	private Dragonstone.Registry.MimetypeGuesser mimeguesser;
	private Dragonstone.Registry.GopherTypeRegistry type_registry;
	public int32 default_resource_lifetime = 1000*60*10; //10 minutes
	public Dragonstone.Util.ConnectionHelper connection_helper = new Dragonstone.Util.ConnectionHelper();
	
	public Gopher(){
		mimeguesser = new Dragonstone.Registry.MimetypeGuesser.default_configuration();
		type_registry = new Dragonstone.Registry.GopherTypeRegistry.default_configuration();
	}
	
	public Gopher.with_mimeguesser(Dragonstone.Registry.MimetypeGuesser mimeguesser,Dragonstone.Registry.GopherTypeRegistry? type_registry = null){
		this.mimeguesser = mimeguesser;
		if (type_registry != null) {
			this.type_registry = type_registry;
		} else {
			this.type_registry = new Dragonstone.Registry.GopherTypeRegistry.default_configuration();
		}
	}
	
	public void request(Dragonstone.Request request,string? filepath = null, bool upload = false){
		if (filepath == null){
			request.setStatus("error/internal","Filepath required!");
			request.finish();
			return;
		}
		if (upload){
			request.setStatus("error/noupload","Uploding not supported");
			request.finish();
			return;
		}
		// parse uri
		var parsed_uri = new Dragonstone.Util.ParsedUri(request.uri,false);
		
		if(!(parsed_uri.scheme == "gopher" || parsed_uri.scheme == null)){
			request.setStatus("error/uri/unknownScheme","Gopher only knows gopher://");
			request.finish();
			return;
		}
		
		string query = "";
		unichar gophertype = '1'; //directory
		
		string? host = parsed_uri.host;
		if (host == null){
			request.setStatus("error/uri/missing_field","host");
			request.finish();
			return;
		}
		uint16? port = parsed_uri.get_port_number();
		if (port == null){
			port = 70;
		}
		
		if(parsed_uri.path != null){
			if(parsed_uri.path.has_prefix("/")){
				if (parsed_uri.path.length > 2){
					query = Uri.unescape_string(parsed_uri.path.substring(2),"\n\r\0");
				}
				if (parsed_uri.path.length > 1){
					gophertype = parsed_uri.path.get(1);
				}
			}
		}
		
		
		var typeinfo = type_registry.get_entry_by_gophertype(gophertype);
		if (typeinfo == null) {
			request.setStatus("error/gopher",@"Gophertype $gophertype not supported!");
			request.finish();
			return;
		}
		if (!typeinfo.uri_template.has_prefix("gopher://") || typeinfo.mimetype == null){
			request.setStatus("error/gopher",@"Gophertype $gophertype not supported!");
			request.finish();
			return;
		}
		var stripped_uri = Dragonstone.Util.Uri.strip_querys(request.uri);
		string? mimetype = typeinfo.mimetype;
		if (typeinfo.mimeyte_is_suggestion || mimetype == null) {
			mimetype = mimeguesser.get_closest_match(stripped_uri,mimetype);
		}
		
		//debugging information
		print(@"Gopher Request:\n  Host:  $host\n  Port:  $port\n  Type:  $gophertype\n  Query: $query\n");
		var resource = new Dragonstone.Resource(request.uri,filepath,true);
		var fetcher = new Dragonstone.Gopher.ResourceFetcher(resource,request,host,port,query,mimetype);
		new Thread<int>(@"Gopher resource fetcher $host:$port [$gophertype|$query]",() => {
			fetcher.fetchResource(connection_helper, default_resource_lifetime);
			return 0;
		});
	}
}

public class Dragonstone.Gopher.ResourceFetcher : Object {
	
	public string host { get; construct; }
	public uint16 port { get; construct; }
	public string query { get; construct; }
	public string mimetype { get; construct; }
	public Dragonstone.Resource resource { get; construct; }
	public Dragonstone.Request request { get; construct; }
	
	public ResourceFetcher(Dragonstone.Resource resource,Dragonstone.Request request,string host,uint16 port,string query,string mimetype){
		Object(
			resource: resource,
			request: request,
			host: host,
			port: port,
			query: query,
			mimetype: mimetype
		);
	}
	
	public void fetchResource(Dragonstone.Util.ConnectionHelper connection_helper, int32 default_resource_lifetime){
			
		request.setStatus("connecting");
		
		var conn = connection_helper.connect_to_server(host,port,request,port!=70);
		if (conn == null){
			conn = connection_helper.connect_to_server(host,port,request,false);
		}
		if (conn == null){ return; }
		
		request.setStatus("loading");
		try {
			//send gopher request
			var message = @"$query\r\n";
			conn.output_stream.write (message.data);
			print ("[gopher] Wrote request\n");
			
			// Receive response
			var input_stream = new DataInputStream (conn.input_stream);
			var helper = new Dragonstone.Util.ResourceFileWriteHelper(request,resource.filepath,0);
			
			if (mimetype.has_prefix("text/")){
				// Receive text
				var success = readText(input_stream,helper,request);
				if (success){
					resource.add_metadata(mimetype,@"[gopher] $host:$port | $query");
				} else {
					return;
				}
			} else {
				try{
					readBytes(input_stream,helper,request);
					resource.add_metadata(mimetype,@"[gopher] $host:$port | $query");
				}catch(Error e){
					request.setStatus("error/internal",e.message);
					request.finish();
					return;
				}
			}
			if (helper.closed){return;} //error or cancelled
			helper.close();
			resource.valid_until = resource.timestamp+default_resource_lifetime;
			request.setResource(resource,"gopher");
			return;
		} catch (Error e) {
				request.setStatus("error/gibberish");
				request.finish();
		}
		return;
	}
	
	public static bool readText(DataInputStream input_stream,Dragonstone.Util.ResourceFileWriteHelper helper, Dragonstone.Request request){
		uint64 counter = 0;
		
		try{
			string line;
			while (true){
				if(request.cancelled){
					helper.cancel();
					return false;
				}
				line = input_stream.read_line(null);
				if (line == null) break;
				if (line == ".") break;
				helper.appendString(line+"\n");
				counter = counter+line.length;
				if (counter > 1024*1024*256){
					print("[gopher][error] Text file is too large (>256MB) terminating read\n");
					break;
				}
			}
		}catch (Error e){
			print("[gopher][error] An error occourred while reding text from a connection to a gopher Server\n"+e.message+"\n");
			request.setStatus("error/gibberish");
			request.finish();
			return false;
		}
		
		print("[gopher] DONE reading!\n");
		//print("result:\n");
		//print(str);
		//print("\n");
		
		return true;
	}
	
	public void readBytes(DataInputStream input_stream, Dragonstone.Util.ResourceFileWriteHelper helper, Dragonstone.Request request) throws Error{
			uint64 counter = 0;
			while (true){
				if(request.cancelled){
					helper.cancel();
					return;
				}
				var bytes = input_stream.read_bytes(1024*64);
				counter += bytes.length;
				if (bytes.length == 0){
					break;
				} else {
					helper.append(Bytes.unref_to_data(bytes));
				}
				//print(@"$counter: length: $(bytes.length)\n");
				//teerminate early if file gets too big
				if(counter > 1024*1024*1024*3){
					print("GOPHER terminating file read early, beacause file is too big (>3GB)\n");
					helper.cancel();
					return;
				}
			}
	}
	
}
