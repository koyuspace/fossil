public class Dragonstone.Store.GeminiWrite : Object, Dragonstone.Interface.ResourceStore {
	
	public int32 default_resource_lifetime = 1000*60*30; //30 minutes
	public Dragonstone.Util.ConnectionHelper connection_helper = new Dragonstone.Util.ConnectionHelper();
	
	public void request(Dragonstone.Request request,string? filepath = null, bool upload = false){
		// parse uri
		var parsed_uri = new Dragonstone.Util.ParsedUri(request.uri,false);
		if(!(parsed_uri.scheme == "gemini+write")){
			request.setStatus("error/uri/unknownScheme","geminiwrite only knows gemini+upload://");
			request.finish();
			return;
		}
		if ((!upload) || request.upload_resource == null){
			request.setStatus("interactive/upload");
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
		
		string? download_resource_uri = request.upload_result_uri;
		if (download_resource_uri == null){
			request.setStatus("error/internal","the download_resource_uri was null, but the upload_resource was set");
			request.finish();
			return;
		}
		string resource_user_id = "geminiwrite_"+GLib.Uuid.string_random();
		request.upload_resource.increment_users(resource_user_id);
		var download_resource = new Dragonstone.Resource(download_resource_uri,filepath,true);
		var uploader = new Dragonstone.Geminiwrite.ResourceUploader(download_resource,request,host,port);
		new Thread<int>(@"geminiwrite resource uploader $host:$port [$(request.uri)]",() => {
			print("STARTED geminiwrite resource uploader\n");
			uploader.do_upload_resource(connection_helper, default_resource_lifetime);
			request.upload_resource.decrement_users(resource_user_id);
			print("STOPPED geminiwrite resource uploader\n");
			return 0;
		});
	}
}

public class Dragonstone.Geminiwrite.ResourceUploader : Object {
	
	public string host { get; construct; }
	public uint16 port { get; construct; }
	public Dragonstone.Resource? download_resource { get; construct; }
	public Dragonstone.Resource upload_resource { get; construct; }
	public Dragonstone.Request request { get; construct; }
	
	public ResourceUploader(Dragonstone.Resource? download_resource, Dragonstone.Request request, string host, uint16 port){
		Object(
			upload_resource: request.upload_resource,
			download_resource: download_resource,
			request: request,
			host: host,
			port: port
		);
	}
	
	public void do_upload_resource(Dragonstone.Util.ConnectionHelper connection_helper, int32 default_resource_lifetime){
			
		request.setStatus("connecting");
		
		var conn = connection_helper.connect_to_server(host,port,request,true);
		if (conn == null){ return; }
		
		var input_stream = new DataInputStream(conn.input_stream);
		
		request.setStatus("uploading");
		try {
			//determine filesize
			var file = File.new_for_path (upload_resource.filepath);
			int64 size;
			try {
				var fileinfo = file.query_info(GLib.FileAttribute.STANDARD_SIZE,GLib.FileQueryInfoFlags.NONE);
				size = fileinfo.get_size();
			} catch(Error e) {
				print(@"[geminiwrite][error] cannot determine filesize for $(request.resource.filepath)\n");
				request.setStatus("error/internal",@"Cannot determine filesize  $(request.resource.filepath)");
				request.finish();
				return;
			}
			
			string? mimetype = upload_resource.mimetype;
			if (mimetype == null){
				mimetype = "application/octet-stream";
			}
			
			var uri = new Dragonstone.Util.ParsedUri(request.uri);
			
			string token = "";
			if (uri.query != null){
				token = uri.query;
			}
			
			string query = Dragonstone.Util.Uri.strip_querys(request.uri)+"\n"+token+"\n"+mimetype+"\n"+size.to_string("%d")+"\n";
			
			conn.output_stream.write(query.data);
			conn.output_stream.flush();
			print ("[geminiwrite] Wrote request\n");
			
			// upload resource
			if (!file.query_exists ()) {
				request.setStatus("error/noFileToUpload");
				request.finish();
				return;
			}
			bool success = ResourceUploader.upload_blob(conn.output_stream,file,request,size);
			if (!success){
				conn.close();
				request.finish();
				return;
			}
			
		} catch(Error e) {
		}
		try {
			if (conn.is_closed()){
				request.setStatus("error/noResponse");
				request.finish();
				return;
			}
			string? statusline = cleanup_statusline(input_stream.read_line(null));
			
			if (statusline == null || statusline.strip().length < 2){
				request.setStatus("error/gibberish","#received an invalid statusline");
				request.finish();
				return;
			}
			var statuscode = int.parse(statusline.substring(0,2));
			var metaline = "";
			if (statusline.length > 3){
				metaline = statusline.substring(3);
			}
			
			print(@"[geminiwrite] received response: $statusline");
			
			request.setStatus("loading");
			
			request.arguments.set("gemini.statuscode",statusline.substring(0,2));
			request.arguments.set("gemini.metaline",metaline);
			
			if (statuscode/10==3){
				var joined_uri = Dragonstone.Util.Uri.join(request.uri,metaline);
				if (joined_uri == null){joined_uri = request.uri;}
				request.setStatus("redirect/temporary",joined_uri);
			} else if (statuscode/10==4){
				request.setStatus("success/noResource",metaline);
			} else if (statuscode/10==5){
				request.setStatus("error/Upload_failed",metaline);
				request.finish();
				return;
			} else {
				request.setStatus("error/gibberish","invalid responsecode");
				request.finish();
				return;
			}
			request.finish(true,true);
		} catch(Error e) {
			print(@"[geminiwrite][error] $(e.message)\n");
			request.setStatus("error/internal",@"Something went wrong while reading a response from a gemini+write\n$(e.message)");
			request.finish();
			return;
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
		  print("[geminiwrite][error] Error while reading file:\n"+e.message);
		  return false;
		}
	}
	
	
	public static string? cleanup_statusline(string? statusline){
		if (statusline == null){ return null; }
		string _statusline = statusline;
		while(_statusline.has_suffix("\r") || _statusline.has_suffix("\n")){
			_statusline = _statusline.substring(0,statusline.length-1);
		}
		if (_statusline.strip().length < 2){
			return null;
		}
		return _statusline;
	}
}
