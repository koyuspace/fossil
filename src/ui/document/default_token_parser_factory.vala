public class Dragonstone.Document.DefaultTokenParserFactory : Dragonstone.Interface.Document.TokenParserFactory, Object {
	
	private Dragonstone.Registry.GopherTypeRegistry gopher_type_registry;
	
	public DefaultTokenParserFactory(Dragonstone.Registry.GopherTypeRegistry gopher_type_registry){
		this.gopher_type_registry = gopher_type_registry;
	}
	
	  ///////////////////////////////////////////////////////
	 // Dragonstone.Interface.Document.TokenParserFactory //
	///////////////////////////////////////////////////////
	
	public Dragonstone.Interface.Document.TokenParser? get_token_parser(string content_type){
		//Make sure we don't forget to add the parser to the has_parser_for function
		if (!has_parser_for(content_type)) {
			return null;
		}
		if (content_type.has_prefix("text/gopher")) { return new Dragonstone.Ui.Document.TokenParser.Gopher(gopher_type_registry); }
		if (content_type.has_prefix("application/gopher")) { return new Dragonstone.Ui.Document.TokenParser.Gopher(gopher_type_registry); }
		if (content_type.has_prefix("text/gemini")) { return new Dragonstone.Ui.Document.TokenParser.Gemini(); }
		if (content_type.has_prefix("text/")) { return new Dragonstone.Ui.Document.TokenParser.Plaintext(); }
		return null;
	}
	
	public bool has_parser_for(string content_type){
		if (content_type.has_prefix("text/gopher")) { return true; }
		if (content_type.has_prefix("application/gopher")) { return true; }
		if (content_type.has_prefix("text/gemini")) { return true; }
		if (content_type.has_prefix("text/")) { return true; }
		return false;
	}
	
}
