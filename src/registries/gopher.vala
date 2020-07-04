public class Dragonstone.Registry.GopherTypeRegistry : Object, Dragonstone.Asm.AsmObject {
	
	private HashTable<unichar,Dragonstone.Registry.GopherTypeRegistryEntry> entrys = new HashTable<unichar,Dragonstone.Registry.GopherTypeRegistryEntry>(unichar_hash, unichar_equal);
	
	public static uint unichar_hash(unichar c){
		return ((uint) c)%8192;
	}
	
	public static bool unichar_equal(unichar a, unichar b){
		return a == b;
	}
	
	public GopherTypeRegistry.default_configuration(){
		//fast
		//add(new GopherTypeRegistryEntry('i',null,".",GopherTypeRegistryContentHint.TEXT));
		exec("ADD_ENTRY","i\t*\tTEXT");
		//standardized
		exec("ADD_ENTRY","0\ttext/*");
		exec("ADD_ENTRY","1\ttext/gopher");
		exec("ADD_ENTRY","2\t*\tCCSO://{host}:{port}/{selector}");
		exec("ADD_ENTRY","3\t*\tERROR");
		exec("ADD_ENTRY","4\ttext/x-hex");
		exec("ADD_ENTRY","5\t~application/octet-stream");
		exec("ADD_ENTRY","6\t*");
		exec("ADD_ENTRY","7\ttext/gopher\tgopher://{host}:{port}/{type}{selector}%09{query}");
		exec("ADD_ENTRY","8\t*\ttelnet://{host}:{port}");
		exec("ADD_ENTRY","9\t~application/octet-stream");
		exec("ADD_ENTRY","g\timage/gif");
		exec("ADD_ENTRY","I\timage/*");
		exec("ADD_ENTRY","T\t*\ttelnet://{host}:{port}");
		/*
		add(new GopherTypeRegistryEntry('0',"text/*"));
		add(new GopherTypeRegistryEntry('1',"text/gopher"));
		add(new GopherTypeRegistryEntry('2',null,"CCSO://{host}:{port}/{selector}"));
		add(new GopherTypeRegistryEntry('3',null,".",GopherTypeRegistryContentHint.ERROR));
		add(new GopherTypeRegistryEntry('4',"text/x-hex"));
		add(new GopherTypeRegistryEntry('5',"application/octet-stream").make_mimetype_suggestion());
		add(new GopherTypeRegistryEntry('6',null));
		add(new GopherTypeRegistryEntry('7',"text/gopher",null,GopherTypeRegistryContentHint.SEARCH));
		add(new GopherTypeRegistryEntry('8',null,"telnet://{host}:{port}"));
		add(new GopherTypeRegistryEntry('9',"application/octet-stream").make_mimetype_suggestion());
		add(new GopherTypeRegistryEntry('g',"image/gif"));
		add(new GopherTypeRegistryEntry('I',"image/*"));
		add(new GopherTypeRegistryEntry('T',null,"telnet://{host}:{port}"));
		*/
		//conventions
		exec("ADD_ENTRY","h\ttext/html");
		exec("ADD_ENTRY","p\timage/png");
		exec("ADD_ENTRY","P\tapplication/pdf");
		exec("ADD_ENTRY","s\taudio/*");
		/*
		add(new GopherTypeRegistryEntry('h',"text/html"));
		add(new GopherTypeRegistryEntry('p',"image/png"));
		add(new GopherTypeRegistryEntry('P',"application/pdf"));
		add(new GopherTypeRegistryEntry('s',"audio/*"));
		*/
	}
	
	public Dragonstone.Registry.GopherTypeRegistryEntry? get_entry_by_gophertype(unichar gophertype){
		return entrys.get(gophertype);
	}
	
	public void add(Dragonstone.Registry.GopherTypeRegistryEntry entry){
		entrys.set(entry.gophertype,entry);
	}
	
	public Dragonstone.Asm.Scriptreturn? add_entry(string _gophertype, string _mimetype, string hint = ""){
		print(@"ADD_ENTRY $_gophertype $_mimetype $hint\n");
		string? uri_template = null;
		if (_gophertype.char_count() != 1){ //yes we use bytes here
			return new Dragonstone.Asm.Scriptreturn(false,@"Argument[0]: Expected a unichar got $_gophertype");
		}
		string mimetype = _mimetype;
		if (mimetype == "" || mimetype == "*"){
			mimetype = null;
		}
		unichar gophertype = _gophertype.get_char(0);
		GopherTypeRegistryContentHint content_hint = GopherTypeRegistryContentHint.LINK;
		if (hint == ""){
		} else if (hint == "LINK"){
			content_hint = GopherTypeRegistryContentHint.LINK;
		} else if (hint == "TEXT"){
			print(@"hint: TEXT $gophertype\n");
			content_hint = GopherTypeRegistryContentHint.TEXT;
			uri_template = ".";
		} else if (hint == "ERROR"){
			content_hint = GopherTypeRegistryContentHint.ERROR;
			uri_template = ".";
		} else if (hint == "SEARCH"){
			content_hint = GopherTypeRegistryContentHint.SEARCH;
		} else {
			if (hint.contains("{query}")){
				content_hint = GopherTypeRegistryContentHint.SEARCH;
			}
			uri_template = hint;
		}
		this.add(new GopherTypeRegistryEntry(gophertype,mimetype,uri_template,content_hint));
		return null;
	}
	
	// ASM integration
	public Dragonstone.Asm.Scriptreturn? asm_add_entry(string arg){
		print("ASM: ADD_ENTRY "+arg+"\n");
		var args = arg.split("\t");
		if (args.length < 2){
			return new Dragonstone.Asm.Scriptreturn.missing_argument();
		} else if (args.length == 2){
			return this.add_entry(args[0],args[1]);
		} else if (args.length == 3){
			return this.add_entry(args[0],args[1],args[2]);
		} else {
			return new Dragonstone.Asm.Scriptreturn.too_many_arguments();
		}
	}
	
	public void foreach_asm_function(Func<string> cb){
		cb("ADD_ENTRY");
	}
	public Dragonstone.Asm.Scriptreturn? exec(string method, string arg){
		if(method == "ADD_ENTRY"){return asm_add_entry(arg);}
		return new Dragonstone.Asm.Scriptreturn.unknown_function(method);
	}
	public string? get_localizable_helptext(string method){
		if(method == "ADD_ENTRY"){return "asm.help.registry.gopher_type_registry.add_entry";}
		return null;
	}
	public string? get_unlocalized_helptext(string method){
		if(method == "ADD_ENTRY"){return "ADD_ENTRY <gophertype> [~]<mimetype>[*] [<hint|uri_template>]";}
		return null;
	}
	
}

public class Dragonstone.Registry.GopherTypeRegistryEntry {
	public unichar gophertype { get; protected set; }
	public string? mimetype { get; protected set; }
	public string uri_template { get; protected set; }
	public bool mimeyte_is_suggestion { get; protected set; default = false; }
	public GopherTypeRegistryContentHint hint { get; protected set; }
	
	public GopherTypeRegistryEntry(unichar gophertype, string? mimetype = null, string? uri_template = null, GopherTypeRegistryContentHint hint = GopherTypeRegistryContentHint.LINK){
		this.gophertype = gophertype;	
		this.hint = hint;
		if (mimetype != null) {
			this.mimeyte_is_suggestion = mimetype.has_suffix("*") || mimeyte_is_suggestion;
			if (mimetype.has_prefix("~")){
				this.mimetype = mimetype.substring(1);
				this.mimeyte_is_suggestion = true;
			}	else {
				this.mimetype = mimetype;
			}
		} else {
			this.mimetype = null;
			this.mimeyte_is_suggestion = true;
		}
		if (uri_template != null){
			this.uri_template = uri_template;
		} else {
			this.uri_template = "gopher://{host}:{port}/{type}{selector}";
		}
	}
	
	public Dragonstone.Registry.GopherTypeRegistryEntry make_mimetype_suggestion(){
		this.mimeyte_is_suggestion = true;
		return this;
	}
	
	public string get_uri(string host, string port, string selector, string query = ""){
		if (selector.has_prefix("URL:")) {
			return selector.substring(4);
		}
		var uri = uri_template;
		uri = uri.replace("{host}",host);
		uri = uri.replace("{port}",port);
		uri = uri.replace("{type}",@"$gophertype");
		uri = uri.replace("{selector}",Uri.escape_string(selector,"/"));
		uri = uri.replace("{query}",Uri.escape_string(query));
		return uri;
	}
	
}

public enum Dragonstone.Registry.GopherTypeRegistryContentHint {
	TEXT,
	ERROR,
	LINK,
	SEARCH;
}
