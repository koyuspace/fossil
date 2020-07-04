public class Dragonstone.Registry.MimetypeGuesser : Dragonstone.Asm.SimpleAsmObject, Dragonstone.Asm.AsmObject {
	
	public List<Dragonstone.Util.MimetypeGuesserEntry> mimetypes = new List<Dragonstone.Util.MimetypeGuesserEntry>();
	
	public MimetypeGuesser.default_configuration(){	
		initalize_asm();
		exec("ADD_TYPE",".txt\ttext/plain");
		exec("ADD_TYPE",".html\ttext/html");
		exec("ADD_TYPE",".png\timage/png");
		exec("ADD_TYPE",".jpg\timage/jpg");
		exec("ADD_TYPE",".jpeg\timage/jpg");
		exec("ADD_TYPE",".gif\timage/gif");
		exec("ADD_TYPE",".bmp\timage/bmp");
		exec("ADD_TYPE",".json\tapplication/json");
		exec("ADD_TYPE",".xml\tapplication/xml");
		exec("ADD_TYPE",".deb\tapplication/vnd.debian.binary-package");
		exec("ADD_TYPE",".tar\tapplication/tar");
		exec("ADD_TYPE",".gz\tapplication/gzip");
		exec("ADD_TYPE",".tar.gz\tapplication/tar+gzip");
		exec("ADD_TYPE",".xz\tapplication/x-xz");
		exec("ADD_TYPE",".mp3\taudio/mpeg");
		exec("ADD_TYPE",".wav\taudio/x-wav");
		
		//add_type(".txt","text/plain");
		//add_type(".html","text/html");
		//add_type(".png","image/png");
		//add_type(".jpg","image/jpg");
		//add_type(".jpeg","image/jpg");
		//add_type(".gif","image/gif");
		//add_type(".bmp","image/bmp");
		//add_type(".json","application/json");
		//add_type(".xml","application/xml");
		//add_type(".deb","application/vnd.debian.binary-package");
		//add_type(".tar","application/tar");
		//add_type(".gz","application/gzip");
		//add_type(".tar.gz","application/tar+gzip");
		//add_type(".xz","application/x-xz");
		//add_type(".mp3","audio/mpeg");
		//add_type(".wav","audio/x-wav");
	}
	
	public void add_type(string suffix,string mimetype){
		mimetypes.append(new Dragonstone.Util.MimetypeGuesserEntry(suffix,mimetype));
	}
	
	public string? get_closest_match(string uri,string? default_mimetype = null, Object? context = null){
		string best_match = default_mimetype;
		uint closest_match_length = 0;
		bool add = false;
		bool has_suffix_star = false;
		if(default_mimetype != null){
			has_suffix_star = default_mimetype.has_suffix("*");
		}
		foreach(Dragonstone.Util.MimetypeGuesserEntry entry in mimetypes){
			if (uri.ascii_down().has_suffix(entry.suffix) && entry.suffix.length > closest_match_length){
				if (has_suffix_star){
					add = entry.mimetype.has_prefix(default_mimetype[0:-1]);
				} else {
					add = true;
				}
				if (add){
					best_match = entry.mimetype;
					closest_match_length = entry.suffix.length;
				}
			}
		}
		return best_match;
	}
	
	//ASM integration
	public Dragonstone.Asm.Scriptreturn? asm_add_type(string arg){
		var parsed_args = new Dragonstone.Asm.Argparse(arg);
		if (!(parsed_args.verify_argument(0,Dragonstone.Asm.Argparse.TYPE_STRING) &&
		      parsed_args.verify_argument(1,Dragonstone.Asm.Argparse.TYPE_STRING))){
			return new Dragonstone.Asm.Scriptreturn.missing_argument();
		}
		if (!parsed_args.verify_argument(2,Dragonstone.Asm.Argparse.TYPE_NULL)){
			return new Dragonstone.Asm.Scriptreturn.too_many_arguments();
		}
		this.add_type(parsed_args.get_string(0),parsed_args.get_string(1));
		return null;
	}
	
	private void initalize_asm(){
		this.add_asm_function(new Dragonstone.Asm.FunctionDescriptor(
			this.asm_add_type,
			"ADD_TYPE",
			"asm.help.registry.gopher_type_registry.add_type",
			"ADD_TYPE <suffix> <mimetype>"
		));
	}
	
}

public class Dragonstone.Util.MimetypeGuesserEntry {
	public string suffix;
	public string mimetype;
	
	public MimetypeGuesserEntry(string suffix,string mimetype){
		this.suffix = suffix;
		this.mimetype = mimetype;
	}
}
