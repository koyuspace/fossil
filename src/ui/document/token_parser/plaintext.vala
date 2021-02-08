public class Dragonstone.Ui.Document.TokenParser.Plaintext : Dragonstone.Interface.Document.TokenParser, Object {
	
	private DataInputStream? input_stream = null; 
	
	private uint level = 0;
	
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
			if ((line = input_stream.read_line (null)) != null) {
				if (line == "") {
					token = new Dragonstone.Ui.Document.Token(EMPTY_LINE, 0, "");
				} else {
					token = new Dragonstone.Ui.Document.Token(PARAGRAPH, level, line+"\n", null, true);
				}
			}
			if (token == null && input_stream != null) {
				input_stream.close();
			}
		} catch (Error e) {
			return new Dragonstone.Ui.Document.Token.parser_error(level, e.message);
		}
		return token;
	}
	
	public void reset(){
		if (input_stream != null) {
			try {
				input_stream.close();
			} catch (Error e) {
				//ignore
			}
		}
		this.input_stream = null;
		this.level = 0;
	}

}
