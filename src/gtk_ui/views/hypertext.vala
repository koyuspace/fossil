public class Fossil.GtkUi.View.Hypertext : Gtk.Bin, Fossil.GtkUi.Interface.LegacyView {
	
	private Fossil.Request request = null;
	private Fossil.GtkUi.LegacyWidget.Tab tab;
	
	private Fossil.Interface.Document.TokenParserFactory token_parser_factory;
	private Fossil.GtkUi.Interface.Theming.HypertextViewThemeProvider theme_provider;
	private Fossil.GtkUi.LegacyWidget.HypertextContent? hypertext = null;
	
	public Hypertext(Fossil.Interface.Document.TokenParserFactory token_parser_factory, Fossil.GtkUi.Interface.Theming.HypertextViewThemeProvider theme_provider){
		this.token_parser_factory = token_parser_factory;
		this.theme_provider = theme_provider;
	}
	
	public bool display_resource(Fossil.Request request, Fossil.GtkUi.LegacyWidget.Tab tab, bool as_subview){
		this.tab = tab;
		if (request.status == "success" && token_parser_factory.has_parser_for(request.resource.mimetype)){
			var theme = theme_provider.get_theme(request.resource.mimetype, request.uri);
			if (theme == null){
				theme = theme_provider.get_default_theme();
			}
			hypertext = new Fossil.GtkUi.LegacyWidget.HypertextContent(theme, new Fossil.GtkUi.LegacyWidget.LinkButtonPopover(tab));
			hypertext.go.connect(on_go_event);
			add(hypertext);
			var input_stream = tab.get_file_content_stream();
			if (input_stream == null) {
				hypertext.append_styled_text("The cache file for this resource does not exist!\nReloading the page should help,\nif not please contact the developer!", "exception", true, false, 0);
			} else {
				print("hypertext: rendering content\n");
	  		var parser = token_parser_factory.get_token_parser(request.resource.mimetype);
	  		parser.set_input_stream(input_stream);
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
		var kv = new Fossil.Util.Kv();
		kv.import(data);
		if (kv.get_value("view_type") != "fossil.hyper_text.0") {
			return false;
		}
		string? val = kv.get_value("scroll");
		if (val != null) {
			Fossil.GtkUi.LegacyUtil.GtkScrollExport.import(hypertext, val);
		}
		return true;
	}
	
	public string? export(){
		if (hypertext == null) { return null; }
		var kv = new Fossil.Util.Kv();
		kv.set_value("view_type","fossil.hyper_text.0");
		kv.set_value("scroll",Fossil.GtkUi.LegacyUtil.GtkScrollExport.export(hypertext));
		return kv.export();
	}
	
}
