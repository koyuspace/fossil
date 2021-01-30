public class Dragonstone.GtkUi.Widget.BookmarkEditor : Gtk.Box {
	
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
	
	public Dragonstone.GtkUi.Widget.BookmarkEditor localize(Dragonstone.Registry.TranslationRegistry translation){
		name_entry.placeholder_text = translation.localize("edit_bookmark.name.placeholder");
		uri_entry.placeholder_text = translation.localize("edit_bookmark.uri.placeholder");
		cancel_button.label = translation.localize("action.cancel");
		save_button.label = translation.localize("edit_bookmark.save_bookmark.label");
		delete_button.label = translation.localize("edit_bookmark.delete_bookmark.label");
		return this;
	}
}
