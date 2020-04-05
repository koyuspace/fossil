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
		if(!request.uri.has_prefix("finger://")){
			request.setStatus("error/uri/unknownScheme","Finger only knows finger://");
			return;
		}
		var startoffset = 9;
		var indexofat = request.uri.index_of_char('@',startoffset);
		int hostoffset = startoffset;
		if(indexofat >= 0){ hostoffset = indexofat+1; }
		var indexofslash = request.uri.index_of_char('/',indexofat);
		var indexofcolon = request.uri.index_of_char(':',indexofat);
		
		if (indexofslash < indexofcolon && indexofslash > 1){
			indexofcolon = -1;
		}
		
		string query = "";
		uint16 port = 79;
		string host;
		
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
					return;
				}
				i++;
			}
			num = num/10;
			port = (uint16) num;
		}
		
		if (indexofcolon > 0){
			host = request.uri.substring(hostoffset,indexofcolon-hostoffset);
		}else if (indexofslash > 0){
			host = request.uri.substring(hostoffset,indexofslash-hostoffset);
		}else{
			host = request.uri.substring(hostoffset);
		}
	
		if (indexofat > 0){
			if (request.uri.length > indexofat+2){
				query = request.uri.substring(startoffset,indexofat-startoffset);
			}
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
		var conn = connection_helper.connect_to_server(host,port,request,true);
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
