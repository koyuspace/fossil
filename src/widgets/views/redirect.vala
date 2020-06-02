public class Dragonstone.View.Redirect : Gtk.Box, Dragonstone.IView {
	
	private Dragonstone.Request request = null;
	private Gtk.Button redirbutton = new Gtk.Button();
	private Gtk.Label buttonlabel = new Gtk.Label("");
	private string title = "Redirect to";
	
	public Redirect(Dragonstone.Registry.TranslationRegistry? translation = null) {
		if(translation != null){
			this.title = translation.localize("view.dragonstone.redirect.title");
		}
		this.orientation = Gtk.Orientation.VERTICAL;
		redirbutton.get_style_context().add_class("suggested-action");
		redirbutton.add(buttonlabel);
		buttonlabel.wrap_mode = Pango.WrapMode.WORD_CHAR;
		buttonlabel.wrap = true;
		var center_box = new Gtk.Box(Gtk.Orientation.VERTICAL,8);
		center_box.margin = 16;
		var label = new Gtk.Label(title);
		var icon = new Gtk.Image.from_icon_name("media-playlist-shuffle-symbolic",Gtk.IconSize.DIALOG);
		icon.icon_size=6;
		var label_attr_list = new Pango.AttrList();
		label_attr_list.insert(new Pango.AttrSize(48000));
		label.attributes = label_attr_list;
		center_box.pack_start(icon);
		center_box.pack_start(label);
		center_box.pack_start(redirbutton);
		this.set_center_widget(center_box);
		show_all();
	}
	
	public bool displayResource(Dragonstone.Request request,Dragonstone.Tab tab){
		if (!(request.status.has_prefix("redirect"))) {return false;}
		this.request = request;
		buttonlabel.label = request.substatus;
		redirbutton.clicked.connect(() => {
			tab.redirect(this.request.substatus);
		});
		return true;
	}
	
	public bool canHandleCurrentResource(){
		if (request == null){
			return false;
		}else{
			return request.status.has_prefix("redirect");
		}
	}
	
}
