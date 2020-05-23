public class Dragonstone.View.Bookmarks : Gtk.Box, Dragonstone.IView {
	
	private Dragonstone.Request? request = null;
	private Dragonstone.Tab? tab = null;
	private Dragonstone.Registry.TranslationRegistry? translation = null;
	private Dragonstone.Registry.BookmarkRegistry bookmark_registry;
	
	private Gtk.ListStore liststore = new Gtk.ListStore(2,typeof(string),typeof(string));
	
	private Gtk.TreeView treeview;
	private Gtk.Button addbutton;
	
	/*
		Columns:
		0: uri
		1: name
	*/
	
	public Bookmarks(Dragonstone.Registry.BookmarkRegistry bookmark_registry, Dragonstone.Registry.TranslationRegistry? translation){
		this.translation = translation;
		if (translation == null){
			this.translation = new Dragonstone.Registry.TranslationLanguageRegistry();
		}
		addbutton.label = translation.localize("view.boomarks.add.label");
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
		foreach (var entry in bookmark_registry.entrys){
			
		}
		//treeview
		treeview = new Gtk.TreeView();
		treeview.get_selection().set_mode(Gtk.SelectionMode.SINGLE);
		treeview.set_model(liststore);
		treeview.insert_column_with_attributes(-1,translation.localize("view.interactive/bookmarks.column.name.head"), new Gtk.CellRendererText (), "text", 1);
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
	
	public bool canHandleCurrentResource(){
		if (request == null){
			return false;
		}else{
			return request.status == "interactive/bookmarks";
		}
	}
	
	private string? get_uri_from_model(Gtk.TreeModel model, Gtk.TreeIter iter){
		Value urival;
		model.get_value(iter,0,out urival);
		return urival.get_string();
	}
	
	public void cleanup(){
		
	}
	
}
