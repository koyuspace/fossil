public class Dragonstone.Ui.Document.TokenParser.Gopher : Dragonstone.Interface.Document.TokenParser, Object {
	
	private DataInputStream? input_stream = null; 
	private Dragonstone.Registry.GopherTypeRegistry type_registry;
	
	private unichar lasttype = '\0';
	private bool last_was_text = false;
	
	public Gopher(Dragonstone.Registry.GopherTypeRegistry type_registry){
		this.type_registry = type_registry;
	}
	
	  ////////////////////////////////////////////////
	 // Dragonstone.Interface.Document.TokenParser //
	////////////////////////////////////////////////
	
	public void set_input_stream(InputStream input_stream){
		this.input_stream = new DataInputStream(input_stream);
	}
	
	//returns null when finished can possibly hang because of the input stream
	public Dragonstone.Ui.Document.Token? next_token(){
		if (input_stream == null) { return null; }
		string? line = null;
		Dragonstone.Ui.Document.Token? token = null;
		try {
			while ((line = input_stream.read_line (null)) != null) {
				var tokens = line.split("\t");
				if(tokens.length >= 4){//valid line, ignores gopher+ lines
					unichar gophertype = 'i';
					string htext = "";
					if (tokens[0].length != 0){
						gophertype = tokens[0].get_char(0);
						htext = tokens[0].substring(1);//human text
					}
					var selector = tokens[1].strip(); //look for url in here
					var host = tokens[2].strip();
					var port = tokens[3].strip();
					
					//Replace lasttype with gophertype
					if(gophertype == '+' && (type_registry.get_entry_by_gophertype(lasttype) != null)){
						gophertype = lasttype;
					}
					lasttype = gophertype;
					var typeinfo = type_registry.get_entry_by_gophertype(gophertype);
					if (typeinfo == null) {
						last_was_text = false;
						return new Dragonstone.Ui.Document.Token.parser_error(0, @"Unknown Line type: $line");
					}
					if (typeinfo.hint != Dragonstone.Registry.GopherTypeRegistryContentHint.TEXT) {
						last_was_text = false;
					}
					if (typeinfo.hint == Dragonstone.Registry.GopherTypeRegistryContentHint.TEXT) {
						if (htext == "") {
							token = new Dragonstone.Ui.Document.Token(EMPTY_LINE, 0, "");
							last_was_text = false;
							break;
						} else {
							token = new Dragonstone.Ui.Document.Token(PARAGRAPH, 0, htext+"\n", null, true, last_was_text);
							last_was_text = true;
							break;
						}
					} else if (typeinfo.hint == Dragonstone.Registry.GopherTypeRegistryContentHint.LINK || selector.has_prefix("URL:")) {
						string? uri = null;
						if (selector.has_prefix("URL:")) {
							uri = selector.substring(4);
						} else if (selector.has_prefix("/URL:")) { //pygopherd get your url right!
							uri = selector.substring(5);
						} else if (selector.has_prefix("url:")) { //It is bloody "URL:", it even is on wikipedia!
							uri = selector.substring(4);
						} else {
							uri = typeinfo.get_uri(host,port,selector);
						}
						token = new Dragonstone.Ui.Document.Token(LINK, 0, htext, uri, true);
						break;
					} else if (typeinfo.hint == Dragonstone.Registry.GopherTypeRegistryContentHint.SEARCH) { //Search
						string uri = typeinfo.get_uri(host,port,selector);
						token = new Dragonstone.Ui.Document.Token(SEARCH, 0, htext, uri, true);
						print("gopher parser: searchfield!!!!!");
						break;
					} else if (typeinfo.hint == Dragonstone.Registry.GopherTypeRegistryContentHint.ERROR) { //Error
						token = new Dragonstone.Ui.Document.Token(ERROR, 0, htext, null, true);
						break;
					}
				} else if (tokens.length == 0) { //empty line, ignore
				} else if (line == ".") { //end of file: ignore, because why not, there could be easter eggs or chocolate
				} else { //invalid line
					return new Dragonstone.Ui.Document.Token.parser_error(0, @"Unknown Line type: $line");
				}
			}
		} catch (Error e) {
			return new Dragonstone.Ui.Document.Token.parser_error(0, e.message);
		}
		return token;
	}
	
	public void reset(){
		this.input_stream = null;
		lasttype = '\0';
	}

}
