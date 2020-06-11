public class Dragonstone.Widget.RequestArgumentDisplay : Gtk.Box {
	construct {
		this.orientation = Gtk.Orientation.VERTICAL;
		this.spacing = 4;
	}
	
	public RequestArgumentDisplay(Dragonstone.Request request){
		foreach (string key in request.arguments.get_keys()){
			string? val = request.arguments.get(key);
			if (val != null){
				this.pack_start(new RequestArgumentItem(key,val));
			}
		}
		this.show_all();
	}
	
}

public class Dragonstone.Widget.RequestArgumentItem : Gtk.Box {
	public RequestArgumentItem(string key, string val){
		this.orientation = Gtk.Orientation.HORIZONTAL;
		this.spacing = 8;
		this.homogeneous = true;
		var key_label = new Gtk.Label(key);
		key_label.halign = Gtk.Align.END;
		key_label.get_style_context().add_class("dim-label");
		var value_label = new Gtk.Label(val);
		value_label.halign = Gtk.Align.START;
		this.pack_start(key_label);
		this.pack_start(value_label);
		this.show_all();
	}
}
