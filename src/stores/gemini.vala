public class Dragonstone.Store.Gemini : Object, Dragonstone.ResourceStore {
	
	public void reload(string uri,Dragonstone.SessionInformation? session = null) {} //only relevent when caching is implemented
	
	public Dragonstone.Resource request(string uri,Dragonstone.SessionInformation? session = null){
	
		// parse uri
		if(!uri.has_prefix("gemini://")){
			return new Dragonstone.ResourceUriSchemeError("gemini");
		}
		var startoffset = 9;
		var indexofslash = uri.index_of_char('/',startoffset);
		var indexofcolon = uri.index_of_char(':',startoffset);
		
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
				var c = uri.get_char(i);
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
					return new Dragonstone.ResourceUriSchemeError("gemini");
				}
				i++;
			}
			num = num/10;
			port = (uint16) num;
		}
		
		if (indexofcolon > 0){
			host = uri.substring(startoffset,indexofcolon-startoffset);
		}else if (indexofslash > 0){
			host = uri.substring(startoffset,indexofslash-startoffset);
		}else{
			host = uri.substring(startoffset);
		}
		
		if (indexofslash > 0){
			if (uri.length > indexofslash+1){
				query = uri.substring(indexofslash+1);
			}
		}
		
		//debugging information
		print(@"Gemini Request:\n  Host:  $host\n  Port:  $port\n  Query: $query\n  Uri:   $uri\n");
		var resource = new Dragonstone.GeminiResource(uri);
		var fetcher = new Dragonstone.GeminiResourceFetcher(resource,host,port,uri);
		new Thread<int>(@"Gemini resource fetcher $host:$port [$uri]",() => {
			fetcher.fetchResource();
			return 0;
		});
		return resource;
	}
	
}

private class Dragonstone.GeminiResourceFetcher : Object {
	
	public string host { get; construct; }
	public uint16 port { get; construct; }
	//public string query { get; construct; }
	public string uri { get; construct; }
	public Dragonstone.GeminiResource resource { get; construct; }
	
	public GeminiResourceFetcher(Dragonstone.GeminiResource resource,string host,uint16 port,string uri){
		Object(
			resource: resource,
			host: host,
			port: port,
			//query: query,
			uri: uri
		);
	}
	
	public void fetchResource(){
			
		//make request
		InetAddress address;
		try {
			// Resolve hostname to IP address
			var resolver = Resolver.get_default ();
			var addresses = resolver.lookup_by_name (host, null);
			address = addresses.nth_data (0);
			print (@"Resolved $host to $address\n");
		} catch (Error e) {
			resource.networkErrorNoHost();
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
			resource.networkErrorConnectionRefused();
			return;
		}
		
		try {
			//send gemini request
			var message = @"$uri\r\n";
			conn.output_stream.write (message.data);
			print ("Wrote request\n");
			
			// Receive response
			var input_stream = new DataInputStream (conn.input_stream);
			
			try{
				var statusline = input_stream.read_line(null);
				while(statusline.has_suffix("\r") || statusline.has_suffix("\n")){
					statusline = statusline.substring(0,statusline.length-1);
				}
				print(@"< $(statusline.length) '$statusline'\n");
				var statuscode = int.parse(statusline.substring(0,2));
				var metaline = statusline.substring(3); //TODO: split on tab if the servers start including filesizes
				resource.statuscode = (uint8) statuscode;
				
				if (statuscode/10==1){
					resource.input(metaline);
				} else if (statuscode/10==2){
					var list = readBytes(input_stream);
					print(@"GEMINI BINARY $(list.length())KB\n");
					if (metaline.strip() == ""){
						metaline = "text/gemini";
					}
					resource.startAppendingData(metaline);
					foreach(var bytes in list){
						resource.appendData(bytes.get_data());
					}
					resource.finishAppendingData();
				} else if (statuscode/10==3){
					var joined_uri = Dragonstone.Util.Uri.join(uri,metaline);
					if (joined_uri == null){joined_uri = uri;}
					resource.redirect(joined_uri);
				} else if (statuscode/10==4){
					resource.temporarilyUnavaiable();
				} else if (statuscode/10==5){
					resource.permanentlyUnavaiable();
				} else if (statuscode/10==6){
					resource.sessionStart();
				} else {
					resource.invalidStatuscode();
				}
			}catch(Error e){
				resource.internalError("Something with binary gemini:\n"+e.message);
			}
			

		} catch (Error e) {
				resource.networkErrorGibberish();
		}
		return;
	}
	
	public List<Bytes> readBytes(DataInputStream input_stream) throws Error{
			List<Bytes> list = new List<Bytes>();
			uint32 counter = 0;
			while (true){
				var bytes = input_stream.read_bytes(1024);
				if (bytes.length == 0){
					break;
				} else {
					list.append(bytes);
				}
				counter++;
				print(@"$counter: length: $(bytes.length)\n");
				//teerminate early if file gets too big
				//will be replaced by special handling of big files with on-disk buffers 
				//if this becomes too much of an issue
				if(counter > 1024*1024*2){
					print("GEMINI terminating file read early, beacause file is too big (>2GB)");
					return list;
				}
			}
			return list;
	}
	
}

public class Dragonstone.GeminiResource : Dragonstone.Resource, Dragonstone.IResourceData {
	
	public List<Bytes>? data = null;
	public uint8 statuscode = 0;
	public string uri { get; construct; }
	
	public GeminiResource (string uri){
		Object(
			resourcetype: Dragonstone.ResourceType.LOADING,
			subtype: "",
			name: "Loading ...", //TOTRANSLATE
			uri: uri
		);
	}
	
	public void startAppendingData(string mimetype){
		if (this.resourcetype != Dragonstone.ResourceType.LOADING){ return; }
		this.subtype = mimetype;
		this.data = new List<Bytes>();
	}
	
	public void appendData(uint8[] data){
		if (this.resourcetype != Dragonstone.ResourceType.LOADING){ return; }
		this.data.append(new Bytes(data));
	}
	
	public void finishAppendingData(){	
		if (this.resourcetype != Dragonstone.ResourceType.LOADING){ return; }
		this.resourcetype = Dragonstone.ResourceType.STATIC;
	}
	
	public void redirect(string uri){
		if (this.resourcetype != Dragonstone.ResourceType.LOADING){ return; }
		this.subtype = uri;
		this.name = @"Redirect to $uri"; //TOTRANSLATE
		this.resourcetype = Dragonstone.ResourceType.REDIRECT;
	}
	
	public void sessionStart(){
		if (this.resourcetype != Dragonstone.ResourceType.LOADING){ return; }
		this.subtype = "gemini";
		this.name = @"Gemini Session requested ($statuscode)"; //TOTRANSLATE
		this.resourcetype = Dragonstone.ResourceType.SESSION_REQUESTED;
	}
	
	public void input(string prompt){
		if (this.resourcetype != Dragonstone.ResourceType.LOADING){ return; }
		this.subtype = "gemini/input";
		this.name = prompt;
		this.resourcetype = Dragonstone.ResourceType.DYNAMIC;
	}
	
	public void networkErrorNoHost(){
		if (this.resourcetype == Dragonstone.ResourceType.STATIC){ return; }
		this.subtype = "";
		this.name = "Error (Can not reach host)"; //TOTRANSLATE
		this.resourcetype = Dragonstone.ResourceType.ERROR_NO_HOST;
	}
	
	public void networkErrorConnectionRefused(){
		if (this.resourcetype == Dragonstone.ResourceType.STATIC){ return; }
		this.subtype = "";
		this.name = "Error (Connection Refused)"; //TOTRANSLATE
		this.resourcetype = Dragonstone.ResourceType.ERROR_CONNECTION_REFUSED;
	}
	
	public void networkErrorGibberish(){
		if (this.resourcetype == Dragonstone.ResourceType.STATIC){ return; }
		this.subtype = "";
		this.name = "Error (This is very gibberish)"; //TOTRANSLATE
		this.resourcetype = Dragonstone.ResourceType.ERROR_GIBBERISH;
	}
	
	public void invalidStatuscode(){
		if (this.resourcetype == Dragonstone.ResourceType.STATIC){ return; }
		this.subtype = "gemini";
		this.name = @"Error invalid/unknown statuscode returned by server [$statuscode]"; //TOTRANSLATE
		this.resourcetype = Dragonstone.ResourceType.ERROR;
	}
	
	public void permanentlyUnavaiable(){
		if (this.resourcetype == Dragonstone.ResourceType.STATIC){ return; }
		this.subtype = "gemini";
		this.name = "Permanently unavaiable"; //TOTRANSLATE
		this.resourcetype = Dragonstone.ResourceType.ERROR_UNAVAIABLE;
	}
	
	public void temporarilyUnavaiable(){
		if (this.resourcetype == Dragonstone.ResourceType.STATIC){ return; }
		this.subtype = "gemini";
		this.name = "Temporarily unavaiable"; //TOTRANSLATE
		this.resourcetype = Dragonstone.ResourceType.ERROR_TEMPORARILY_UNAVAIABLE;
	}
	
	public void internalError(string info){
		if (this.resourcetype == Dragonstone.ResourceType.ERROR_INTERNAL){ return; }
		this.subtype = info;
		this.name = "Internal Error"; //TOTRANSLATE
		this.resourcetype = Dragonstone.ResourceType.ERROR_GIBBERISH;
	}
	
	public unowned List<Bytes>? getData(){
		return data;
	}
	
}
