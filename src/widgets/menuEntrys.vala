public class Dragonstone.Widget.MenuButton : Gtk.Button {
	public MenuButton(string labeltext){
		var label = new Gtk.Label(labeltext);
		label.single_line_mode = true;
		label.set_justify(Gtk.Justification.LEFT);
		label.halign = Gtk.Align.START;
		halign = Gtk.Align.FILL;
		add(label);
		set_css_name("modelbutton");
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
		box.set_child_packing(label,true,true,0,Gtk.PackType.START);
		box.set_child_packing(switch_widget,false,true,0,Gtk.PackType.END);
		add(box);
		get_style_context().add_class("flat");
		set_css_name("modelbutton");
		this.clicked.connect(() => {
			switch_widget.set_state(!switch_widget.get_state());
		});
	}
}

public class Dragonstone.Widget.MenuBigTextDisplay : Gtk.Label {
	
	public string text {
		get {
			return this.label;
		}
		set {
			this.label = value;
		}
	}
	
	public MenuBigTextDisplay(string text){
		set_line_wrap(true);
		wrap_mode = Pango.WrapMode.WORD_CHAR;
		wrap = true;
		max_width_chars = 40;
		/*monospace = true;
		left_margin = 2;
		right_margin = 2;
		editable = false;*/
		selectable = true;
		set_css_name("entry");
		get_style_context().remove_class("view");
		this.text = text;
	}
}
