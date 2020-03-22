public class Dragonstone.Registry.MimetypeGuesser : Object {
	
	public List<Dragonstone.Util.MimetypeGuesserEntry> mimetypes = new List<Dragonstone.Util.MimetypeGuesserEntry>();
	
	public MimetypeGuesser.default_configuration(){
		add_type(".txt","text/plain");
		add_type(".gmi","text/gemini");
		add_type(".gemini","text/gemini");
		//add_type(".gph","text/gopher");
		add_type(".gopher","text/gopher");
		add_type(".html","text/html");
		add_type(".png","image/png");
		add_type(".jpg","image/jpg");
		add_type(".jpeg","image/jpg");
		add_type(".gif","image/gif");
		add_type(".bmp","image/bmp");
		add_type(".json","application/json");
		add_type(".xml","application/xml");
		add_type(".deb","application/vnd.debian.binary-package");
		add_type(".tar","application/tar");
		add_type(".gz","application/gzip");
		add_type(".tar.gz","application/tar+gzip");
		add_type(".xz","application/x-xz");
		add_type(".mp3","audio/mpeg");
		add_type(".wav","audio/x-wav");
	}
	
	public void add_type(string suffix,string mimetype){
		mimetypes.append(new Dragonstone.Util.MimetypeGuesserEntry(suffix,mimetype));
	}
	
	public string? get_closest_match(string uri,string? default_mimetype = null){
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
	
}

public class Dragonstone.Util.MimetypeGuesserEntry {
	public string suffix;
	public string mimetype;
	
	public MimetypeGuesserEntry(string suffix,string mimetype){
		this.suffix = suffix;
		this.mimetype = mimetype;
	}
}
