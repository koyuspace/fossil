public class Fossil.GtkUi.LegacyWidget.BookmarkAdder : Gtk.Box {
	
	public Gtk.Entry name_entry;
	public Gtk.Entry uri_entry;
	public Gtk.Box button_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL,4);
	public Gtk.Button cancel_button = new Gtk.Button.with_label("Cancel");
	public Gtk.Button add_button = new Gtk.Button.with_label("Add");
	
	public Fossil.Registry.BookmarkRegistry bookmark_registry;
	
	public signal void bookmark_added(Fossil.Registry.BookmarkRegistryEntry bookmark);
	
	public BookmarkAdder(Fossil.Registry.BookmarkRegistry bookmark_registry){
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
		set_values("","");
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
	
	public Fossil.GtkUi.LegacyWidget.BookmarkAdder localize(Fossil.Registry.TranslationRegistry translation){
		name_entry.placeholder_text = translation.localize("add_bookmark.name.placeholder");
		uri_entry.placeholder_text = translation.localize("add_bookmark.uri.placeholder");
		cancel_button.label = translation.localize("action.cancel");
		add_button.label = translation.localize("add_bookmark.add_bookmark.label");
		return this;
	}
}
