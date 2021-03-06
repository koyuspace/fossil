public class Fossil.Store.File : Object, Fossil.Interface.ResourceStore {
	
	public Fossil.Registry.MimetypeGuesser mimeguesser = null;
	
	
	public File(){
		mimeguesser = new Fossil.Registry.MimetypeGuesser.default_configuration();
	}
	
	public File.with_mimeguesser(Fossil.Registry.MimetypeGuesser mimeguesser){
		this.mimeguesser = mimeguesser;
	}
	
	public void request(Fossil.Request request,string? filepath = null, bool upload = false){
		if (upload){
			request.setStatus("error/noupload","Uploding not supported");
			request.finish();
			return;
		}
		string path = null;
		// parse uri
		if(request.uri.has_prefix("file://")){
			path = request.uri.slice(7,request.uri.length);
		} else if (request.uri.has_prefix("/")) {
			path = request.uri;
		} else {
			request.setStatus("error/uri/unknownScheme","File only knows file:// or /");
			request.finish();
			return;
		}
		
		if (path == ""){path = Environment.get_home_dir();}
		
		path = GLib.Uri.unescape_string(path);
		
		var file = GLib.File.new_for_path(path);
		if (!file.query_exists()){
			request.setStatus("error/resourceUnavaiable","No Such File or directory");
			request.finish();
			return;
		}
		
		var basename = file.get_basename();
		if (basename == null) {basename = request.uri;}
		
		if(FileUtils.test(path, FileTest.IS_DIR)){
			var helper = new Fossil.Util.ResourceFileWriteHelper(request,filepath,0);
			try {
				Dir dir = Dir.open (path, 0);
				string? name = null;
				helper.appendString("HOME\tfile://"+GLib.Uri.escape_string(Environment.get_home_dir(),"/")+"\n");
				helper.appendString("ROOT\tfile:///\n");
				helper.appendString("\n");
				helper.appendString("THIS\t"+path+"\n");
				var parent = file.get_parent();
				if (parent != null){
					helper.appendString("PARENT\t"+parent.get_uri()+"\n");
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
						type = "DIRECTORY";
					}
					if (!name.has_prefix(".")){
						helper.appendString(type+"\tfile://"+GLib.Uri.escape_string(fpath,"/")+"\t"+name+"\n");
					}
				}
			} catch (FileError e) {
				helper.cancel();
				request.setStatus("error/internal",e.message);
				request.finish();
			}
			if (helper.closed) { return; }
			helper.close();
			var resource = new Fossil.Resource(request.uri,filepath,true);
			resource.add_metadata("text/fossil-directory",basename);
			request.setResource(resource,"file");
			return;
		}
		
		var resource = new Fossil.Resource(request.uri,path,false);
		resource.add_metadata(mimeguesser.get_closest_match(basename,"text/plain"),basename);
		request.setResource(resource,"file");
		return;
	}
	
}
