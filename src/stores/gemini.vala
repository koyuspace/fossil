public class Dragonstone.Store.Gemini : Object, Dragonstone.ResourceStore {
	
	private Dragonstone.Cache? cache = null;
	public int32 default_resource_lifetime = 1000*60*10; //10 minutes
	
	public void set_cache(Dragonstone.Cache? cache){
		this.cache = cache;
		print(@"Setting gemini cache null:$(cache == null)\n");
	}
	
	public void request(Dragonstone.Request request,string? filepath = null){
		if (filepath == null){
			request.setStatus("error/internal","Filepath required!");
			return;
		}
		// parse uri
		if(!request.uri.has_prefix("gemini://")){
			request.setStatus("error/uri/unknownScheme","Gemini only knows gemini://");
			return;
		}
		var startoffset = 9;
		var indexofslash = request.uri.index_of_char('/',startoffset);
		var indexofcolon = request.uri.index_of_char(':',startoffset);
		
		if (indexofslash < indexofcolon && indexofslash > 1){
			indexofcolon = -1;
		}
		
		string query = "";
		uint16 port = 1965;
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
					request.setStatus("error/uri/invalid");
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
				query = request.uri.substring(indexofslash+1);
			}
		}
		
		//debugging information
		print(@"Gemini Request:\n  Host:  $host\n  Port:  $port\n  Query: $query\n  Uri:   $(request.uri)\n");
		var resource = new Dragonstone.Resource(request.uri,filepath,true);
		var fetcher = new Dragonstone.GeminiResourceFetcher(resource,request,host,port,cache);
		new Thread<int>(@"Gemini resource fetcher $host:$port [$(request.uri)]",() => {
			fetcher.fetchResource(default_resource_lifetime);
			return 0;
		});
		return;
	}
	
}

private class Dragonstone.GeminiResourceFetcher : Object {
	
	public string host { get; construct; }
	public uint16 port { get; construct; }
	//public string query { get; construct; }
	public string uri { get; construct; }
	public Dragonstone.Resource resource { get; construct; }
	public Dragonstone.Request request { get; construct; }
	public Dragonstone.Cache? cache { get; construct; }
	
	public GeminiResourceFetcher(Dragonstone.Resource resource,Dragonstone.Request request,string host,uint16 port,Dragonstone.Cache? cache = null){
		Object(
			resource: resource,
			request: request,
			host: host,
			port: port,
			//query: query,
			uri: request.uri,
			cache: cache
		);
	}
	
	public void fetchResource(int32 default_resource_lifetime){
		
		//make request
		request.setStatus("connecting");
		InetAddress address;
		try {
			// Resolve hostname to IP address
			var resolver = Resolver.get_default ();
			var addresses = resolver.lookup_by_name (host, null);
			address = addresses.nth_data (0);
			print (@"Resolved $host to $address\n");
		} catch (Error e) {
			request.setStatus("error/noHost");
			return;
		}
		
		SocketConnection conn;
		try {
			// Connect
			var client = new SocketClient ();
			client.tls = true;
      client.set_tls_validation_flags(GLib.TlsCertificateFlags.EXPIRED | GLib.TlsCertificateFlags.GENERIC_ERROR | GLib.TlsCertificateFlags.INSECURE | GLib.TlsCertificateFlags.NOT_ACTIVATED | GLib.TlsCertificateFlags.REVOKED);
			print (@"Connecting to $host...\n");
			conn = client.connect (new InetSocketAddress (address, port));
			print (@"Connected to $host\n");
		} catch (Error e) {
			print("ERROR while connecting: "+e.message+"\n");
			request.setStatus("error/connecionRefused");
			return;
		}
		
		try {
			//send gemini request
			var message = @"$uri\r\n";
			conn.output_stream.write (message.data);
			print ("Wrote request\n");
			
			// Receive response
			var input_stream = new DataInputStream (conn.input_stream);
			request.setStatus("loading");
			
			try{
				var statusline = input_stream.read_line(null);
				while(statusline.has_suffix("\r") || statusline.has_suffix("\n")){
					statusline = statusline.substring(0,statusline.length-1);
				}
				print(@"< $(statusline.strip().length) '$statusline'\n");
				if (statusline.strip().length < 2){
					request.setStatus("error/gibberish","#invalid status line");
					return;
				}
				var statuscode = int.parse(statusline.substring(0,2));
				var metaline = statusline.substring(3); //TODO: split on tab if the servers start including filesizes
				
				if (statuscode/10==1){
					var helper = new Dragonstone.Util.ResourceFileWriteHelper(request,resource.filepath,0);
					helper.appendString(metaline); //input prompt
					resource.add_metadata("gemini/input",metaline);
					if (helper.closed){return;} //error or cancelled
					helper.close();
					request.setResource(resource,"gemini");
				} else if (statuscode/10==2){
					var helper = new Dragonstone.Util.ResourceFileWriteHelper(request,resource.filepath,0);
					readBytes(input_stream,helper);
					if (metaline.strip() == ""){
						metaline = "text/gemini";
					}
					resource.add_metadata(metaline/*mimetype*/,@"[gemini] $uri");
					if (helper.error){return;}
					helper.close();
					resource.valid_until = resource.timestamp+default_resource_lifetime;
					request.setResource(resource,"gemini");
					if (cache != null){cache.put_resource(resource);}
				} else if (statuscode/10==3){
					var joined_uri = Dragonstone.Util.Uri.join(uri,metaline);
					if (joined_uri == null){joined_uri = uri;}
					request.setStatus("redirect/temporary",joined_uri);
				} else if (statuscode/10==4){ //temporarely unavaiable
					request.setStatus("error/resourceUnavaiable");
				} else if (statuscode/10==5){ //permanently unavaiable
					request.setStatus("error/resourceUnavaiable");
				} else if (statuscode/10==6){
					request.setStatus("error/sessionRequired");
				} else {
					request.setStatus("error/gibberish","#invalid status code");
				}
			}catch(Error e){
				request.setStatus("error/internalError","Something with binary gemini:\n"+e.message);
			}
			

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
				var bytes = input_stream.read_bytes(1024*10);
				counter += bytes.length;
				if (bytes.length == 0){
					break;
				} else {
					helper.append(Bytes.unref_to_data(bytes));
				}
				//print(@"$counter: length: $(bytes.length)\n");
				//teerminate early if file gets too big
				if(counter > 1024*1024*1024*3){
					print("GEMINI terminating file read early, beacause file is too big (>3GB)\n");
					helper.cancel();
					return;
				}
			}
	}
	
}
