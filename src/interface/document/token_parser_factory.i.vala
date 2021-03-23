public interface Fossil.Interface.Document.TokenParserFactory : Object {
	
	public abstract Fossil.Interface.Document.TokenParser? get_token_parser(string content_type);
	public abstract bool has_parser_for(string content_type);
	
}
