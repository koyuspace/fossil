public class Dragonstone.Store.Finger : Object, Dragonstone.ResourceStore {
	
	private Dragonstone.Cache? cache = null;
	public int32 default_resource_lifetime = 1000*60*10; //10 minutes
	public Dragonstone.Util.ConnectionHelper connection_helper = new Dragonstone.Util.ConnectionHelper();
	
	public void set_cache(Dragonstone.Cache? cache){
		this.cache = cache;
		print(@"Setting finger cache null:$(cache == null)\n");
	}
	
	public void request(Dragonstone.Request request,string? filepath = null){
		if (filepath == null){
			request.setStatus("error/internal","Filepath required!");
			return;
		}
		// parse uri
		var parsed_uri = new Dragonstone.Util.ParsedUri(request.uri);
		
		if(!(parsed_uri.scheme == "finger" || parsed_uri.scheme == null)){
			request.setStatus("error/uri/unknownScheme","Finger only knows finger://");
			return;
		}
		
		string? host = parsed_uri.host;
		if (host == "null"){
			request.setStatus("error/uri/noHost","Finger needs a host");
			return;
		}
		uint16? port = parsed_uri.get_port_number();
		if (port == null){
			port = 79;
		}
		string query = "";
		if(parsed_uri.username != null){
			query = parsed_uri.username;
		}
		
		//debugging information
		print(@"Finger Request:\n  Host:  $host\n  Port:  $port\n  Query: $query\n");
		var resource = new Dragonstone.Resource(request.uri,filepath,true);
		var fetcher = new Dragonstone.FingerResourceFetcher(resource,request,host,port,query,"text/plain",cache);
		new Thread<int>(@"Finger resource fetcher $host:$port [$query]",() => {
			fetcher.fetchResource(connection_helper, default_resource_lifetime);
			return 0;
		});
	}
}

private class Dragonstone.FingerResourceFetcher : Object {
	
	public string host { get; construct; }
	public uint16 port { get; construct; }
	public string query { get; construct; }
	public string mimetype { get; construct; }
	public Dragonstone.Resource resource { get; construct; }
	public Dragonstone.Request request { get; construct; }
	public Dragonstone.Cache? cache { get; construct; }
	
	public FingerResourceFetcher(Dragonstone.Resource resource,Dragonstone.Request request,string host,uint16 port,string query,string mimetype, Dragonstone.Cache? cache = null){
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
		var conn = connection_helper.connect_to_server(host,port,request,false);
		if (conn == null){ return; }
		
		request.setStatus("loading");
		try {
			//send finger request
			var message = @"$query\r\n";
			conn.output_stream.write (message.data);
			print ("[finger] Wrote request\n");
			
			// Receive response
			var input_stream = new DataInputStream (conn.input_stream);
			var helper = new Dragonstone.Util.ResourceFileWriteHelper(request,resource.filepath,0);
			try{
				readBytes(input_stream,helper);
				resource.add_metadata(mimetype,@"[finger] $host:$port | $query");
			}catch(Error e){
				request.setStatus("error/internal",e.message);
				return;
			}
			if (helper.closed){return;} //error or cancelled
			helper.close();
			resource.valid_until = resource.timestamp+default_resource_lifetime;
			request.setResource(resource,"finger");
			if (cache != null){cache.put_resource(resource);}
			return;
		} catch (Error e) {
				request.setStatus("error/gibberish");
		}
		return;
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
				if(counter > 1024*1024*100){
					print("FINGER terminating file read early, beacause file is too big (>100MB)\n");
					helper.cancel();
					return;
				}
			}
	}
	
}
