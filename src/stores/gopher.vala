public class Dragonstone.Store.Gopher : Object, Dragonstone.ResourceStore {
	
	
	public void request(Dragonstone.Request request,string? filepath = null){
		if (filepath == null){
			request.setStatus("error/internal","Filepath required!");
			return;
		}
		// parse uri
		if(!request.uri.has_prefix("gopher://")){
			request.setStatus("error/uri/unknownScheme","Gopher only knows gopher://");
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
		
		//debugging information
		print(@"Gopher Request:\n  Host:  $host\n  Port:  $port\n  Type:  $gophertype\n  Query: $query\n");
		var resource = new Dragonstone.Resource(request.uri,filepath,true);
		var fetcher = new Dragonstone.GopherResourceFetcher(resource,request,host,port,query,gophertype);
		new Thread<int>(@"Gopher resource fetcher $host:$port [$gophertype|$query]",() => {
			fetcher.fetchResource();
			return 0;
		});
	}
}

private class Dragonstone.GopherResourceFetcher : Object {
	
	public string host { get; construct; }
	public uint16 port { get; construct; }
	public string query { get; construct; }
	public unichar gophertype { get; construct; }
	public Dragonstone.Resource resource { get; construct; }
	public Dragonstone.Request request { get; construct; }
	
	public GopherResourceFetcher(Dragonstone.Resource resource,Dragonstone.Request request,string host,uint16 port,string query,unichar gophertype){
		Object(
			resource: resource,
			request: request,
			host: host,
			port: port,
			query: query,
			gophertype: gophertype
		);
	}
	
	public void fetchResource(){
			
		request.setStatus("connecting");
		//make request
		InetAddress address;
		try {
			// Resolve hostname to IP address
			var resolver = Resolver.get_default ();
			var addresses = resolver.lookup_by_name (host, null);
			address = addresses.nth_data (0);
			print (@"[gopher] Resolved $host to $address\n");
		} catch (Error e) {
			request.setStatus("error/noHost");
			return;
		}
		
		SocketConnection conn;
		try {
			// Connect
			var client = new SocketClient ();
			print (@"[gopher] Connecting to $host...\n");
			conn = client.connect (new InetSocketAddress (address, port));
			print (@"[gopher] Connected to $host\n");
		} catch (Error e) {
			print("[gopher] ERROR while connecting: "+e.message+"\n");
			request.setStatus("error/connectionRefused");
			return;
		}
		request.setStatus("loading");
		try {
			//send gopher request
			var message = @"$query\r\n";
			conn.output_stream.write (message.data);
			print ("[gopher] Wrote request\n");
			
			// Receive response
			var input_stream = new DataInputStream (conn.input_stream);
			var helper = new Dragonstone.Util.ResourceFileWriteHelper(request,resource.filepath,0);
			
			if (gophertype == '0' || gophertype == '1' || gophertype == '7'){
				// Receive text
				var str = readText(input_stream);
				if (str.validate()){
					var mimetype = "text/gopher";
					if (gophertype == '0'){
						mimetype = "text/plain";
					}
					helper.appendString(str);
					resource.add_metadata(mimetype,@"[gopher] $host:$port | $query");
				}else{
					request.setStatus("error/gibberish");
				}
			} else if(gophertype == '9' || gophertype == 'I' || gophertype == 'g' || gophertype == 'p'){
				try{
					readBytes(input_stream,helper);
					var mimetype = "application/octet-stream";
					if (gophertype == 'I'){
						mimetype = "image/";
					}
					if (query.has_suffix(".jpg") || query.has_suffix(".jpeg")){
						mimetype = "image/jpg";
					} else if (query.has_suffix(".png") || gophertype == 'p'){
						mimetype = "image/png";
					} else if (query.has_suffix(".gif") || gophertype == 'g'){
						mimetype = "image/gif";
					} else if (query.has_suffix(".bmp")){
						mimetype = "image/bmp";
					}
					resource.add_metadata(mimetype,@"[gopher] $host:$port | $query");
				}catch(Error e){
					request.setStatus("error/internal",e.message);
					return;
				}
			} else {
				request.setStatus("error",@"Gophertype $gophertype not supported!");
				return;
			}
			if (helper.closed){return;} //error or cancelled
			helper.close();
			request.setResource(resource,"gopher");
			return;
		} catch (Error e) {
				request.setStatus("error/gibberish");
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
