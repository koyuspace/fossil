public class Dragonstone.GtkUi.View.Geminitext : Dragonstone.GtkUi.Widget.HyperTextContent, Dragonstone.GtkUi.Interface.View {
	
	private Dragonstone.Request request = null;
	private Dragonstone.GtkUi.Tab tab;
	
	public bool display_resource(Dragonstone.Request request, Dragonstone.GtkUi.Tab tab, bool as_subview){
		this.tab = tab;
		this.link_popover = new Dragonstone.GtkUi.Widget.LinkButtonPopover(tab);
		if (request.status == "success" && request.resource.mimetype.has_prefix("text/gemini")){
			var file = File.new_for_path(request.resource.filepath);
			if (!file.query_exists ()) {
        this.textview.buffer.text ="The cache file for this resource does not exist!\nReloading the page should help,\nif not please contact the developer!";
			}
			print("gemini: rendering content\n");
			try{
				//TODO: Use a general purpose token document view that utilizes a parser factory
				highlight_preformatted_paragraphs();
    		var parser = new Dragonstone.Ui.Document.TokenParser.Gemini();
    		parser.set_input_stream(file.read());
    		while (true) {
    			var token = parser.next_token();
    			if (token == null) { break; }
    			append_token(token);
    		}
			}catch (GLib.Error e) {
				this.append_widget(new Gtk.Label("Error while rendering gemini content:\n"+e.message));
			}
		} else {
			return false;
		}
		show_all();
		this.request = request;
		this.go.connect(on_go_event);
		return true;
	}
	
	public bool canHandleCurrentResource(){
		if (request == null){
			return false;
		}else{
			return request.status == "success" && request.resource.mimetype.has_prefix("text/gemini");
		}
	}
	
	protected void on_go_event(string uri, bool alt){
		if (this.tab != null){
			if (alt){
				tab.open_uri_in_new_tab(uri);
			} else {
				tab.go_to_uri(uri);
			}
		}
	}
	
	public bool import(string data){
		var kv = new Dragonstone.Util.Kv();
		kv.import(data);
		if (kv.get_value("view_type") != "dragonstone.gemini_text.0"){
			return false;
		}
		string? val = kv.get_value("scroll");
		if (val != null){
			Dragonstone.GtkUi.Util.GtkScrollExport.import(this,val);
		}
		return true;
	}
	
	public string? export(){
		var kv = new Dragonstone.Util.Kv();
		kv.set_value("view_type","dragonstone.gemini_text.0");
		kv.set_value("scroll",Dragonstone.GtkUi.Util.GtkScrollExport.export(this));
		return kv.export();
	}
	
}
