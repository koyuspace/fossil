public class Fossil.GtkUi.View.Directory : Gtk.Box, Fossil.GtkUi.Interface.LegacyView {
	
	private Fossil.Request request = null;
	private Fossil.GtkUi.LegacyWidget.Tab tab = null;
	private Gtk.ListStore liststore = new Gtk.ListStore(3,typeof(string),typeof(string),typeof(string));
	private HashTable<string,Gtk.TreeIter?> displayed_uris = new HashTable<string,Gtk.TreeIter?>(str_hash, str_equal);
	private Gtk.TreeModelFilter filterstore;
	private Gtk.TreeModelSort sortedstore;
	private Gtk.Entry search_entry;
	private Gtk.Entry path_entry;
	private Gtk.Button home_button;
	private Gtk.Button parent_button;
	private Gtk.TreeView treeview;
	private Gtk.Box controls;
	private Gtk.ToggleButton search_toggle;
	private string? home_uri = null;
	private string? root_uri = null;
	private string? parent_uri = null;
	private string? relative_uri = null;
	private string? selected_uri = null;
	private bool still_alive = true;
	private bool search_dirty = true;
	
	private double previous_adjustment_value = 0;
	private bool ignore_next_size_update = false;
	
	/*
		Colums:
		0: uri
		1: filename
		2: icon-name
	*/
	
	public Directory(Fossil.Registry.TranslationRegistry? itranslation){
		var translation = itranslation;
		if(translation == null) {
			var language = new Fossil.Registry.TranslationLanguageRegistry();
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
		controls = new Gtk.Box(Gtk.Orientation.HORIZONTAL,2);
		//parent_button
		parent_button = new Gtk.Button.from_icon_name("go-up-symbolic");
		parent_button.clicked.connect(go_parent);
		controls.pack_start(parent_button);
		//home_button
		home_button = new Gtk.Button.from_icon_name("user-home-symbolic");
		home_button.clicked.connect(go_home);
		controls.pack_start(home_button);
		//path_entry
		path_entry = new Gtk.Entry();
		path_entry.expand = true;
		path_entry.placeholder_text = translation.localize("view.directory.path.placeholder");
		path_entry.activate.connect(go_path);
		controls.pack_start(path_entry);
		//controls
		controls.set_child_packing(parent_button,false,true,0,Gtk.PackType.START);
		controls.set_child_packing(home_button,false,true,0,Gtk.PackType.START);
		controls.set_child_packing(path_entry,true,true,0,Gtk.PackType.START);
		actionbar.pack_start(controls);
		//search_entry
		search_entry = new Gtk.Entry();
		search_entry.placeholder_text = translation.localize("view.directory.search.placeholder");
		//search_entry.width_chars = 35;
		search_entry.buffer.deleted_text.connect(() => {this.search_dirty = true;});
		search_entry.buffer.inserted_text.connect(() => {this.search_dirty = true;});
		search_entry.expand = true;
		actionbar.pack_start(search_entry);
		//search_toggle
		search_toggle = new Gtk.ToggleButton();
		var searchicon = new Gtk.Image.from_icon_name("system-search-symbolic",Gtk.IconSize.SMALL_TOOLBAR);
		search_toggle.add(searchicon);
		search_toggle.toggled.connect(() => {
			controls.visible = !search_toggle.active;
			search_entry.visible = search_toggle.active;
			if (search_entry.visible){
				search_entry.grab_focus_without_selecting();
			}
		});
		actionbar.pack_start(search_toggle);
		//stores
		filterstore = new Gtk.TreeModelFilter((Gtk.TreeModel) liststore,null);
		filterstore.set_visible_func(filter_visible_function);
		sortedstore = new Gtk.TreeModelSort.with_model(filterstore);
		sortedstore.set_sort_column_id (1, Gtk.SortType.ASCENDING);
		//treeview
		treeview = new Gtk.TreeView();
		treeview.get_selection().set_mode(Gtk.SelectionMode.SINGLE);
		treeview.set_model(sortedstore);
		treeview.insert_column_with_attributes(-1,translation.localize("view.directory.column.filename.head"), new Gtk.CellRendererText (), "text", 1);
		treeview.insert_column_with_attributes(-1,translation.localize("view.directory.column.uri.head"), new Gtk.CellRendererText (), "text", 0);
		//treeview.insert_column_with_attributes(-1,"Filename", new Gtk.CellRendererText (), "text", 1);
		treeview.row_activated.connect(treeview_row_activated);
		treeview.cursor_changed.connect(update_selected_uri);
		//scrolled window
		var scrolled_window = new Gtk.ScrolledWindow(null,null);
		scrolled_window.add(treeview);
		scrolled_window.expand = true;
		//some adjustment magic
		scrolled_window.vadjustment.value_changed.connect(() => {
			if (!ignore_next_size_update) {
				bool scrolled_down = scrolled_window.vadjustment.value < previous_adjustment_value;
				//print(@"Vadjustment : $(scrolled_window.vadjustment.value) $previous_adjustment_value $scrolled_down $(actionbar.is_visible())\n");
				if (scrolled_down != actionbar.is_visible()){
					actionbar.visible = scrolled_down;
				}
			} else {
				ignore_next_size_update = false;
			}
			previous_adjustment_value = scrolled_window.vadjustment.value;
		});
		scrolled_window.vadjustment.changed.connect(() => {
			ignore_next_size_update = true;
		});
		//pack to root window
		pack_start(actionbar);
		pack_start(scrolled_window);
		set_child_packing(actionbar,false,true,0,Gtk.PackType.START);
		set_child_packing(scrolled_window,true,true,0,Gtk.PackType.START);
		//show all
		show_all();
		search_entry.visible = false;
		
		Timeout.add(1000,() => {
			if (search_dirty){
				search_dirty = false;
				filterstore.refilter();
			}
			return still_alive;
		});
	}
	
	private void add_item(string uri, string name, string type){
		if (type == "HOME") {
			this.home_uri = uri;
		} else if (type == "ROOT") {
			this.root_uri = uri;
		} else if (type == "THIS") {
			this.relative_uri = uri;
		} else if (type == "PARENT") {
			this.parent_uri = uri;
		} else {
			Gtk.TreeIter iter;
			liststore.append (out iter);
			liststore.set (iter, 0, uri, 1, name, 2, "");
			displayed_uris.set(uri,iter);
			search_dirty = true;
		}
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
		if(!sortedstore.get_iter(out iter,path)){
			return;
		}
		string uri = get_uri_from_model(sortedstore,iter);
		if (uri != null && tab != null){
			tab.go_to_uri(uri);
		}
	}
	
	private void go_path() {
		if (this.root_uri != null) {
			this.tab.go_to_uri(Fossil.Util.Uri.join(this.root_uri,this.path_entry.text));
		} else {
			this.tab.go_to_uri(this.path_entry.text);
		}
	}
	
	private void go_home() {
		if (this.home_uri != null){
		print("[directory.gtk] go home\n");
			this.tab.go_to_uri(this.home_uri);
		}
	}
	
	private void go_parent() {
		if (this.parent_uri != null){
			print("[directory.gtk] go parent\n");
			this.tab.go_to_uri(this.parent_uri);
		}
	}
	
	private void update_navigation() {
		if (path_entry.buffer.text == "" && this.relative_uri != null){
			path_entry.text = this.relative_uri;
		}
		parent_button.visible = this.parent_uri != null;
		if (this.parent_uri != null){
			parent_button.set_tooltip_text(parent_uri);
		}
		home_button.visible = this.home_uri != null;
		if (this.home_uri != null){
			home_button.set_tooltip_text(home_uri);
			home_button.sensitive = this.home_uri != request.uri;
		} else {
			home_button.sensitive = true;
		}
	}
	
	private void update_controls() {
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
	
	public bool display_resource(Fossil.Request request, Fossil.GtkUi.LegacyWidget.Tab tab, bool as_subview){
		if (!(request.status == "success" && request.resource.mimetype == "text/fossil-directory")) {return false;}
		this.request = request;
		this.tab = tab;
  	var input_stream = tab.get_file_content_stream();
		if (input_stream == null) {
			print("[directory.gtk][error] file does not exist!\n ");
      return false;
		} else {
			try {
				var dis = new DataInputStream(input_stream);
		    string line;
				while ((line = dis.read_line (null)) != null) {
					add_line(line.strip());
				}
				update_navigation();
			}catch (GLib.Error e) {
				print("[directory.gtk][error] Error while rendering directory content:\n"+e.message);
			}
		}
		return true;
	}
	
	public bool canHandleCurrentResource(){
		if (request == null){
			return false;
		}else{
			return request.status == "success" && request.resource.mimetype == "text/fossil-directory";
		}
	}
	
	public void cleanup(){
		print("[directory.gtk] cleanup function called!\n");
		still_alive = false;
	}
	
	
}
