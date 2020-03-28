public class Dragonstone.Widget.MenuButton : Gtk.Button {
	public MenuButton(string labeltext){
		var label = new Gtk.Label(labeltext);
		label.single_line_mode = true;
		label.set_justify(Gtk.Justification.LEFT);
		label.halign = Gtk.Align.START;
		halign = Gtk.Align.FILL;
		add(label);
		get_style_context().add_class("flat");
	}
}

public class Dragonstone.Widget.MenuSwitch : Gtk.Button {

	public Gtk.Switch switch_widget;
	
	public MenuSwitch(string labeltext){
		var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL,1);
		var label = new Gtk.Label(labeltext);
		label.single_line_mode = true;
		label.set_justify(Gtk.Justification.LEFT);
		label.halign = Gtk.Align.START;
		box.pack_start(label);
		switch_widget = new Gtk.Switch();
		box.pack_end(switch_widget);
		halign = Gtk.Align.FILL;
		add(box);
		get_style_context().add_class("flat");
		
		this.clicked.connect(() => {
			switch_widget.set_state(!switch_widget.get_state());
		});
	}
}
