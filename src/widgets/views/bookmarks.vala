public class Dragonstone.View.Bookmarks : Gtk.Box, Dragonstone.IView {
	
	private Dragonstone.Request? request = null;
	private Dragonstone.Tab? tab = null;
	private Dragonstone.Registry.TranslationRegistry? translation = null;
	private Dragonstone.Registry.BookmarkRegistry bookmark_registry;
	
	private HashTable<string,Gtk.TreeIter?> displayed_uids = new HashTable<string,Gtk.TreeIter?>(str_hash, str_equal);
	private string? selected_uid = null;
	private bool search_dirty = true;
	
	private Gtk.ListStore liststore = new Gtk.ListStore(3,typeof(string),typeof(string),typeof(string));
	
	private Gtk.TreeView treeview;
	private Gtk.Button addbutton = new Gtk.Button();
	private Gtk.Popover addpopover;
	private Dragonstone.Widget.BookmarkAdder addwidget;
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
		//add bookmarks
		bookmark_registry.bookmark_added.connect(append_entry);
		foreach (var entry in bookmark_registry.entrys){
			append_entry(entry);
		}
		//treeview
		treeview = new Gtk.TreeView();
		treeview.get_selection().set_mode(Gtk.SelectionMode.SINGLE);
		treeview.set_model(liststore);
		treeview.insert_column_with_attributes(-1,translation.localize("view.interactive/bookmarks.column.name.head"), new Gtk.CellRendererText (), "text", 2);
		treeview.insert_column_with_attributes(-1,translation.localize("view.interactive/bookmarks.column.uri.head"), new Gtk.CellRendererText (), "text", 1);
		treeview.insert_column_with_attributes(-1,translation.localize("view.interactive/bookmarks.column.uri.head"), new Gtk.CellRendererText (), "text", 0);
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
	
	public bool canHandleCurrentResource(){
		if (request == null){
			return false;
		}else{
			return request.status == "interactive/bookmarks";
		}
	}
	
	private string? get_uid_from_model(Gtk.TreeModel model, Gtk.TreeIter iter){
		Value urival;
		model.get_value(iter,0,out urival);
		return urival.get_string();
	}
	
	public void cleanup(){
		bookmark_registry.bookmark_added.disconnect(append_entry);
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
