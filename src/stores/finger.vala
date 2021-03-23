public class Fossil.Store.Finger : Object, Fossil.Interface.ResourceStore {
	
	public int32 default_resource_lifetime = 1000*60*10; //10 minutes
	public Fossil.Util.ConnectionHelper connection_helper = new Fossil.Util.ConnectionHelper();
	
	public void request(Fossil.Request request,string? filepath = null, bool upload = false){
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
		var parsed_uri = new Fossil.Util.ParsedUri(request.uri);
		
		if(!(parsed_uri.scheme == "finger" || parsed_uri.scheme == null)){
			request.setStatus("error/uri/unknownScheme","Finger only knows finger://");
			request.finish();
			return;
		}
		
		string? host = parsed_uri.host;
		if (host == "null"){
			request.setStatus("error/uri/missing_field","host");
			request.finish();
			return;
		}
		uint16? port = parsed_uri.get_port_number();
		if (port == null){
			port = 79;
		}
		string query = "";
		if(parsed_uri.username != null){
			query = parsed_uri.username;
		} else if (parsed_uri.path != null) {
			if(parsed_uri.path.length > 1){
				query = Uri.unescape_string(parsed_uri.path.substring(1),"\n\r\0");
			}
		}
		
		//debugging information
		print(@"Finger Request:\n  Host:  $host\n  Port:  $port\n  Query: $query\n");
		var resource = new Fossil.Resource(request.uri,filepath,true);
		var fetcher = new Fossil.FingerResourceFetcher(resource,request,host,port,query,"text/plain");
		new Thread<int>(@"Finger resource fetcher $host:$port [$query]",() => {
			fetcher.fetchResource(connection_helper, default_resource_lifetime);
			return 0;
		});
	}
}

private class Fossil.FingerResourceFetcher : Object {
	
	public string host { get; construct; }
	public uint16 port { get; construct; }
	public string query { get; construct; }
	public string mimetype { get; construct; }
	public Fossil.Resource resource { get; construct; }
	public Fossil.Request request { get; construct; }
	
	public FingerResourceFetcher(Fossil.Resource resource,Fossil.Request request,string host,uint16 port,string query,string mimetype){
		Object(
			resource: resource,
			request: request,
			host: host,
			port: port,
			query: query,
			mimetype: mimetype
		);
	}
	
	public void fetchResource(Fossil.Util.ConnectionHelper connection_helper, int32 default_resource_lifetime){
			
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
			var helper = new Fossil.Util.ResourceFileWriteHelper(request,resource.filepath,0);
			try{
				readBytes(input_stream,helper);
				resource.add_metadata(mimetype,@"[finger] $host:$port | $query");
			}catch(Error e){
				request.setStatus("error/internal",e.message);
				request.finish();
				return;
			}
			if (helper.closed){return;} //error or cancelled
			helper.close();
			resource.valid_until = resource.timestamp+default_resource_lifetime;
			request.setResource(resource,"finger");
			return;
		} catch (Error e) {
				request.setStatus("error/gibberish");
				request.finish();
		}
		return;
	}
	
	public void readBytes(DataInputStream input_stream,Fossil.Util.ResourceFileWriteHelper helper) throws Error{
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
