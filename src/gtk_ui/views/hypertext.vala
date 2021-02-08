public class Dragonstone.GtkUi.View.Hypertext : Gtk.Bin, Dragonstone.GtkUi.Interface.View {
	
	private Dragonstone.Request request = null;
	private Dragonstone.GtkUi.Tab tab;
	
	private Dragonstone.Interface.Document.TokenParserFactory token_parser_factory;
	private Dragonstone.GtkUi.Interface.Theming.HyperTextViewThemeProvider theme_provider;
	private Dragonstone.GtkUi.Widget.HyperTextContent? hypertext = null;
	
	public Hypertext(Dragonstone.Interface.Document.TokenParserFactory token_parser_factory, Dragonstone.GtkUi.Interface.Theming.HyperTextViewThemeProvider theme_provider){
		this.token_parser_factory = token_parser_factory;
		this.theme_provider = theme_provider;
	}
	
	public bool display_resource(Dragonstone.Request request, Dragonstone.GtkUi.Tab tab, bool as_subview){
		this.tab = tab;
		if (request.status == "success" && token_parser_factory.has_parser_for(request.resource.mimetype)){
			var theme = theme_provider.get_theme(request.resource.mimetype, request.uri);
			if (theme == null){
				theme = theme_provider.get_default_theme();
			}
			hypertext = new Dragonstone.GtkUi.Widget.HyperTextContent(theme, new Dragonstone.GtkUi.Widget.LinkButtonPopover(tab));
			hypertext.go.connect(on_go_event);
			add(hypertext);
			var file = File.new_for_path(request.resource.filepath);
			if (!file.query_exists ()) {
				hypertext.append_styled_text("The cache file for this resource does not exist!\nReloading the page should help,\nif not please contact the developer!", "exception", true, false, 0);
			}
			print("hypertext: rendering content\n");
			try{
    		var parser = token_parser_factory.get_token_parser(request.resource.mimetype);
    		parser.set_input_stream(file.read());
    		bool first_title = true;
    		while (true) {
    			var token = parser.next_token();
    			if (token == null) { break; }
    			if (first_title && token.token_type == TITLE){
    				first_title = false;
    				tab.set_title(token.text);
    			}
    			hypertext.append_token(token);
    		}
    		
			} catch (GLib.Error e) {
				hypertext.append_styled_text(e.message, "exception", true, false, 0);
			}
		} else {
			return false;
		}
		show_all();
		this.request = request;
		return true;
	}
	
	public bool canHandleCurrentResource(){
		if (request == null) {
			return false;
		} else {
			return request.status == "success" && token_parser_factory.has_parser_for(request.resource.mimetype);
		}
	}
	
	protected void on_go_event(string uri, bool alt){
		if (this.tab != null) {
			if (alt) {
				tab.open_uri_in_new_tab(uri);
			} else {
				tab.go_to_uri(uri);
			}
		}
	}
	
	public bool import(string data){
		if (hypertext == null) { return false; }
		var kv = new Dragonstone.Util.Kv();
		kv.import(data);
		if (kv.get_value("view_type") != "dragonstone.hyper_text.0") {
			return false;
		}
		string? val = kv.get_value("scroll");
		if (val != null) {
			Dragonstone.GtkUi.Util.GtkScrollExport.import(hypertext, val);
		}
		return true;
	}
	
	public string? export(){
		if (hypertext == null) { return null; }
		var kv = new Dragonstone.Util.Kv();
		kv.set_value("view_type","dragonstone.hyper_text.0");
		kv.set_value("scroll",Dragonstone.GtkUi.Util.GtkScrollExport.export(hypertext));
		return kv.export();
	}
	
}
