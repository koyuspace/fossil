public class Dragonstone.Util.GopherTypeRegistry {
	
	public List<Dragonstone.Util.GopherTypeRegistryEntry> entrys = new List<Dragonstone.Util.GopherTypeRegistryEntry>();
	
	public GopherTypeRegistry.default_configuration(){
		//fast
		add(new GopherTypeRegistryEntry('i',null,".",GopherTypeRegistryContentHint.TEXT));
		//standardized
		add(new GopherTypeRegistryEntry('0',"text/plain"));
		add(new GopherTypeRegistryEntry('1',"text/gopher"));
		add(new GopherTypeRegistryEntry('2',null,"CCSO://{host}:{port}/{selector}"));
		add(new GopherTypeRegistryEntry('3',null,".",GopherTypeRegistryContentHint.ERROR));
		add(new GopherTypeRegistryEntry('4',"text/x-hex"));
		add(new GopherTypeRegistryEntry('5',"application/octet-stream"));
		add(new GopherTypeRegistryEntry('6',null));
		add(new GopherTypeRegistryEntry('7',"text/gopher",null,GopherTypeRegistryContentHint.SEARCH));
		add(new GopherTypeRegistryEntry('8',null,"telnet://{host}:{port}"));
		add(new GopherTypeRegistryEntry('9',"application/octet-stream"));
		add(new GopherTypeRegistryEntry('g',"image/gif"));
		add(new GopherTypeRegistryEntry('I',"image/*"));
		add(new GopherTypeRegistryEntry('T',null,"telnet://{host}:{port}"));
		//conventions
		add(new GopherTypeRegistryEntry('h',"text/html"));
		add(new GopherTypeRegistryEntry('p',"image/png"));
	}
	
	public Dragonstone.Util.GopherTypeRegistryEntry? get_entry_by_gophertype(unichar gophertype){
		foreach(Dragonstone.Util.GopherTypeRegistryEntry entry in entrys){
			if (entry.gophertype == gophertype){
				return entry;
			}
		}
		return null;
	}
	
	public void add(Dragonstone.Util.GopherTypeRegistryEntry entry){
		entrys.append(entry);
	}
	
}

public class Dragonstone.Util.GopherTypeRegistryEntry {
	public unichar gophertype { get; protected set; }
	public string? mimetype { get; protected set; }
	public string uri_template { get; protected set; }
	
	public GopherTypeRegistryEntry(unichar gophertype, string? mimetype = null, string? uri_template = null, GopherTypeRegistryContentHint hint = GopherTypeRegistryContentHint.LINK){
		this.gophertype = gophertype;
		this.mimetype = mimetype;
		if (uri_template != null){
			this.uri_template = uri_template;
		} else {
			this.uri_template = "gopher://{host}:{port}/{type}{selector}";
		}
	}
	
	public string get_uri(string host, string port, string selector, string? query = null){
		if (selector.has_prefix("URL:")) {
			return selector.substring(4);
		}
		var uri = uri_template;
		uri = uri.replace("{host}",host);
		uri = uri.replace("{port}",port);
		uri = uri.replace("{type}",@"$gophertype");
		uri = uri.replace("{selector}",selector);
		if( query != null ){
			uri = uri+"\t"+(query.replace("\t","%09"));
		}
		return uri;
	}
}

public enum Dragonstone.Util.GopherTypeRegistryContentHint {
	TEXT,
	ERROR,
	LINK,
	SEARCH;
}
