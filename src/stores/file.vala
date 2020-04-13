public class Dragonstone.Store.File : Object, Dragonstone.ResourceStore {
	
	public Dragonstone.Registry.MimetypeGuesser mimeguesser = null;
	
	
	public File(){
		mimeguesser = new Dragonstone.Registry.MimetypeGuesser.default_configuration();
	}
	
	public File.with_mimeguesser(Dragonstone.Registry.MimetypeGuesser mimeguesser){
		this.mimeguesser = mimeguesser;
	}
	
	public void request(Dragonstone.Request request,string? filepath = null){
		
		string path = null;
		// parse uri
		if(request.uri.has_prefix("file://")){
			path = request.uri.slice(7,request.uri.length);
		} else if (request.uri.has_prefix("/")) {
			path = request.uri;
		} else {
			request.setStatus("error/uri/unknownScheme","File only knows file:// or /");
			return;
		}
		
		if (path == ""){path = Environment.get_home_dir();}
		
		path = GLib.Uri.unescape_string(path);
		
		var file = GLib.File.new_for_path(path);
		if (!file.query_exists()){
			request.setStatus("error/resourceUnavaiable","No Such File or directory");
			return;
		}
		
		var basename = file.get_basename();
		if (basename == null) {basename = request.uri;}
		
		if(FileUtils.test(path, FileTest.IS_DIR)){
			var helper = new Dragonstone.Util.ResourceFileWriteHelper(request,filepath,0);
			try {
				Dir dir = Dir.open (path, 0);
				string? name = null;
				helper.appendString("HOME\tfile://"+GLib.Uri.escape_string(Environment.get_home_dir(),"/")+"/\n");
				helper.appendString("ROOT\tfile:///\n");
				helper.appendString("\n");
				helper.appendString("THIS\t"+path+"\n");
				var parent = file.get_parent();
				if (parent != null){
					helper.appendString("PARENT\t"+parent.get_uri()+"/\n");
				}
				helper.appendString("\n");
				while ((name = dir.read_name ()) != null) {
					if (request.cancelled) {
						helper.cancel();
						break;
					}
					string fpath = Path.build_filename (path, name);
					string type = "FILE";
					if (FileUtils.test (fpath, FileTest.IS_DIR)) {
						fpath = fpath+"/";
						type = "DIRECTORY";
					}
					if (!name.has_prefix(".")){
						helper.appendString(type+"\tfile://"+GLib.Uri.escape_string(fpath,"/")+"\t"+name+"\n");
					}
				}
			} catch (FileError e) {
				helper.cancel();
				request.setStatus("error/internal",e.message);
			}
			if (helper.closed) { return; }
			helper.close();
			var resource = new Dragonstone.Resource(request.uri,filepath,true);
			resource.add_metadata("text/dragonstone-directory",basename);
			request.setResource(resource,"file");
			return;
		}
		
		var resource = new Dragonstone.Resource(request.uri,path,false);
		resource.add_metadata(mimeguesser.get_closest_match(basename,"text/plain"),basename);
		request.setResource(resource,"file");
		return;
	}
	
}
