private class Dragonstone.GtkUi.LegacyWidget.TextEntrySingleLine : Gtk.Bin {

	public signal void submit(string text);
	public Gtk.Entry entry;
	public Gtk.Button button;
	
	public TextEntrySingleLine(string placeholder, string text, string icon_name, int min_width = 0){
		var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL,4);
		box.homogeneous = false;
		box.margin_start = 4;
		entry = new Gtk.Entry();
		entry.placeholder_text = placeholder;
		entry.activate.connect(on_activate);
		entry.text = text;
		if (min_width < 0) {
			min_width = -min_width;
			if (placeholder.char_count() > min_width) { min_width = placeholder.char_count()+1;}
		}
		if (min_width > 0){
			entry.set_width_chars(min_width);
		}
		button = new Gtk.Button.from_icon_name(icon_name);
		button.clicked.connect(on_activate);
		button.halign = Gtk.Align.START;
		box.pack_start(entry);
		box.pack_start(button);
		box.halign = Gtk.Align.FILL;
		add(box);
	}
	
	private void on_activate(){
		submit(entry.text);
	}
}
