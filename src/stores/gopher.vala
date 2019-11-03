public class Dragonstone.GopherResourceStore : Object, ResourceStore {
	
	public void reload(string uri,Dragonstone.SessionInformation? session = null) {} //only relevent when caching is implemented
	
	public Dragonstone.Resource request(string uri,Dragonstone.SessionInformation? session = null){
	
		// parse uri
		if(!uri.has_prefix("gopher://")){
			return new Dragonstone.ResourceUriSchemeError("gopher");
		}
		var startoffset = 9;
		var indexofslash = uri.index_of_char('/',startoffset);
		var indexofcolon = uri.index_of_char(':',startoffset);
		
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
					return new Dragonstone.ResourceUriSchemeError("gopher");
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
				gophertype = uri.get_char(indexofslash+1);
			}
			if (uri.length > indexofslash+2){
				query = uri.substring(indexofslash+2);
			}
		}
		
		//debugging information
		print(@"Gopher Request:\n  Host:  $host\n  Port:  $port\n  Type:  $gophertype\n  Query: $query\n");
		var resource = new Dragonstone.GopherResource();
		var fetcher = new Dragonstone.GopherResourceFetcher(resource,host,port,query,gophertype);
		new Thread<int>(@"Gopher resource fetcher $host:$port [$gophertype|$query]",() => {
			fetcher.fetchResource();
			return 0;
		});
		return resource;
	}
	
}

private class Dragonstone.GopherResourceFetcher : Object {
	
	public string host { get; construct; }
	public uint16 port { get; construct; }
	public string query { get; construct; }
	public unichar gophertype { get; construct; }
	public Dragonstone.GopherResource resource { get; construct; }
	
	public GopherResourceFetcher(Dragonstone.GopherResource resource,string host,uint16 port,string query,unichar gophertype){
		Object(
			resource: resource,
			host: host,
			port: port,
			query: query,
			gophertype: gophertype
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
			print (@"Connecting to $host...\n");
			conn = client.connect (new InetSocketAddress (address, port));
			print (@"Connected to $host\n");
		} catch (Error e) {
			print("ERROR while connecting: "+e.message+"\n");
			resource.networkErrorConnectionRefused();
			return;
		}
		
		try {
			//send gopher request
			var message = @"$query\r\n";
			conn.output_stream.write (message.data);
			print ("Wrote request\n");
			
			// Receive response
			var input_stream = new DataInputStream (conn.input_stream);
			
			if (gophertype == '0' || gophertype == '1' || gophertype == '7'){
				// Receive text
				var str = readText(input_stream);
				if (str.validate()){
					var mimetype = "text/gopher";
					if (gophertype == '0'){
						mimetype = "text/plain";
					}
					resource.setText(str,mimetype);
					print(@"SUCCESS $(str.length)B\n");
				}else{
					resource.networkErrorGibberish();
				}
			} else if(gophertype == '9' || gophertype == 'I' || gophertype == 'g'){ 
			//gopher://g.feuerfuchs.dev/1/commissions/
			// /\ good for testing images
				try{
					var list = readBytes(input_stream);
					print(@"GOPHER BINARY $(list.length())KB\n");
					var mimetype = "application/octet-stream";
					if (gophertype == 'I'){
						mimetype = "image/";
					}
					if (query.has_suffix(".jpg") || query.has_suffix(".jpeg")){
						mimetype = "image/jpg";
					} else if (query.has_suffix(".png")){
						mimetype = "image/png";
					} else if (query.has_suffix(".gif") || gophertype == 'g'){
						mimetype = "image/gif";
					} else if (query.has_suffix(".bmp")){
						mimetype = "image/bmp";
					}
					resource.startAppendingData(mimetype);
					foreach(var bytes in list){
						resource.appendData(bytes.get_data());
					}
					resource.finishAppendingData();
				}catch(Error e){
					resource.internalError("Something with binary gopher:\n"+e.message);
				}
			} else {
				resource.gophertypeNotSupported(gophertype);
			}

		} catch (Error e) {
				resource.networkErrorGibberish();
		}
		return;
	}
	
	public string readText(DataInputStream input_stream){
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
					print("GOPHER Text file is too large (>256MB) terminating read\n");
					break;
				}
			}
		}catch (Error e){
			print("An error occourred while reding text from a connection to a gopher Server\n"+e.message+"\n");
		}
		
		print("DONE reading!\n");
		//print("result:\n");
		//print(str);
		//print("\n");
		
		return str;
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
					print("GOPHER terminating file read early, beacause file is too big (>2GB)");
					return list;
				}
			}
			return list;
	}
	
}

public class Dragonstone.GopherResource : Dragonstone.Resource, Dragonstone.IResourceData, Dragonstone.IResourceText{
	
	public List<Bytes>? data = null;
	private string? text = null;
	private unichar not_supported_gopher_type = '\0';
	
	public GopherResource (){
		Object(
			resourcetype: Dragonstone.ResourceType.LOADING,
			subtype: "",
			name: "Loading ..." //TOTRANSLATE
		);
	}
	
	public void setText(string text,string mimetype){
		this.text = text;
		this.data = new List<Bytes>();
		this.data.append(new Bytes(text.data));
		this.subtype = mimetype;
		this.resourcetype = Dragonstone.ResourceType.STATIC;
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
	
	public void internalError(string info){
		if (this.resourcetype == Dragonstone.ResourceType.ERROR_INTERNAL){ return; }
		this.subtype = info;
		this.name = "Internal Error"; //TOTRANSLATE
		this.resourcetype = Dragonstone.ResourceType.ERROR_GIBBERISH;
	}
	
	public void gophertypeNotSupported(unichar gophertype){
		this.subtype = "gopher";
		this.not_supported_gopher_type = gophertype;
		this.name = @"Gophertype $gophertype not supported"; //TOTRANSLATE
		this.resourcetype = Dragonstone.ResourceType.ERROR;
	}
	
	/*
	public void setIsSearch(){
		this.subtype = "gopher.search";
		this.name = "";
		this.resourcetype = Dragonstone.ResourceType.INTERACTIVE;
	}
	*/
	
	
	public unowned List<Bytes>? getData(){
		return data;
	}
	
	public string? getText(){
		return text;
	}
	
}
