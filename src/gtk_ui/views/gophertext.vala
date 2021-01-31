public class Dragonstone.GtkUi.View.Gophertext : Dragonstone.GtkUi.Widget.HyperTextContent, Dragonstone.GtkUi.Interface.View {
	
	private Dragonstone.Request request = null;
	private Dragonstone.GtkUi.Tab tab;
	
	private Dragonstone.Registry.MimetypeGuesser mimeguesser;
	private Dragonstone.Registry.GopherTypeRegistry type_registry;
	
	private Dragonstone.Interface.Cache? cache = null;
	
	public Gophertext(){
		mimeguesser = new Dragonstone.Registry.MimetypeGuesser.default_configuration();
		type_registry = new Dragonstone.Registry.GopherTypeRegistry.default_configuration();
	}
	
	public Gophertext.with_registries(Dragonstone.Registry.MimetypeGuesser? mimeguesser,Dragonstone.Registry.GopherTypeRegistry? type_registry = null){
		if (mimeguesser != null){
			this.mimeguesser = mimeguesser;
		} else {
			this.mimeguesser = new Dragonstone.Registry.MimetypeGuesser.default_configuration();
		}
		if (type_registry != null) {
			this.type_registry = type_registry;
		} else {
			this.type_registry = new Dragonstone.Registry.GopherTypeRegistry.default_configuration();
		}
	}
	
	public void set_cache(Dragonstone.Interface.Cache? cache){
		this.cache = cache;
	}
	
	
	public bool display_resource(Dragonstone.Request request, Dragonstone.GtkUi.Tab tab, bool as_subview){
		this.tab = tab;
		if (request.status == "success" && request.resource.mimetype.has_prefix("text/gopher")){
			var file = File.new_for_path(request.resource.filepath);
			if (!file.query_exists ()) {
        this.textview.buffer.text ="The cache file for this resource does not exist!\nReloading the page should help,\nif not please contact the developer!";
        return false;
    	}
    	var cache = tab.session.get_cache();
    	if (cache != null){
    		this.cache = cache;
    	}
    	try{
    		//TODO: Use a general purpose token document view that utilizes a parser factory
    		var parser = new Dragonstone.Ui.Document.TokenParser.Gopher(type_registry);
    		parser.set_input_stream(file.read());
    		while (true) {
    			var token = parser.next_token();
    			if (token == null) { break; }
    			append_token(token);
    		}
			}catch (GLib.Error e) {
				Gtk.TextIter end_iter;
				textview.buffer.get_end_iter(out end_iter);
				var anchor = textview.buffer.create_child_anchor(end_iter);
				textview.add_child_at_anchor(new Gtk.Label("Error while rendering gopher content:\n"+e.message),anchor);
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
			return request.status == "success" && request.resource.mimetype.has_prefix("text/gopher");
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
		if (kv.get_value("view_type") != "dragonstone.gopher_text.0"){
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
		kv.set_value("view_type","dragonstone.gopher_text.0");
		kv.set_value("scroll",Dragonstone.GtkUi.Util.GtkScrollExport.export(this));
		return kv.export();
	}
	
}
