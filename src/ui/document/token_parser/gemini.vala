public class Dragonstone.Ui.Document.TokenParser.Gemini : Dragonstone.Interface.Document.TokenParser, Object {
	
	private DataInputStream? input_stream = null; 
	
	private bool preformatted_block = false;
	private bool preformatted_block_empty = false;
	private string? alttext = null;
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
			while ((line = input_stream.read_line (null)) != null) {
				bool is_text = true;
				if (line.validate(line.length)){
					if (line.has_prefix("```")){
						if (!preformatted_block){
							preformatted_block = true;
							if (line.length > 3){
								alttext = line.substring(3).strip();
							}
						} else {
							preformatted_block = false;
							if (line.length > 3){
								if (alttext == null){
									alttext = "";
								} else if (alttext != "") {
									alttext += "\n";
								}
								alttext += line.substring(3).strip();
							}
							if (alttext != null && alttext != "" && !preformatted_block_empty) {
								token = new Dragonstone.Ui.Document.Token(DESCRIPTION, level, alttext);
								alttext = null;
								break;
							}
							alttext = null;
						}
						is_text=false;
					}
					if (!preformatted_block){
						if (line.has_prefix("###")) {
							level = 2;
							is_text = false;
							token = new Dragonstone.Ui.Document.Token(TITLE, level, line.substring(3).strip());
							break;
						}
						if (line.has_prefix("##")) {
							level = 1;
							is_text = false;
							token = new Dragonstone.Ui.Document.Token(TITLE, level, line.substring(2).strip());
							break;
						}
						if (line.has_prefix("#")) {
							level = 0;
							is_text = false;
							token = new Dragonstone.Ui.Document.Token(TITLE, level, line.substring(1).strip());
							break;
						}
						if (line.has_prefix("* ")) {
							is_text = false;
							token = new Dragonstone.Ui.Document.Token(LIST_ITEM, level, line.substring(2).strip());
							break;
						}
						if (line.has_prefix(">")) {
							is_text = false;
							token = new Dragonstone.Ui.Document.Token(QUOTE, level, line.substring(1).strip());
							break;
						}
						if (line.has_prefix("=>")) {
							var uri = "";
							var htext = "";
							var uri_and_text = line.substring(2).strip();
							var spaceindex = uri_and_text.index_of_char(' ');
							var tabindex = uri_and_text.index_of_char('\t');
							if (spaceindex < 0 && tabindex < 0){
								uri = uri_and_text;
								htext = uri_and_text;
							} else if ((tabindex > 0 && tabindex < spaceindex) || spaceindex < 0){
								uri = uri_and_text.substring(0,tabindex);
								htext = uri_and_text.substring(tabindex).strip();
							} else if ((spaceindex > 0 && spaceindex < tabindex) || tabindex < 0){
								uri = uri_and_text.substring(0,spaceindex);
								htext = uri_and_text.substring(spaceindex).strip();
							}
							is_text = false;
							token = new Dragonstone.Ui.Document.Token(LINK, level, htext, uri);
							break;
						}
						
					}
					if (is_text){
						if (line == "" && !preformatted_block) {
							token = new Dragonstone.Ui.Document.Token(EMPTY_LINE, 0, "");
						} else {
							token = new Dragonstone.Ui.Document.Token(PARAGRAPH, level, line+"\n", null, preformatted_block, preformatted_block && (!preformatted_block_empty));
							preformatted_block_empty = false;
						}
						break;
					}
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
		this.preformatted_block = false;
		this.alttext = null;
		this.level = 0;
	}

}
