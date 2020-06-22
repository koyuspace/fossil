public class Dragonstone.Store.GopherWrite : Object, Dragonstone.ResourceStore {
	
	//
	
	public int32 default_resource_lifetime = 1000*60*10; //10 minutes
	public Dragonstone.Util.ConnectionHelper connection_helper = new Dragonstone.Util.ConnectionHelper();
	
	//uriformat:
	//gopher+write(t|f)://<server>[:<port>]/<encoded_selector>
	
	public void request(Dragonstone.Request request,string? filepath = null, bool upload = false){
		// parse uri
		var parsed_uri = new Dragonstone.Util.ParsedUri(request.uri,false);
		if(!(parsed_uri.scheme == "gopher+writet" || parsed_uri.scheme == "gopher+writef")){
			request.setStatus("error/uri/unknownScheme","gopherwrite only knows gopher+writet:// and gopher+writef://");
			request.finish();
			return;
		}
		if ((!upload) || request.upload_resource == null){
			if (parsed_uri.scheme == "gopher+writet"){
				request.setStatus("interactive/upload/text");
			} else {
				request.setStatus("interactive/upload");
			}
			request.finish();
			return;
		}
		
		bool upload_text = parsed_uri.scheme == "gopher+writet";
		
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
		string query = "";
		if (parsed_uri.path != null){
			if (parsed_uri.path.length > 1){
				//dont unescape tabs, as these serve as delimiters for the filesize
				query = Uri.unescape_string(parsed_uri.path.substring(1),"\t\n\r\0");
			}
		}
		string? download_resource_uri = request.upload_result_uri;
		if (download_resource_uri == null){
			request.setStatus("error/internal","the upload_result_uri was null, but the upload_resource was set");
			request.finish();
		}
		string resource_user_id = "gopherwrite_"+GLib.Uuid.string_random();
		request.upload_resource.increment_users(resource_user_id);
		var download_resource = new Dragonstone.Resource(download_resource_uri,filepath,true);
		var uploader = new Dragonstone.gopherwriteGopher.ResourceUploader(download_resource,request,host,port,query);
		new Thread<int>(@"gopherwriteGopher resource uploader $host:$port [$query]",() => {
			uploader.do_upload_resource(connection_helper, default_resource_lifetime,upload_text);
			request.upload_resource.decrement_users(resource_user_id);
			return 0;
		});
	}
}

public class Dragonstone.gopherwriteGopher.ResourceUploader : Object {
	
	public string host { get; construct; }
	public uint16 port { get; construct; }
	public string query { get; construct; }
	public Dragonstone.Resource? download_resource { get; construct; }
	public Dragonstone.Resource upload_resource { get; construct; }
	public Dragonstone.Request request { get; construct; }
	
	public ResourceUploader(Dragonstone.Resource? download_resource, Dragonstone.Request request, string host, uint16 port, string query){
		Object(
			upload_resource: request.upload_resource,
			download_resource: download_resource,
			request: request,
			host: host,
			port: port,
			query: query
		);
	}
	
	//upload_text id set to false, upload as blob
	public void do_upload_resource(Dragonstone.Util.ConnectionHelper connection_helper, int32 default_resource_lifetime, bool upload_text){
			
		request.setStatus("connecting");
		
		var conn = connection_helper.connect_to_server(host,port,request,port!=70);
		if (conn == null){
			conn = connection_helper.connect_to_server(host,port,request,false);
		}
		if (conn == null){ return; }
		
		request.setStatus("uploading");
		try {
			//determine filesize
			var file = File.new_for_path (upload_resource.filepath);
			int64? size = null;
			try {
				var fileinfo = file.query_info(GLib.FileAttribute.STANDARD_SIZE,GLib.FileQueryInfoFlags.NONE);
				size = fileinfo.get_size();
			} catch(Error e) {
				print(@"[gopherwrite][error] cannot determine filesize for $(request.resource.filepath)\n");
			}
			
			string query = this.query;
			
			if (!upload_text){
				if (size != null){
					query = query+"\t"+size.to_string("%d");
				} else {
					print("[gopherwrite][error] size is reuired for a binary upload!");
					request.setStatus("error/internal","Cannot determine filesize  $(request.resource.filepath)");
					request.finish();
					return;
				}
			}
			
			//send gopher request
			var message = @"$query\r\n";
			conn.output_stream.write (message.data);
			print ("[gopherwrite] Wrote request\n");
			
			// upload resource
			if (!file.query_exists ()) {
				request.setStatus("error/noFileToUpload");
				request.finish();
				return;
			}
			bool success = false;
			if (upload_text){
				if (size == null){size = 0;}
				success = ResourceUploader.upload_text(conn.output_stream,file,request,size);
				conn.output_stream.flush();
			}else{
				success = ResourceUploader.upload_blob(conn.output_stream,file,request,size);
			}
			if (!success){
				conn.close();
				request.finish();
				return;
			}
			if (download_resource == null){
				conn.close();
				request.setStatus("success");
				request.finish(false,true);
				return;
			}
			
			// Receive response
			request.setStatus("loading");
			var input_stream = new DataInputStream (conn.input_stream);
			var helper = new Dragonstone.Util.ResourceFileWriteHelper(request,download_resource.filepath,0);
			
			// Receive text
			success =  Dragonstone.Gopher.ResourceFetcher.readText(input_stream,helper,request);
			if (success){
				download_resource.add_metadata("text/gopher",@"[gopherwrite] $host:$port | $query");
			} else {
				request.finish(false,true);
				return;
			}
			
			if (helper.closed){return;} //error or cancelled
			helper.close();
			download_resource.valid_until = download_resource.timestamp+default_resource_lifetime;
			request.setResource(download_resource,"gopher");
			return;
		} catch (Error e) {
				request.setStatus("error/gibberish",e.message);
				request.finish();
		}
		return;
	}
	
	public static bool upload_text(OutputStream output_stream, File file, Dragonstone.Request request, int64 size){
		int64 progress = 0;
		try {
			var fileinfo = file.query_info(GLib.FileAttribute.STANDARD_SIZE,GLib.FileQueryInfoFlags.NONE);
			size = fileinfo.get_size();
			var data_input_stream = new DataInputStream (file.read());
			string line;
			while ((line = data_input_stream.read_line (null)) != null) {
				if(request.cancelled){
					output_stream.close();
					data_input_stream.close();
					request.setStatus("cancelled");
					return false;
				}
				//escape a . line by appending a space, this will not matter to most humans or parsers
				//and will ne less of an issue, than only partially uploading a file
				if (line == "."){
					line = ". ";
					size += 1;
				}
				progress += line.length;
				output_stream.write((line+"\n").data);
				request.setStatus("uploading",progress.to_string("%x")+"/"+size.to_string("%x"));
			}
			output_stream.write((".\n").data);
			output_stream.flush();
			data_input_stream.close();
			return true;
		} catch (GLib.Error e) {
				request.setStatus("error/internal","Error while reading file:\n"+e.message);
		    print("[gopherwrite][error] Error while reading file:\n"+e.message);
		    return false;
		}
	}
	
	//this assumes, that the filesize did not change, but this rarely should be an issue
	public static bool upload_blob(OutputStream output_stream, File file, Dragonstone.Request request, int64 size){
		int64 progress = 0;
		try {
			var data_input_stream = new DataInputStream (file.read ());
			while (true) {
				if(request.cancelled){
					output_stream.close();
					data_input_stream.close();
					request.setStatus("cancelled");
					return false;
				}
				var bytes = data_input_stream.read_bytes(1024*64);
				progress += bytes.length;
				if (bytes.length == 0){
					break;
				} else {
					output_stream.write(Bytes.unref_to_data(bytes));
				}
				request.setStatus("uploading",progress.to_string("%x")+"/"+size.to_string("%x"));
			}
			output_stream.flush();
			data_input_stream.close();
			return true;
		} catch (GLib.Error e) {
			request.setStatus("error/internal","Error while reading file:\n"+e.message);
		  print("[gopherwrite][error] Error while reading file:\n"+e.message);
		  return false;
		}
	}
	
}
