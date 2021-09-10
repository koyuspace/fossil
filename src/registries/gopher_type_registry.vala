public class Fossil.Registry.GopherTypeRegistry : Fossil.Asm.SimpleAsmObject, Fossil.Asm.AsmObject {
	
	private HashTable<unichar,Fossil.Registry.GopherTypeRegistryEntry> entries = new HashTable<unichar,Fossil.Registry.GopherTypeRegistryEntry>(unichar_hash, unichar_equal);
	
	public static uint unichar_hash(unichar c){
		return ((uint) c)%8192;
	}
	
	public static bool unichar_equal(unichar a, unichar b){
		return a == b;
	}
	
	public GopherTypeRegistry.default_configuration(){
		initialize_asm();
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
		exec("ADD_ENTRY","7\ttext/gopher\tgopher://{host}:{port}/{type}{selector}%09{search}");
		exec("ADD_ENTRY","8\t*\ttelnet://{host}:{port}");
		exec("ADD_ENTRY","9\t~application/octet-stream");
		exec("ADD_ENTRY","g\timage/gif");
		exec("ADD_ENTRY","I\timage/*");
		exec("ADD_ENTRY","T\t*\ttelnet://{host}:{port}");
		add(new GopherTypeRegistryEntry('0',"text/*"));
		add(new GopherTypeRegistryEntry('1',"text/gopher"));
		add(new GopherTypeRegistryEntry('2',null,"CCSO://{host}:{port}/{selector}"));
		add(new GopherTypeRegistryEntry('3',null,".",GopherTypeRegistryContentHint.ERROR));
		add(new GopherTypeRegistryEntry('4',"text/x-hex"));
		add(new GopherTypeRegistryEntry('5',"application/octet-stream").make_mimetype_suggestion());
		add(new GopherTypeRegistryEntry('6',null));
		add(new GopherTypeRegistryEntry('7',"text/gopher","gopher://{host}:{port}/{type}{selector}%09{search}",GopherTypeRegistryContentHint.SEARCH));
		add(new GopherTypeRegistryEntry('8',null,"telnet://{host}:{port}"));
		add(new GopherTypeRegistryEntry('9',"application/octet-stream").make_mimetype_suggestion());
		add(new GopherTypeRegistryEntry('g',"image/gif"));
		add(new GopherTypeRegistryEntry('I',"image/*"));
		add(new GopherTypeRegistryEntry('T',null,"telnet://{host}:{port}"));
		//conventions
		exec("ADD_ENTRY","h\ttext/html");
		exec("ADD_ENTRY","p\timage/png");
		exec("ADD_ENTRY","P\tapplication/pdf");
		exec("ADD_ENTRY","s\taudio/*");
		add(new GopherTypeRegistryEntry('h',"text/html"));
		add(new GopherTypeRegistryEntry('p',"image/png"));
		add(new GopherTypeRegistryEntry('P',"application/pdf"));
		add(new GopherTypeRegistryEntry('s',"audio/*"));
	}
	
	public Fossil.Registry.GopherTypeRegistryEntry? get_entry_by_gophertype(unichar gophertype){
		return entries.get(gophertype);
	}
	
	public void add(Fossil.Registry.GopherTypeRegistryEntry entry){
		entries.set(entry.gophertype,entry);
	}
	
	public Fossil.Asm.Scriptreturn? add_entry(string _gophertype, string _mimetype, string hint = ""){
		print(@"ADD_ENTRY $_gophertype $_mimetype $hint\n");
		string? uri_template = null;
		if (_gophertype.char_count() != 1){ //yes we use bytes here
			return new Fossil.Asm.Scriptreturn(false,@"Argument[0]: Expected a unichar got $_gophertype");
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
			content_hint = GopherTypeRegistryContentHint.TEXT;
			uri_template = ".";
		} else if (hint == "ERROR"){
			content_hint = GopherTypeRegistryContentHint.ERROR;
			uri_template = ".";
		} else if (hint == "SEARCH"){
			content_hint = GopherTypeRegistryContentHint.SEARCH;
		} else {
			if (hint.contains("{search}")){
				content_hint = GopherTypeRegistryContentHint.SEARCH;
			}
			uri_template = hint;
		}
		this.add(new GopherTypeRegistryEntry(gophertype,mimetype,uri_template,content_hint));
		return null;
	}
	
	// ASM integration
	public Fossil.Asm.Scriptreturn? asm_add_entry(string arg, Object? context = null){
		var parsed_args = new Fossil.Asm.Argparse(arg);
		if (!(parsed_args.verify_argument(0,Fossil.Asm.Argparse.TYPE_STRING) &&
		      parsed_args.verify_argument(1,Fossil.Asm.Argparse.TYPE_STRING))){
			return new Fossil.Asm.Scriptreturn.missing_argument();
		}
		if (!parsed_args.verify_argument(3,Fossil.Asm.Argparse.TYPE_NULL)){
			return new Fossil.Asm.Scriptreturn.too_many_arguments();
		}
		return this.add_entry(parsed_args.get_string(0),parsed_args.get_string(1),parsed_args.get_string(2,""));
	}
	
	private void initialize_asm(){
		this.add_asm_function(new Fossil.Asm.FunctionDescriptor(
			this.asm_add_entry,
			"ADD_ENTRY",
			"asm.help.registry.gopher_type_registry.add_entry",
			"ADD_ENTRY <gophertype> [~]<mimetype>[*] [<hint|uri_template>]"
		));
	}
	
}

public class Fossil.Registry.GopherTypeRegistryEntry {
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
	
	public Fossil.Registry.GopherTypeRegistryEntry make_mimetype_suggestion(){
		this.mimeyte_is_suggestion = true;
		return this;
	}
	
	public string get_uri(string host, string port, string selector){
		if (selector.has_prefix("URL:")) {
			return selector.substring(4);
		}
		var uri = uri_template;
		uri = uri.replace("{host}",host);
		uri = uri.replace("{port}",port);
		uri = uri.replace("{type}",@"$gophertype");
		uri = uri.replace("{selector}",Uri.escape_string(selector,"/"));
		return uri;
	}
	
}

public enum Fossil.Registry.GopherTypeRegistryContentHint {
	TEXT,
	ERROR,
	LINK,
	SEARCH;
}
