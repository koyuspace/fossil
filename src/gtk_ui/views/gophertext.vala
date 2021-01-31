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
    			switch(token.token_type){
    				case PARAGRAPH:
    					append_text(token.text);
    					break;
    				case EMPTY_LINE:
    					append_text("\n");
    					break;
    				case LINK:
    					append_link(token.text,token.uri);
    					append_text("\n");
    					break;
    				case SEARCH:
    					var searchfield = new Dragonstone.GtkUi.View.GophertextInlineSearch(token.text, token.uri);
							searchfield.go.connect((s,uri) => {
								tab.go_to_uri(uri);
								if (cache != null){
									cache.invalidate_for_uri(request.uri);
								}
							});
							append_widget(searchfield);
							break;
    				case ERROR:
    					append_text("ERROR: "+token.text);
    					break;
    				case PARSER_ERROR:
    					append_text("[PARSER ERROR] "+token.text);
    					break;
    				default:
	    				break;
    			}
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

private class Dragonstone.GtkUi.View.GophertextInlineSearch : Gtk.Bin {

	public signal void go(string uri);
	private string uri_template;
	private Gtk.Entry entry;
	
	public GophertextInlineSearch(string htext, string uri_template){
		this.uri_template = uri_template;
		var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL,4);
		box.homogeneous = false;
		box.margin_start = 4;
		entry = new Gtk.Entry();
		entry.placeholder_text = htext;
		//entry.halign = Gtk.Align.FILL;
		entry.activate.connect(submit);
		entry.expand = true;
		var width = 50;
		if (htext.char_count() > width) { width = htext.char_count()+1;}
		entry.set_width_chars(width);
		//var icon = new Gtk.Image.from_icon_name("system-search-symbolic",Gtk.IconSize.LARGE_TOOLBAR);
		//icon.halign = Gtk.Align.START;
		var button = new Gtk.Button.from_icon_name("go-next-symbolic");
		button.clicked.connect(submit);
		button.button_press_event.connect(handle_button_press);
		button.halign = Gtk.Align.START;
		//box.pack_start(icon);
		box.pack_start(entry);
		box.pack_start(button);
		box.halign = Gtk.Align.FILL;
		add(box);
		set_tooltip_text(uri_template);
	}
	
	private bool handle_button_press(Gdk.EventButton event){
		if (event.type == BUTTON_PRESS){
			if (event.button == 3 && uri_template.has_suffix("/postfile%09{search}")) { //right click
				var popover = new Dragonstone.GtkUi.View.GophertextInlineSearchPostB64FilePopover(this,uri_template.substring(0,uri_template.length-11)+"b64");
				popover.set_relative_to(this);
				popover.popup();
				popover.show_all();
				return true;
			}
		}
		return false;
	}
	
	private void submit(){
		if (entry.text != ""){
			go(uri_template.replace("{search}",Uri.escape_string(entry.text)));
		}
	}
}

private class Dragonstone.GtkUi.View.GophertextInlineSearchPostB64FilePopover : Gtk.Popover {
	
	private string base64_buffer = "";
	private string base_uri = "";
	private Dragonstone.GtkUi.View.GophertextInlineSearch parent_entry;
	private uint64 max_file_size = 1024*1024*128;
	private Gtk.Label error_label = new Gtk.Label("");
	private Gtk.Entry comment_entry = new Gtk.Entry();
	private Gtk.FileChooserButton file_button;
	private Gtk.Button post_button;
	private bool uploading = false;
	
	public GophertextInlineSearchPostB64FilePopover(Dragonstone.GtkUi.View.GophertextInlineSearch parent, string uri){
		this.base_uri = uri;
		this.parent_entry = parent;
		var box = new Gtk.Box(Gtk.Orientation.VERTICAL,4);
		box.margin = 8;
		var title_label = new Gtk.Label("This will post a base64 encoded file with a space seperated comment appended to it to");
		title_label.set_tooltip_text("This feataure is intended to work with the gopherboard over at gopher://khzae.net");
		var uri_label = new Gtk.Label(uri);
		uri_label.selectable = true;
		//filebutton
		file_button = new Gtk.FileChooserButton("Select a file to upload",Gtk.FileChooserAction.OPEN);
		//postbutton
		var post_button_label = "Upload!"; //tab.translation.localize("action.upload_file");
		var post_button = new Gtk.Button.with_label(post_button_label);
		post_button.sensitive = false;
		post_button.clicked.connect(this.activate_upload);
		//comment_entry
		comment_entry.placeholder_text = "Add comment (my not be supported everywhere)";
		comment_entry.activate.connect(this.activate_upload);
		//make file button work
		file_button.file_set.connect(() => {
			post_button.sensitive = true;
		});
		box.pack_start(title_label);
		box.pack_start(uri_label);
		box.pack_start(file_button);
		box.pack_start(comment_entry);
		box.pack_start(error_label);
		box.pack_start(post_button);
		add(box);
		this.set_position(Gtk.PositionType.BOTTOM);
	}
	
	private void activate_upload(){
		if (!uploading){
			var file = file_button.get_file();
			if (file != null){
				post_button.sensitive = false;
				encode_and_send_file(file);
			}
		}	
	}
	
	private void display_error(string error){
		Timeout.add(0,() => {
			error_label.label = error;
			return false;
		},Priority.HIGH);
	}
	
	private void send(){
		Timeout.add(0,() => {
			string comment = "";
			if (comment_entry.text != ""){
				comment = "%20"+Uri.escape_string(comment_entry.text);
			}
			parent_entry.go(@"$base_uri%09$base64_buffer$comment");
			return false;
		},Priority.HIGH);
	}
	
	private void encode_and_send_file(File file){
		uploading = true;
		try {
			var input_stream = file.read();
			uint64 size = 0;
			uint8[] readbuffer = new uint8[1024*4*3]; //make sure the size of this is dividable by 3!
			while (size < max_file_size){
				var bytes = input_stream.read_bytes(1024*4*3);
				var bytes_read = (uint64) bytes.length;
				size += (uint64) bytes_read;
				base64_buffer = base64_buffer+Base64.encode(bytes.get_data());
				if (bytes_read != readbuffer.length){	
					break;
				}
			}
			print(@"Read $size bytes\n");
			if (size > max_file_size){
				display_error("File too large (max 128MB)");
			}
			send();
		} catch (GLib.Error e) {
			print("[gopher.gtk][base64_file_upload][error] "+e.message);
			display_error(e.message);
		}
		uploading = false;
	}	
	
}
