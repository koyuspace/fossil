public class Fossil.GtkUi.LegacyWidget.InlineSearch : Gtk.Bin {

	public signal void go(string uri);
	private string uri_template;
	private Gtk.Entry entry;
	
	public InlineSearch(string htext, string uri_template){
		this.uri_template = uri_template;
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
		button.button_press_event.connect(handle_button_press);
		button.halign = Gtk.Align.START;
		//box.pack_start(icon);
		box.pack_start(entry);
		box.pack_start(button);
		box.halign = Gtk.Align.FILL;
		add(box);
		set_tooltip_text(uri_template);
	}
	
	private bool handle_button_press(Gdk.EventButton event){
		if (event.type == BUTTON_PRESS){
			if (event.button == 3 && uri_template.has_suffix("/postfile%09{search}")) { //right click
				var popover = new Fossil.GtkUi.LegacyWidget.InlineSearchPostB64FilePopoverEasterEgg(this,uri_template.substring(0,uri_template.length-11)+"b64");
				popover.set_relative_to(this);
				popover.popup();
				popover.show_all();
				return true;
			}
		}
		return false;
	}
	
	private void submit(){
		if (entry.text != ""){
			go(uri_template.replace("{search}",Uri.escape_string(entry.text)));
		}
	}
}
