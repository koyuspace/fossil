public class Fossil.Store.Gemini : Object, Fossil.Interface.ResourceStore {
	
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
		
		if(!(parsed_uri.scheme == "gemini" || parsed_uri.scheme == null)){
			request.setStatus("error/uri/unknownScheme","Gemini only knows gemini://");
			request.finish();
			return;
		}
		
		if (parsed_uri.username != null){
			request.setStatus("error/uri/illegal_field","username");
			request.finish();
			return;
		}
		
		string? host = parsed_uri.host;
		if (host == null){
			request.setStatus("error/uri/missing_field","host");
			request.finish();
			return;
		}
		
		uint16? port = parsed_uri.get_port_number();
		if (port == null){
			port = 1965;
		}
		
		//debugging information
		print(@"Gemini Request:\n  Host:  $host\n  Port:  $port\n  Uri:   $(request.uri)\n");
		var resource = new Fossil.Resource(request.uri,filepath,true);
		var fetcher = new Fossil.GeminiResourceFetcher(resource,request,host,port);
		new Thread<int>(@"Gemini resource fetcher $host:$port [$(request.uri)]",() => {
			fetcher.fetchResource(connection_helper, default_resource_lifetime);
			return 0;
		});
		return;
	}
	
}

private class Fossil.GeminiResourceFetcher : Object {
	
	public string host { get; construct; }
	public uint16 port { get; construct; }
	public string uri { get; construct; }
	public Fossil.Resource resource { get; construct; }
	public Fossil.Request request { get; construct; }
	
	public GeminiResourceFetcher(Fossil.Resource resource,Fossil.Request request,string host,uint16 port){
		Object(
			resource: resource,
			request: request,
			host: host,
			port: port,
			uri: request.uri
		);
	}
	
	public void fetchResource(Fossil.Util.ConnectionHelper connection_helper, int32 default_resource_lifetime){
		
		request.setStatus("connecting");
		
		var conn = connection_helper.connect_to_server(host,port,request,true);
		if (conn == null){ return; }
		
		try {
			//send gemini request
			var message = @"$uri\r\n";
			conn.output_stream.write (message.data);
			print ("Wrote request\n");
			
			// Receive response
			var input_stream = new DataInputStream(conn.input_stream);
			request.setStatus("loading");
			
			bool beyond_header = false;
			Fossil.Util.ResourceFileWriteHelper? helper = null;

            try {
                var file_from_http = File.new_for_uri (@"https://$host/favicon.ico");
                File local_file = File.new_for_path("/tmp/fossil-favicon.ico");
                file_from_http.copy(local_file, FileCopyFlags.OVERWRITE);
                Gdk.Pixbuf pixbuf = new Gdk.Pixbuf.from_file("/tmp/fossil-favicon.ico");
                var pxb = pixbuf.scale_simple(16, 16, Gdk.InterpType.BILINEAR);
                Fossil.GtkUi.LegacyWidget.TabHead.favicon.set_from_pixbuf(pxb);
            } catch (Error e) {
                Fossil.GtkUi.LegacyWidget.TabHead.favicon.set_from_icon_name("text-x-generic", Gtk.IconSize.LARGE_TOOLBAR);
            }

			try{
				var statusline = input_stream.read_line(null);
				beyond_header = true;
				if (statusline == null){
					request.setStatus("error/gibberish","#received a null statusline");
					request.finish();
					conn.close();
					return;
				}
				while(statusline.has_suffix("\r") || statusline.has_suffix("\n")){
					statusline = statusline.substring(0,statusline.length-1);
				}
				if (statusline.length > (1024+3)){
					request.setStatus("error/gibberish","#received a too long statusline");
					request.finish();
					conn.close();
					return;
				}
				print(@"[gemini][debug] statusline: $(statusline.strip().length) '$statusline'\n");
				if (statusline.strip().length < 2){
					request.setStatus("error/gibberish","#invalid status line");
					request.finish();
					return;
				}
				var seperator = statusline.substring(2,1);
				if (!(seperator == " " || seperator == "\t")){
					request.setStatus("error/gibberish","#too long statuscode or no space after it");
					request.arguments.set("gemini.statusline",statusline);
					request.finish();
					conn.close();
					return;
				}
				
				var statuscode = int.parse(statusline.substring(0,2));
				var metaline = statusline.substring(3); //TODO: split on tab if the servers start including filesizes
				request.arguments.set("gemini.statuscode",statusline.substring(0,2));
				request.arguments.set("gemini.metaline",statusline.substring(3));
				
				if (statuscode/10==1){
					helper = new Fossil.Util.ResourceFileWriteHelper(request,resource.filepath,0);
					helper.appendString(metaline); //input prompt
					resource.add_metadata("gemini/input",metaline);
					if (helper.closed){return;} //error or cancelled
					helper.close();
					request.setResource(resource,"gemini");
				} else if (statuscode/10==2){
					if (metaline.strip() == ""){
						metaline = "text/gemini";
					}
					resource.add_metadata(metaline/*mimetype*/,@"[gemini] $uri");
					resource.valid_until = resource.timestamp+default_resource_lifetime;
					helper = new Fossil.Util.ResourceFileWriteHelper(request,resource.filepath,0);
					read_bytes(input_stream,helper,request);
					if (helper.error){
						request.finish();
						return;
					}
					helper.close();
					request.setResource(resource,"gemini");
				} else if (statuscode/10==3){
					var joined_uri = Fossil.Util.Uri.join(uri,metaline);
					if (joined_uri == null){joined_uri = uri;}
					request.setStatus("redirect/temporary",joined_uri);
					request.finish(true);
				} else if (statuscode/10==4){ //temporarely unavaiable
					request.setStatus("error/resourceUnavaiable");
					request.finish();
				} else if (statuscode/10==5){ //permanently unavaiable
					request.setStatus("error/resourceUnavaiable");
					request.finish();
				} else if (statuscode/10==6){
					request.setStatus("error/sessionRequired","tls");
					request.finish();
				} else {
					request.setStatus("error/gibberish","#invalid status code");
					request.finish();
				}
				try {
					conn.close();
				}catch(Error e){
					//do nothing
				}
			}catch(Error e){
				if (beyond_header){
					print("[gemini] rescuing data from terminated or timed out connection\n");
					helper.close();
					if (e.message == "TLS connection closed unexpectedly"){
						request.arguments.set("warning.tls.connection_got_terminated","true");
					}
					if (e.message == "Socket I/O timed out"){
						request.arguments.set("warning.connection_timed_out","true");
					}
					request.setResource(resource,"gemini");
				} else {
					if (e.message == "Socket I/O timed out"){
						request.setStatus("error/timeout");
					} else if (e.message == "TLS connection closed unexpectedly"){
						request.setStatus("error/gibberish","TLS connection closed unexpectedly");
					} else {
						request.setStatus("error/internalError","Something with gemini:\n"+e.message);
					}
					request.finish();
				}
			}
			

		} catch (Error e) {
				request.setStatus("error/gibberish");
				request.finish();
		}
		return;
	}
	
	public static void read_bytes(DataInputStream input_stream, Fossil.Util.ResourceFileWriteHelper helper, Fossil.Request request) throws Error{
		//print("[debug] readbytes start\n");
		uint64 counter = 0;
		while (true){
			if(request.cancelled){
				helper.cancel();
				//print("[debug] readbytes end (cancelled)\n");
				return;
			}
			var bytes = input_stream.read_bytes(1024*1024);
			counter += bytes.length;
			if (bytes.length == 0){
				break;
			} else {
				helper.append(Bytes.unref_to_data(bytes));
			}
			//print(@"$counter: length: $(bytes.length)\n");
			//teerminate early if file gets too big
			if(counter > 1024*1024*1024*3){
				print("[gemini] terminating file read early, beacause file is too big (>3GB)\n");
				helper.cancel();
				//print("[debug] readbytes end (too big)\n");
				return;
			}
		}
		//print("[debug] readbytes end\n");
	}
	
}
