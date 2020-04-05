public class Dragonstone.Store.Gopher : Object, Dragonstone.ResourceStore {
	
	private Dragonstone.Registry.MimetypeGuesser mimeguesser;
	private Dragonstone.Registry.GopherTypeRegistry type_registry;
	private Dragonstone.Cache? cache = null;
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
	
	public void set_cache(Dragonstone.Cache? cache){
		this.cache = cache;
		print(@"Setting gopher cache null:$(cache == null)\n");
	}
	
	public void request(Dragonstone.Request request,string? filepath = null){
		if (filepath == null){
			request.setStatus("error/internal","Filepath required!");
			return;
		}
		// parse uri
		if(!request.uri.has_prefix("gopher://")){
			request.setStatus("error/uri/unknownScheme","Gopher only knows gopher://");
			return;
		}
		var startoffset = 9;
		var indexofslash = request.uri.index_of_char('/',startoffset);
		var indexofcolon = request.uri.index_of_char(':',startoffset);
		
		if (indexofslash < indexofcolon && indexofslash > 1){
			indexofcolon = -1;
		}
		
		string query = "";
		uint16 port = 70;
		string host;
		unichar gophertype = '1'; //directory
		
		if (indexofcolon > 0){
			uint32 num = 0;
			uint i = indexofcolon+1;
			while(true){
				num = num*10;
				var c = request.uri.get_char(i);
				if (c == '0') {
					num += 0;
				} else if (c == '1') {
					num += 1;
				} else if (c == '2') {
					num += 2;
				} else if (c == '3') {
					num += 3;
				} else if (c == '4') {
					num += 4;
				} else if (c == '5') {
					num += 5;
				} else if (c == '6') {
					num += 6;
				} else if (c == '7') {
					num += 7;
				} else if (c == '8') {
					num += 8;
				} else if (c == '9') {
					num += 9;
				} else if (c == '/' || c == '\0') {
					break;
				} else {
					request.setStatus("error/uri/invalid","Port has to be a number");
				}
				i++;
			}
			num = num/10;
			port = (uint16) num;
		}
		
		if (indexofcolon > 0){
			host = request.uri.substring(startoffset,indexofcolon-startoffset);
		}else if (indexofslash > 0){
			host = request.uri.substring(startoffset,indexofslash-startoffset);
		}else{
			host = request.uri.substring(startoffset);
		}
	
		if (indexofslash > 0){
			if (request.uri.length > indexofslash+1){
				gophertype = request.uri.get_char(indexofslash+1);
			}
			if (request.uri.length > indexofslash+2){
				query = request.uri.substring(indexofslash+2);
			}
		}
		
		var typeinfo = type_registry.get_entry_by_gophertype(gophertype);
		if (typeinfo == null) {
			request.setStatus("error/gopher",@"Gophertype $gophertype not supported!");
		}
		var stripped_uri = Dragonstone.Util.Uri.strip_querys(request.uri);
		string mimetype = mimeguesser.get_closest_match(stripped_uri,typeinfo.mimetype);
		
		//debugging information
		print(@"Gopher Request:\n  Host:  $host\n  Port:  $port\n  Type:  $gophertype\n  Query: $query\n");
		var resource = new Dragonstone.Resource(request.uri,filepath,true);
		var fetcher = new Dragonstone.GopherResourceFetcher(resource,request,host,port,query,mimetype,cache);
		new Thread<int>(@"Gopher resource fetcher $host:$port [$gophertype|$query]",() => {
			fetcher.fetchResource(connection_helper, default_resource_lifetime);
			return 0;
		});
	}
}

private class Dragonstone.GopherResourceFetcher : Object {
	
	public string host { get; construct; }
	public uint16 port { get; construct; }
	public string query { get; construct; }
	public string mimetype { get; construct; }
	public Dragonstone.Resource resource { get; construct; }
	public Dragonstone.Request request { get; construct; }
	public Dragonstone.Cache? cache { get; construct; }
	
	public GopherResourceFetcher(Dragonstone.Resource resource,Dragonstone.Request request,string host,uint16 port,string query,string mimetype, Dragonstone.Cache? cache = null){
		Object(
			resource: resource,
			request: request,
			host: host,
			port: port,
			query: query,
			mimetype: mimetype,
			cache: cache
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
				var str = readText(input_stream);
				if (str == null){
					request.setStatus("error/gibberish");
					return;
				} else {
					helper.appendString(str);
					resource.add_metadata(mimetype,@"[gopher] $host:$port | $query");
				}
			} else {
				try{
					readBytes(input_stream,helper);
					resource.add_metadata(mimetype,@"[gopher] $host:$port | $query");
				}catch(Error e){
					request.setStatus("error/internal",e.message);
					return;
				}
			}
			if (helper.closed){return;} //error or cancelled
			helper.close();
			resource.valid_until = resource.timestamp+default_resource_lifetime;
			request.setResource(resource,"gopher");
			if (cache != null){cache.put_resource(resource);}
			return;
		} catch (Error e) {
				request.setStatus("error/gibberish");
		}
		return;
	}
	
	public string? readText(DataInputStream input_stream){
		string str = "";
		uint64 counter = 0;
		
		try{
			string line;
			while (true){
				line = input_stream.read_line(null);
				if (line == null) break;
				if (line.strip() == ".") break;
				str = str+line+"\n";
				counter = counter+line.length;
				if (counter > 1024*1024*256){
					print("[gopher][error] Text file is too large (>256MB) terminating read\n");
					break;
				}
			}
		}catch (Error e){
			print("[gopher][error] An error occourred while reding text from a connection to a gopher Server\n"+e.message+"\n");
			return null;
		}
		
		print("[gopher] DONE reading!\n");
		//print("result:\n");
		//print(str);
		//print("\n");
		
		return str;
	}
	
	public void readBytes(DataInputStream input_stream,Dragonstone.Util.ResourceFileWriteHelper helper) throws Error{
			uint64 counter = 0;
			while (true){
				if(request.cancelled){
					helper.cancel();
					return;
				}
				var bytes = input_stream.read_bytes(1024);
				counter += bytes.length;
				if (bytes.length == 0){
					break;
				} else {
					helper.append(Bytes.unref_to_data(bytes));
				}
				print(@"$counter: length: $(bytes.length)\n");
				//teerminate early if file gets too big
				if(counter > 1024*1024*1024*3){
					print("GOPHER terminating file read early, beacause file is too big (>3GB)\n");
					helper.cancel();
					return;
				}
			}
	}
	
}
