public class Dragonstone.View.Bookmarks : Gtk.Box, Dragonstone.IView {
	
	private Dragonstone.Request? request = null;
	private Dragonstone.Tab? tab = null;
	private Dragonstone.Registry.TranslationRegistry? translation = null;
	private Dragonstone.Registry.BookmarkRegistry bookmark_registry;
	
	private HashTable<string,Gtk.TreeIter?> displayed_uids = new HashTable<string,Gtk.TreeIter?>(str_hash, str_equal);
	private bool search_dirty = true;
	private Dragonstone.Registry.BookmarkRegistryEntry? selected_bookmark = null;
	
	private Gtk.ListStore liststore = new Gtk.ListStore(3,typeof(string),typeof(string),typeof(string));
	
	private Gtk.TreeView treeview;
	private Gtk.Button addbutton = new Gtk.Button();
	private Gtk.Popover addpopover;
	private Dragonstone.Widget.BookmarkAdder addwidget;
	private Gtk.Box controls = new Gtk.Box(Gtk.Orientation.HORIZONTAL,1);
	private Gtk.Button editbutton = new Gtk.Button.from_icon_name("document-edit-symbolic");
	private Gtk.Popover editpopover;
	private Dragonstone.Widget.BookmarkEditor editwidget;
	private Gtk.Button gotobutton = new Gtk.Button.from_icon_name("go-jump-symbolic");
	/*
		Columns:
		0: uid
		1: uri
		2: name
	*/
	
	public Bookmarks(Dragonstone.Registry.BookmarkRegistry bookmark_registry, Dragonstone.Registry.TranslationRegistry? translation){
		this.translation = translation;
		if (translation == null){
			this.translation = new Dragonstone.Registry.TranslationLanguageRegistry();
		}
		//addbutton
		addbutton.label = translation.localize("view.boomarks.add.label");
		addwidget = new Dragonstone.Widget.BookmarkAdder(bookmark_registry);
		addwidget.margin = 8;
		addpopover = new Gtk.Popover(addbutton);
		addpopover.add(addwidget);
		addpopover.show_all();
		addpopover.hide();
		addbutton.clicked.connect(addpopover.popup);
		addwidget.cancel_button.clicked.connect(addpopover.popdown);
		addwidget.localize(translation);
		addwidget.bookmark_added.connect(() => {
			addpopover.popdown();
			addwidget.set_values("","");
		});
		//editbutton
		editbutton.tooltip_text = translation.localize("view.boomarks.editbutton.tooltip");
		editwidget = new Dragonstone.Widget.BookmarkEditor(bookmark_registry);
		editwidget.margin = 8;
		editpopover = new Gtk.Popover(editbutton);
		editpopover.add(editwidget);
		editpopover.show_all();
		editpopover.hide();
		editbutton.clicked.connect(() => {
			if (selected_bookmark != null){
				editwidget.edit_bookmark(selected_bookmark);
				editpopover.popup();
			}
		});
		editwidget.done_editing.connect(editpopover.popdown);
		editwidget.localize(translation);
		editwidget.name_entry.activate.connect(editpopover.popdown);
		editwidget.uri_entry.activate.connect(editpopover.popdown);
		//gotobutton
		gotobutton.clicked.connect(open_selected_in_new_tab);
		gotobutton.tooltip_text = translation.localize("view.boomarks.open_in_new_tab.tooltip");
		//populate controls box
		controls.pack_start(new Gtk.Separator(Gtk.Orientation.VERTICAL));
		controls.pack_start(editbutton);
		controls.pack_start(gotobutton);
		controls.pack_start(new Gtk.Separator(Gtk.Orientation.VERTICAL));
		
		this.bookmark_registry = bookmark_registry;
	}
	
	public bool displayResource(Dragonstone.Request request,Dragonstone.Tab tab){
		if (!(request.status == "interactive/bookmarks")) {return false;}
		this.request = request;
		this.tab = tab;
		//init gui
		expand = true;
		orientation = Gtk.Orientation.VERTICAL;
		var actionbar = new Gtk.ActionBar();
		actionbar.expand = false;
		//addbutton
		actionbar.pack_start(addbutton);
		//controls
		actionbar.pack_start(controls);
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
		treeview.set_model(liststore);
		treeview.insert_column_with_attributes(-1,translation.localize("view.interactive/bookmarks.column.name.head"), new Gtk.CellRendererText (), "text", 2);
		treeview.insert_column_with_attributes(-1,translation.localize("view.interactive/bookmarks.column.uri.head"), new Gtk.CellRendererText (), "text", 1);
		treeview.insert_column_with_attributes(-1,translation.localize("view.interactive/bookmarks.column.uri.head"), new Gtk.CellRendererText (), "text", 0);
		treeview.row_activated.connect(treeview_row_activated);
		treeview.cursor_changed.connect(update_selected_bookmark);
		//scrolled window
		var scrolled_window = new Gtk.ScrolledWindow(null,null);
		scrolled_window.add(treeview);
		scrolled_window.expand = true;
		//pack to root window
		this.pack_start(actionbar);
		pack_start(scrolled_window);
		set_child_packing(actionbar,false,true,0,Gtk.PackType.START);
		set_child_packing(scrolled_window,true,true,0,Gtk.PackType.START);
		this.show_all();
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
				search_dirty = true;
			}
		}
	}
	
	private void update_entry(Dragonstone.Registry.BookmarkRegistryEntry entry){
		lock(displayed_uids){
			var iter = displayed_uids.get(entry.uid); 
			if (iter != null){
				liststore.set (iter, 1, entry.uri, 2, entry.name);
				search_dirty = true;
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
		if(!liststore.get_iter(out iter,path)){
			return;
		}
		string uri = get_uri_from_model(liststore,iter);
		if (uri != null && tab != null){
			tab.go_to_uri(uri);
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
	
	public void cleanup(){
		bookmark_registry.bookmark_added.disconnect(append_entry);
		bookmark_registry.bookmark_modified.disconnect(update_entry);
		bookmark_registry.bookmark_removed.disconnect(remove_entry);
	}
	
}

public class Dragonstone.Widget.BookmarkAdder : Gtk.Box {
	
	public Gtk.Entry name_entry;
	public Gtk.Entry uri_entry;
	public Gtk.Box button_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL,4);
	public Gtk.Button cancel_button = new Gtk.Button.with_label("Cancel");
	public Gtk.Button add_button = new Gtk.Button.with_label("Add");
	
	public Dragonstone.Registry.BookmarkRegistry bookmark_registry;
	
	public signal void bookmark_added(Dragonstone.Registry.BookmarkRegistryEntry bookmark);
	
	public BookmarkAdder(Dragonstone.Registry.BookmarkRegistry bookmark_registry){
		this.bookmark_registry = bookmark_registry;
		this.orientation = Gtk.Orientation.VERTICAL;
		this.spacing = 4;
		name_entry = new Gtk.Entry();
		uri_entry = new Gtk.Entry();
		pack_start(name_entry);
		pack_start(uri_entry);
		pack_start(button_box);
		button_box.set_homogeneous(true);
		button_box.pack_start(cancel_button);
		button_box.pack_start(add_button);
		add_button.get_style_context().add_class("suggested-action");
		add_button.sensitive = false;
		add_button.clicked.connect(on_activate);
		name_entry.activate.connect(on_activate);
		uri_entry.activate.connect(on_activate);
		name_entry.buffer.deleted_text.connect(update_addbutton_sensitive);
		name_entry.buffer.inserted_text.connect(update_addbutton_sensitive);
		uri_entry.buffer.deleted_text.connect(update_addbutton_sensitive);
		uri_entry.buffer.inserted_text.connect(update_addbutton_sensitive);
	}
	
	public void update_addbutton_sensitive(){
		this.add_button.sensitive = (name_entry.text != "" && uri_entry.text != "");
	}
	
	public void set_values(string name, string uri){
		this.name_entry.text = name;
		this.uri_entry.text = uri;
	}
	
	public void on_activate(){
		if (name_entry.text != "" && uri_entry.text != ""){
			var bookmark = bookmark_registry.add_bookmark(name_entry.text,uri_entry.text);
			if (bookmark != null){
				bookmark_added(bookmark);
			}
		}
	}
	
	public Dragonstone.Widget.BookmarkAdder localize(Dragonstone.Registry.TranslationRegistry translation){
		name_entry.placeholder_text = translation.localize("add_bookmark.name.placeholder");
		uri_entry.placeholder_text = translation.localize("add_bookmark.uri.placeholder");
		cancel_button.label = translation.localize("action.cancel");
		add_button.label = translation.localize("add_bookmark.add_bookmark.label");
		return this;
	}
}

public class Dragonstone.Widget.BookmarkEditor : Gtk.Box {
	
	public Gtk.Entry name_entry;
	public Gtk.Entry uri_entry;
	public Gtk.Box button_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL,4);
	public Gtk.Button cancel_button = new Gtk.Button.with_label("Cancel");
	public Gtk.Button save_button = new Gtk.Button.with_label("Save");
	public Gtk.Button delete_button = new Gtk.Button.with_label("Delete");
	
	public Dragonstone.Registry.BookmarkRegistry bookmark_registry;
	Dragonstone.Registry.BookmarkRegistryEntry? bookmark = null;
	
	public signal void done_editing(Dragonstone.Registry.BookmarkRegistryEntry bookmark,bool triggered_by_save=false);
	
	public BookmarkEditor(Dragonstone.Registry.BookmarkRegistry bookmark_registry){
		this.bookmark_registry = bookmark_registry;
		this.orientation = Gtk.Orientation.VERTICAL;
		this.spacing = 4;
		name_entry = new Gtk.Entry();
		uri_entry = new Gtk.Entry();
		pack_start(name_entry);
		pack_start(uri_entry);
		pack_start(button_box);
		button_box.set_homogeneous(true);
		button_box.pack_start(delete_button);
		button_box.pack_start(cancel_button);
		button_box.pack_start(save_button);
		save_button.get_style_context().add_class("suggested-action");
		save_button.clicked.connect(() => {
			save_name();
			save_uri();
			done_editing(bookmark,true);
		});
		delete_button.get_style_context().add_class("destructive-action");
		delete_button.clicked.connect(() => {
			bookmark_registry.remove_bookmark(bookmark);
			done_editing(bookmark);
		});
		cancel_button.clicked.connect(() => {
			done_editing(bookmark);
		});
		name_entry.activate.connect(save_name);
		uri_entry.activate.connect(save_uri);
	}
	
	public void edit_bookmark(Dragonstone.Registry.BookmarkRegistryEntry? bookmark){
		this.bookmark = bookmark;
		if (bookmark == null){
			this.name_entry.text = "";
			this.uri_entry.text = "";
			this.sensitive = false;
		} else {
			this.name_entry.text = bookmark.name;
			this.uri_entry.text = bookmark.uri;
			this.sensitive = true;
		}
	}
	
	public void save_name(){
		if (bookmark != null){
			bookmark.name = name_entry.text;
			bookmark_registry.bookmark_modified(bookmark);
		}
	}
	
	public void save_uri(){
		if (bookmark != null){
			bookmark.uri = uri_entry.text;
			bookmark_registry.bookmark_modified(bookmark);
		}
	}	
	
	public Dragonstone.Widget.BookmarkEditor localize(Dragonstone.Registry.TranslationRegistry translation){
		name_entry.placeholder_text = translation.localize("edit_bookmark.name.placeholder");
		uri_entry.placeholder_text = translation.localize("edit_bookmark.uri.placeholder");
		cancel_button.label = translation.localize("action.cancel");
		save_button.label = translation.localize("edit_bookmark.save_bookmark.label");
		delete_button.label = translation.localize("edit_bookmark.delete_bookmark.label");
		return this;
	}
}
