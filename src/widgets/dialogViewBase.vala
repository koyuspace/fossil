public class Dragonstone.Widget.DialogViewBase : Gtk.ScrolledWindow {
	protected Gtk.Box outer_box = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
	protected Gtk.Box center_box = new Gtk.Box(Gtk.Orientation.VERTICAL,4);
	
	construct{
		center_box.margin = 16;
		outer_box.set_center_widget(center_box);
		add(outer_box);
		this.show_all();
	}
	
	public void append_widget(Gtk.Widget widget){
		center_box.pack_start(widget);
	}
	
	public Gtk.Image append_big_icon(string icon_name){
		var icon = new Gtk.Image.from_icon_name("media-playlist-shuffle-symbolic",Gtk.IconSize.DIALOG);
		icon.icon_size=6;
		append_widget(icon);
		return icon;
	}
	
	public Gtk.Label append_label(string text){
		var label = new Gtk.Label(text);
		label.justify = Gtk.Justification.CENTER;
		label.wrap_mode = Pango.WrapMode.WORD_CHAR;
		label.wrap = true;
		append_widget(label);
		return label;
	}
	
	public Gtk.Label append_big_headline(string text){
		var label_attr_list = new Pango.AttrList();
		label_attr_list.insert(new Pango.AttrSize(48000));
		var label = append_label(text);
		label.attributes = label_attr_list;
		return label;
	}

	public Gtk.Label append_small_headline(string text){
		var label_attr_list = new Pango.AttrList();
		label_attr_list.insert(new Pango.AttrSize(16000));
		var label_font_description = new Pango.FontDescription();
		label_font_description.set_style(Pango.Style.OBLIQUE);
		label_attr_list.insert(new Pango.AttrFontDesc(label_font_description));
		var label = append_label(text);
		label.attributes = label_attr_list;
		return label;
	}

}
