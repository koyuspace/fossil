public class Dragonstone.View.Directory : Gtk.Box, Dragonstone.IView {
	
	private Dragonstone.Request request = null;
	private Dragonstone.Tab tab = null;
	private Gtk.ListStore liststore = new Gtk.ListStore(3,typeof(string),typeof(string),typeof(string));
	private HashTable<string,Gtk.TreeIter?> displayed_uris = new HashTable<string,Gtk.TreeIter?>(str_hash, str_equal);
	private Gtk.TreeModelFilter filterstore;
	private Gtk.Entry search_entry;
	private Gtk.TreeView treeview;
	private string? selected_uri = null;
	private bool still_alive = true;
	private bool search_dirty = true;
	
	/*
		Colums:
		0: uri
		1: filename
		2: icon-name
	*/
	
	public Directory(Dragonstone.Registry.TranslationRegistry? itranslation){
		var translation = itranslation;
		if(translation == null) {
			var language = new Dragonstone.Registry.TranslationLanguageRegistry();
			language.set_text("view.directory.search.placeholder","Search ...");
			language.set_text("view.directory.column.uri.head","Uri");
			language.set_text("view.directory.colum.users.filename","Filename");
			translation = language;
		}
		//init gui
		expand = true;
		orientation = Gtk.Orientation.VERTICAL;
		var actionbar = new Gtk.ActionBar();
		actionbar.expand = false;
		//search_entry
		search_entry = new Gtk.Entry();
		search_entry.placeholder_text = translation.localize("view.directory.search.placeholder");
		search_entry.width_chars = 35;
		search_entry.buffer.deleted_text.connect(() => {this.search_dirty = true;});
		search_entry.buffer.inserted_text.connect(() => {this.search_dirty = true;});
		actionbar.pack_start(search_entry);
		//stores
		filterstore = new Gtk.TreeModelFilter((Gtk.TreeModel) liststore,null);
		filterstore.set_visible_func(filter_visible_function);
		//treeview
		treeview = new Gtk.TreeView();
		treeview.get_selection().set_mode(Gtk.SelectionMode.SINGLE);
		treeview.set_model(filterstore);
		treeview.insert_column_with_attributes(-1,translation.localize("view.directory.column.filename.head"), new Gtk.CellRendererText (), "text", 1);
		treeview.insert_column_with_attributes(-1,translation.localize("view.directory.column.uri.head"), new Gtk.CellRendererText (), "text", 0);
		//treeview.insert_column_with_attributes(-1,"Filename", new Gtk.CellRendererText (), "text", 1);
		treeview.row_activated.connect(treeview_row_activated);
		treeview.cursor_changed.connect(update_selected_uri);
		//scrolled window
		var scrolled_window = new Gtk.ScrolledWindow(null,null);
		scrolled_window.add(treeview);
		scrolled_window.expand = true;
		//pack to root window
		pack_start(actionbar);
		pack_start(scrolled_window);
		set_child_packing(actionbar,false,true,0,Gtk.PackType.START);
		set_child_packing(scrolled_window,true,true,0,Gtk.PackType.START);
		//show all
		show_all();
		//controls.visible = false;
		
		Timeout.add(1000,() => {
			if (search_dirty){
				search_dirty = false;
				filterstore.refilter();
			}
			return still_alive;
		});
	}
	
	private void add_item(string uri, string name, string type){
		Gtk.TreeIter iter;
		liststore.append (out iter);
		liststore.set (iter, 0, uri, 1, name, 2, "");
		displayed_uris.set(uri,iter);
		search_dirty = true;
	}
	
	private void add_line(string line){
		var tokens = line.split("\t");
		string type;
		string uri;
		string name;
		if (tokens.length >= 2){
			type = tokens[0];
			uri = tokens[1];
			if (tokens.length >= 3){
				name = tokens[2];
			} else {
				name = uri;
			}
			add_item(uri,name,type);
		}
	}
	
	private bool filter_visible_function(Gtk.TreeModel model, Gtk.TreeIter iter){
		string name = get_name_from_model(model,iter);
		if (name != null){
			return name.has_prefix(this.search_entry.buffer.text);
		} else {
			return false;
		}
	}
	
	private void treeview_row_activated(Gtk.TreePath path, Gtk.TreeViewColumn column){
		Gtk.TreeIter iter;
		if(!filterstore.get_iter(out iter,path)){
			return;
		}
		string uri = get_uri_from_model(filterstore,iter);
		if (uri != null && tab != null){
			tab.goToUri(uri);
		}
	}
	
	private void update_controls(){
		//controls.visible = selected_uri != null;
		if (selected_uri != null){
			//left blank 
		}
	}
	
	private void update_selected_uri(){
		var selection = treeview.get_selection();
		Gtk.TreeModel model;
		Gtk.TreeIter iter;
		if (selection.get_selected(out model, out iter)) {
			selected_uri = get_uri_from_model(model,iter);
		} else {
			selected_uri = null;
		}
		this.update_controls();
	}
	
	private string? get_uri_from_model(Gtk.TreeModel model, Gtk.TreeIter iter){
		Value urival;
		model.get_value(iter,0,out urival);
		return urival.get_string();
	}
	
	private string? get_name_from_model(Gtk.TreeModel model, Gtk.TreeIter iter){
		Value urival;
		model.get_value(iter,1,out urival);
		return urival.get_string();
	}
	
	public bool displayResource(Dragonstone.Request request,Dragonstone.Tab tab){
		if (!(request.status == "success" && request.resource.mimetype == "text/dragonstone-directory")) {return false;}
		this.request = request;
		this.tab = tab;
		var file = File.new_for_path(request.resource.filepath);
		if (!file.query_exists ()) {
			print("[directory.gtk][error] file does not exist!\n ");
      return false;
  	}
  	try {
  		var dis = new DataInputStream (file.read ());
      string line;
			while ((line = dis.read_line (null)) != null) {
				add_line(line.strip());
			}
		}catch (GLib.Error e) {
			print("[directory.gtk][error] Error while rendering directory content:\n"+e.message);
		}
		return true;
	}
	
	public bool canHandleCurrentResource(){
		if (request == null){
			return false;
		}else{
			return request.status == "success" && request.resource.mimetype == "text/dragonstone-directory";
		}
	}
	
	public void cleanup(){
		print("[directory.gtk] cleanup function called!\n");
		still_alive = false;
	}
	
	
}
