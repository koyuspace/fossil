public class Dragonstone.View.Gophertext : Dragonstone.Widget.TextContent, Dragonstone.IView {
	
	private Dragonstone.Request request = null;
	
	private Dragonstone.Registry.MimetypeGuesser mimeguesser;
	private Dragonstone.Registry.GopherTypeRegistry type_registry;
	
	public Gophertext(){
		mimeguesser = new Dragonstone.Registry.MimetypeGuesser.default_configuration();
		type_registry = new Dragonstone.Registry.GopherTypeRegistry.default_configuration();
	}
	
	public Gophertext.with_mimeguesser(Dragonstone.Registry.MimetypeGuesser mimeguesser,Dragonstone.Registry.GopherTypeRegistry? type_registry = null){
		this.mimeguesser = mimeguesser;
		if (type_registry != null) {
			this.type_registry = type_registry;
		} else {
			this.type_registry = new Dragonstone.Registry.GopherTypeRegistry.default_configuration();
		}
	}
	
	
	public bool displayResource(Dragonstone.Request request,Dragonstone.Tab tab){
		if (request.status == "success" && request.resource.mimetype.has_prefix("text/gopher")){
			var file = File.new_for_path(request.resource.filepath);
			if (!file.query_exists ()) {
        this.textview.buffer.text ="The cache file for this resource does not exist!\nReloading the page should help,\nif not please contact the developer!";
    	}
    	try{
				//parse text
				unichar lasttype = '\0';
				var dis = new DataInputStream (file.read ());
        string line;
				while ((line = dis.read_line (null)) != null) {
					var tokens = line.split("\t");
					if(tokens.length == 4){//valid line
						unichar gophertype = 'i';
						string htext = "";
						if (tokens[0].length != 0){
							gophertype = tokens[0].get(0);
							htext = tokens[0].substring(1);//human text
						}
						var query = tokens[1].strip(); //look for url in here
						var host = tokens[2].strip();
						var port = tokens[3].strip();
						
						//
						if(gophertype == '+' && (type_registry.get_entry_by_gophertype(lasttype) != null)){
							gophertype = lasttype;
						}
						var typeinfo = type_registry.get_entry_by_gophertype(gophertype);
						if (typeinfo == null) {
							appendWidget(new Dragonstone.View.GophertextUnknownItem(gophertype,htext,query,host,port));
						} else if (typeinfo.hint == Dragonstone.Registry.GopherTypeRegistryContentHint.TEXT){
							appendText(htext+"\n");
						}else if (typeinfo.hint == Dragonstone.Registry.GopherTypeRegistryContentHint.LINK || query.has_prefix("URL:")){
							string? uri = null;
							if (query.has_prefix("URL:")) {
								uri = query.substring(4);
							}else{
								if( port != "70" ){
									uri = @"gopher://$host:$port/$gophertype$query";
								}else{
									uri = @"gopher://$host/$gophertype$query";
								}
							}
							appendWidget(new Dragonstone.Widget.LinkButton(tab,htext,uri));
						} else if (typeinfo.hint == Dragonstone.Registry.GopherTypeRegistryContentHint.SEARCH){ //Search
							string? uri = null;
							if( port != "70" ){
								uri = @"gopher://$host:$port/$gophertype$query";
							}else{
								uri = @"gopher://$host/$gophertype$query";
							}
							var searchfield = new Dragonstone.View.GophertextInlineSearch(htext,uri);
							searchfield.go.connect((s,uri) => {tab.goToUri(uri);});
							appendWidget(searchfield);
						} else if (typeinfo.hint == Dragonstone.Registry.GopherTypeRegistryContentHint.ERROR){ //Error
							appendWidget(new Dragonstone.View.GophertextIconLabel(htext,"dialog-error-symbolic"));
						}
						lasttype = gophertype;
					}else if(tokens.length == 0){ //empty line, ignore
					}else{ //invalid line
					
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
		this.request = request;
		return true;
	}
	
	public bool canHandleCurrentResource(){
		if (request == null){
			return false;
		}else{
			return request.status == "success" && request.resource.mimetype.has_prefix("text/gopher");
		}
	}
	
}

private class Dragonstone.View.GophertextInlineSearch : Gtk.Bin {

	public signal void go(string uri);
	private string base_uri;
	private Gtk.Entry entry;
	
	public GophertextInlineSearch(string htext,string uri){
		base_uri = uri;
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
		button.halign = Gtk.Align.START;
		//box.pack_start(icon);
		box.pack_start(entry);
		box.pack_start(button);
		box.halign = Gtk.Align.FILL;
		add(box);
	}
	
	private void submit(){
		if (entry.text != ""){
			var searchstring = entry.text.replace("\t","%09");
			go(@"$base_uri\t$searchstring");
		}
	}
}

private class Dragonstone.View.GophertextUnknownItem : Gtk.Bin {
	public GophertextUnknownItem(unichar gophertype,string htext,string query,string host,string port){
		var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL,4);
		box.homogeneous = false;
		box.margin_start = 4;
		var label = new Gtk.Label(@"Unknown Item Type: '$gophertype' -> $host:$port/$gophertype$query\n$htext");
		label.selectable = true;
		label.halign = Gtk.Align.START;
		//var labelAttrList = new Pango.AttrList();
		//labelAttrList.insert(new Pango.AttrSize(8000));
		//label.attributes = labelAttrList;
		var icon = new Gtk.Image.from_icon_name("dialog-question-symbolic",Gtk.IconSize.BUTTON);
		icon.halign = Gtk.Align.START;
		box.pack_start(icon);
		box.pack_start(label);
		box.halign = Gtk.Align.START;
		add(box);
	}
}

//gopher://khzae.net/1/poll/1556462960/vote?CARTOON NETWORK WEBSITE GOT HACKED??? NO!!!!!!!!!!!
// /\ for testing putposes
private class Dragonstone.View.GophertextIconLabel : Gtk.Bin {
	public GophertextIconLabel(string text,string icon_name){
		var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL,4);
		box.margin_start = 8; 
		box.homogeneous = false;
		var label = new Gtk.Label(text);
		label.selectable = true;
		label.halign = Gtk.Align.START;
		var labelAttrList = new Pango.AttrList();
		labelAttrList.insert(new Pango.AttrSize(10000));
		label.attributes = labelAttrList;
		var icon = new Gtk.Image.from_icon_name(icon_name,Gtk.IconSize.BUTTON);
		icon.halign = Gtk.Align.START;
		box.pack_start(icon);
		box.pack_start(label);
		box.halign = Gtk.Align.START;
		add(box);
	}
}
