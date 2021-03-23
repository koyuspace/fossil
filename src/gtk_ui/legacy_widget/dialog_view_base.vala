public class Fossil.GtkUi.LegacyWidget.DialogViewBase : Gtk.Box {
	protected Gtk.Box outer_box = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
	protected Gtk.Box center_box = new Gtk.Box(Gtk.Orientation.VERTICAL,8);
	protected Gtk.ScrolledWindow scrolled_window = new Gtk.ScrolledWindow(null,null);
	protected Gtk.Button backbutton = new Gtk.Button.from_icon_name("go-previous-symbolic");
	protected Gtk.ActionBar actionbar = new Gtk.ActionBar();
	
	construct{
		center_box.margin = 16;
		this.orientation = Gtk.Orientation.VERTICAL;
		outer_box.set_center_widget(center_box);
		scrolled_window.add(outer_box);
		actionbar.pack_start(backbutton);
		pack_start(actionbar);
		pack_start(scrolled_window);
		this.set_child_packing(actionbar,false,true,0,Gtk.PackType.START);
		this.set_child_packing(scrolled_window,true,true,0,Gtk.PackType.START);
		this.show();
		this.scrolled_window.show_all();
		this.actionbar.hide();
		this.backbutton.hide();
	}
	
	public void use_as_subview(Fossil.GtkUi.LegacyWidget.Tab tab){
		this.actionbar.show();
		this.backbutton.show();
		this.backbutton.clicked.connect(tab.go_back_subview);
	}
	
	public override void show_all(){
		outer_box.show_all();
	}
	
	public void append_widget(Gtk.Widget widget){
		center_box.pack_start(widget);
	}
	
	public Gtk.Image append_big_icon(string icon_name){
		var icon = new Gtk.Image.from_icon_name(icon_name,Gtk.IconSize.DIALOG);
		icon.set_pixel_size(icon.scale_factor*64);
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
