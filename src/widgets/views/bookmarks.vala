public class Dragonstone.View.Bookmarks : Gtk.Stack, Dragonstone.IView {
	
	private Dragonstone.Request? request = null;
	private Dragonstone.Tab? tab = null;
	private Dragonstone.Registry.TranslationRegistry? translation = null;
	private Dragonstone.Registry.BookmarkRegistry bookmark_registry;
	
	private HashTable<string,Gtk.TreeIter?> displayed_uids = new HashTable<string,Gtk.TreeIter?>(str_hash, str_equal);
	private Dragonstone.Registry.BookmarkRegistryEntry? selected_bookmark = null;
	
	private Gtk.ListStore liststore = new Gtk.ListStore(3,typeof(string),typeof(string),typeof(string));
	private Gtk.TreeModelFilter filterstore;
	
	//bookmark list
	private Gtk.ScrolledWindow list_scroll;
	private Gtk.Box view_list = new Gtk.Box(Gtk.Orientation.VERTICAL,0);
	private Gtk.TreeView treeview;
	private Gtk.Button addbutton = new Gtk.Button();
	public Gtk.Button backbutton = new Gtk.Button.from_icon_name("go-previous-symbolic");
	//private Gtk.Popover addpopover;
	private Gtk.Box controls = new Gtk.Box(Gtk.Orientation.HORIZONTAL,1);
	private Gtk.Button editbutton = new Gtk.Button.from_icon_name("document-edit-symbolic");
	//private Gtk.Popover editpopover;
	private Gtk.Button gotobutton = new Gtk.Button.from_icon_name("go-jump-symbolic");
	private Gtk.ToggleButton search_toggle = new Gtk.ToggleButton();
	private Gtk.Entry search_entry = new Gtk.Entry();
	
	//addview
	private Dragonstone.Widget.SubviewBase subview_add = new Dragonstone.Widget.SubviewBase("temptitle: Add");
	private Dragonstone.Widget.BookmarkAdder addwidget;
		
	//editview
	private Dragonstone.Widget.SubviewBase subview_edit = new Dragonstone.Widget.SubviewBase("temptitle: Edit");
	private Dragonstone.Widget.BookmarkEditor editwidget;
	
	/*
		Columns:
		0: uid
		1: uri
		2: name
	*/
	
	public Bookmarks(Dragonstone.Registry.BookmarkRegistry bookmark_registry, Dragonstone.Registry.TranslationRegistry? translation){
		this.bookmark_registry = bookmark_registry;
		this.translation = translation;
		if (translation == null){
			this.translation = new Dragonstone.Registry.TranslationLanguageRegistry();
		}
		//backbutton
		backbutton.clicked.connect(() => {
			if (this.tab != null){
				this.tab.go_back_subview();
			}
		});
		//addbutton
		addbutton.label = translation.localize("view.boomarks.add.label");
		addwidget = new Dragonstone.Widget.BookmarkAdder(bookmark_registry);
		addwidget.margin = 8;
		subview_add.append_child(addwidget);
		subview_add.set_title(translation.localize("view.boomarks.subview_add.title"));
		/*addpopover = new Gtk.Popover(addbutton);
		addpopover.add(subview_add);
		addpopover.show_all();
		addpopover.hide();*/
		add_named(subview_add,"subview_add");
		/*addbutton.clicked.connect(addpopover.popup);
		addwidget.cancel_button.clicked.connect(addpopover.popdown);*/
		addbutton.clicked.connect(() => {
			this.set_visible_child_full("subview_add",Gtk.StackTransitionType.OVER_LEFT);
			addwidget.uri_entry.grab_focus_without_selecting();
		});
		addwidget.cancel_button.clicked.connect(() => {
			this.set_visible_child_full("view_list",Gtk.StackTransitionType.UNDER_RIGHT);
		});
		addwidget.localize(translation);
		addwidget.bookmark_added.connect(() => {
			//addpopover.popdown();
			this.set_visible_child_full("view_list",Gtk.StackTransitionType.UNDER_RIGHT);
			addwidget.set_values("","");
		});
		subview_add.backbutton.clicked.connect(() => {
			this.set_visible_child_full("view_list",Gtk.StackTransitionType.UNDER_RIGHT);
		});
		//editbutton
		editbutton.tooltip_text = translation.localize("view.boomarks.editbutton.tooltip");
		editwidget = new Dragonstone.Widget.BookmarkEditor(bookmark_registry);
		editwidget.margin = 8;
		subview_edit.append_child(editwidget);
		subview_edit.set_title(translation.localize("view.boomarks.subview_edit.title"));
		/*editpopover = new Gtk.Popover(editbutton);
		editpopover.add(subview_edit);
		editpopover.show_all();
		editpopover.hide();*/
		add_named(subview_edit,"subview_edit");
		editbutton.clicked.connect(() => {
			if (selected_bookmark != null){
				editwidget.edit_bookmark(selected_bookmark);
				/*editpopover.popup();*/
				this.set_visible_child_full("subview_edit",Gtk.StackTransitionType.OVER_LEFT);
			}
		});
		//editwidget.done_editing.connect(editpopover.popdown);
		editwidget.done_editing.connect(() => {
			this.set_visible_child_full("view_list",Gtk.StackTransitionType.UNDER_RIGHT);
		});
		subview_edit.backbutton.clicked.connect(() => {
			this.set_visible_child_full("view_list",Gtk.StackTransitionType.UNDER_RIGHT);
		});
		editwidget.localize(translation);
		/*editwidget.name_entry.activate.connect(editpopover.popdown);
		editwidget.uri_entry.activate.connect(editpopover.popdown);*/
		editwidget.name_entry.activate.connect(() => {
			this.set_visible_child_full("view_list",Gtk.StackTransitionType.UNDER_RIGHT);
		});
		editwidget.uri_entry.activate.connect(() => {
			this.set_visible_child_full("view_list",Gtk.StackTransitionType.UNDER_RIGHT);
		});
		//gotobutton
		gotobutton.clicked.connect(open_selected_in_new_tab);
		gotobutton.tooltip_text = translation.localize("view.boomarks.open_in_new_tab.tooltip");
		//populate controls box
		controls.pack_start(new Gtk.Separator(Gtk.Orientation.VERTICAL));
		controls.pack_start(editbutton);
		controls.pack_start(gotobutton);
		controls.pack_start(new Gtk.Separator(Gtk.Orientation.VERTICAL));
		//search_toggle
		var searchicon = new Gtk.Image.from_icon_name("system-search-symbolic",Gtk.IconSize.SMALL_TOOLBAR);
		search_toggle.add(searchicon);
		search_toggle.toggled.connect(() => {
			addbutton.visible = !search_toggle.active;
			backbutton.visible = !search_toggle.active;
			search_entry.visible = search_toggle.active;
			if (search_entry.visible){
				search_entry.grab_focus_without_selecting();
			}
		});
		//search_entry
		search_entry.placeholder_text = translation.localize("view.bookmarks.search.placeholder");
		search_entry.expand = true;
		search_entry.buffer.inserted_text.connect(on_search_dirty);
		search_entry.buffer.deleted_text.connect(on_search_dirty);
		//stores
		filterstore = new Gtk.TreeModelFilter((Gtk.TreeModel) liststore,null);
		filterstore.set_visible_func(filter_visible_function);
	}
	
	public bool displayResource(Dragonstone.Request request,Dragonstone.Tab tab, bool as_subview){
		if (!(request.status == "interactive/bookmarks" || as_subview)) { return false; }
		this.request = request;
		this.tab = tab;
		//init gui
		expand = true;
		var actionbar = new Gtk.ActionBar();
		actionbar.expand = false;
		//backbutton
		actionbar.pack_start(backbutton);
		//addbutton
		actionbar.pack_start(addbutton);
		//controls
		actionbar.pack_start(controls);
		//search
		actionbar.pack_end(search_toggle);
		actionbar.pack_end(search_entry);
		//add bookmarks
		bookmark_registry.bookmark_added.connect(append_entry);
		bookmark_registry.bookmark_modified.connect(update_entry);
		bookmark_registry.bookmark_removed.connect(remove_entry);
		bookmark_registry.iterate_over_all_bookmarks((entry) => {
			append_entry(entry);
			return true;
		});
		//treeview
		treeview = new Gtk.TreeView();
		treeview.get_selection().set_mode(Gtk.SelectionMode.SINGLE);
		treeview.set_model(filterstore);
		treeview.insert_column_with_attributes(-1,translation.localize("view.bookmarks.column.name.head"), new Gtk.CellRendererText (), "text", 2);
		treeview.insert_column_with_attributes(-1,translation.localize("view.bookmarks.column.uri.head"), new Gtk.CellRendererText (), "text", 1);
		//only needed for debugging
		//treeview.insert_column_with_attributes(-1,translation.localize("view.interactive/bookmarks.column.uri.head"), new Gtk.CellRendererText (), "text", 0);
		treeview.row_activated.connect(treeview_row_activated);
		treeview.cursor_changed.connect(update_selected_bookmark);
		//scrolled window
		list_scroll = new Gtk.ScrolledWindow(null,null);
		list_scroll.add(treeview);
		list_scroll.expand = true;
		//pack to root window
		view_list.pack_start(actionbar);
		view_list.pack_start(list_scroll);
		view_list.set_child_packing(actionbar,false,true,0,Gtk.PackType.START);
		view_list.set_child_packing(list_scroll,true,true,0,Gtk.PackType.START);
		this.add_named(view_list,"view_list");
		this.show_all();
		this.set_visible_child(view_list);
		search_entry.hide();
		if (as_subview){
			search_entry.text = request.uri;
			addwidget.uri_entry.text = request.uri;
		} else {
			backbutton.hide();
		}
		update_controls();
		return true;
	}
	
	private void append_entry(Dragonstone.Registry.BookmarkRegistryEntry entry){
		lock(displayed_uids){
			if (displayed_uids.get(entry.uid) == null){
				Gtk.TreeIter iter;
				liststore.append (out iter);
				liststore.set (iter, 0, entry.uid, 1, entry.uri, 2, entry.name);
				displayed_uids.set(entry.uid, iter);
				on_search_dirty();
			}
		}
	}
	
	private void update_entry(Dragonstone.Registry.BookmarkRegistryEntry entry){
		lock(displayed_uids){
			var iter = displayed_uids.get(entry.uid); 
			if (iter != null){
				liststore.set (iter, 1, entry.uri, 2, entry.name);
				on_search_dirty();
			}
			//maybe add the entry, if its not in the table of displayed entrys
		}
	}
	
	private void remove_entry(Dragonstone.Registry.BookmarkRegistryEntry entry){
		lock(displayed_uids){
			var iter = displayed_uids.get(entry.uid); 
			if (iter != null){
				liststore.remove(ref iter);
				displayed_uids.remove(entry.uid);
			}
		}
	}
	
	private void open_selected_in_new_tab(){
		if (selected_bookmark != null){
			tab.open_uri_in_new_tab(selected_bookmark.uri);
		}
	}
	
	private void update_selected_bookmark(){
		var selection = treeview.get_selection();
		Gtk.TreeModel model;
		Gtk.TreeIter iter;
		if (selection.get_selected(out model, out iter)) {
			selected_bookmark = bookmark_registry.get_bookmark_by_uid(get_uid_from_model(model,iter));
		} else {
			selected_bookmark = null;
		}
		this.update_controls();
	}
	
	private void treeview_row_activated(Gtk.TreePath path, Gtk.TreeViewColumn column){
		Gtk.TreeIter iter;
		if(!filterstore.get_iter(out iter,path)){
			return;
		}
		string uri = get_uri_from_model(filterstore,iter);
		if (uri != null && tab != null){
			tab.go_to_uri(uri);
		}
	}
	
	private bool filter_visible_function(Gtk.TreeModel model, Gtk.TreeIter iter){
		string? uri = get_uri_from_model(model,iter);
		string? name = get_name_from_model(model,iter);
		string searchquery = this.search_entry.buffer.text;
		if (uri != null){
			if (uri.contains(searchquery)){
				return true;
			}
		}
		if (name != null){
			if (name.contains(searchquery)){
				return true;
			}
		}
		return false;
	}
	
	private bool timeout_running = false;
	private void on_search_dirty(){
		if (!timeout_running){
			timeout_running = true;
			Timeout.add(500,() => {
				filterstore.refilter();
				update_controls();
				timeout_running = false;
				return false;
			},Priority.HIGH);
		}
	}
	
	private void update_controls(){
		controls.visible = selected_bookmark != null;
	}
	
	public bool canHandleCurrentResource(){
		if (request == null){
			return false;
		}else{
			return request.status == "interactive/bookmarks";
		}
	}
	
	private string? get_name_from_model(Gtk.TreeModel model, Gtk.TreeIter iter){
		Value nameval;
		model.get_value(iter,2,out nameval);
		return nameval.get_string();
	}
	
	private string? get_uri_from_model(Gtk.TreeModel model, Gtk.TreeIter iter){
		Value urival;
		model.get_value(iter,1,out urival);
		return urival.get_string();
	}
	
	private string? get_uid_from_model(Gtk.TreeModel model, Gtk.TreeIter iter){
		Value uidval;
		model.get_value(iter,0,out uidval);
		return uidval.get_string();
	}
	
	public bool import(string data){
		var kv = new Dragonstone.Util.Kv();
		kv.import(data);
		if (kv.get_value("view_type") != "dragonstone.bookmarks.0"){
			return false;
		}
		string? val = kv.get_value("search.text");
		if (val != null) {
			this.search_entry.text = val;
		}
		if (kv.get_value("search_toggle.active") == "true"){
			search_toggle.active = true;
		}
		val = kv.get_value("add_name_entry");
		if (val != null){
			this.addwidget.name_entry.text = val;
		}
		val = kv.get_value("add_uri_entry");
		if (val != null){
			this.addwidget.uri_entry.text = val;
		}
		val = kv.get_value("visible_view");
		if (val == "add"){
			this.set_visible_child_name("subview_add");
		} else if (val == "edit"){
			this.set_visible_child_name("subview_edit");
			val = kv.get_value("edit_name_entry");
			if (val != null){
				this.editwidget.name_entry.text = val;
			}
			val = kv.get_value("edit_uri_entry");
			if (val != null){
				this.editwidget.uri_entry.text = val;
			}
		}
		val = kv.get_value("scroll");
		if (val != null){
			Dragonstone.Util.GtkScrollExport.import(this.list_scroll,val);
		}
		return true;
	}
	
	public string? export(){
		var kv = new Dragonstone.Util.Kv();
		kv.set_value("view_type","dragonstone.bookmarks.0");
		if (this.search_entry.text != ""){
			kv.set_value("search.text",this.search_entry.text);
		}
		if (search_toggle.active){
			kv.set_value("search_toggle.active","true");
		}
		if (this.visible_child_name == "subview_add"){
			kv.set_value("visible_view","add");
		}
		kv.set_value("add_name_entry",this.addwidget.name_entry.text);
		kv.set_value("add_uri_entry",this.addwidget.uri_entry.text);
		if (this.visible_child_name == "subview_edit"){
			kv.set_value("visible_view","edit");
			kv.set_value("edit_name_entry",this.editwidget.name_entry.text);
			kv.set_value("edit_uri_entry",this.editwidget.uri_entry.text);
		}
		kv.set_value("scroll",Dragonstone.Util.GtkScrollExport.export(this.list_scroll));
		return kv.export();
	}
	
	public void cleanup(){
		bookmark_registry.bookmark_added.disconnect(append_entry);
		bookmark_registry.bookmark_modified.disconnect(update_entry);
		bookmark_registry.bookmark_removed.disconnect(remove_entry);
	}
	
}
