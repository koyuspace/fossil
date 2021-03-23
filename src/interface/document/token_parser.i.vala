public interface Fossil.Interface.Document.TokenParser : Object {
	
	public abstract void set_input_stream(InputStream input_stream);
	
	//returns null when finished can possibly hang because of the input stream
	public abstract Fossil.Ui.Document.Token? next_token();
	
	public abstract void reset();
}
