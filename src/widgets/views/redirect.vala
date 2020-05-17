public class Dragonstone.View.Redirect : Gtk.Bin, Dragonstone.IView {
	
	private Dragonstone.Request request = null;
	private Gtk.Label nameLabel = new Gtk.Label("");
	private Gtk.Button redirbutton = new Gtk.Button.with_label("");
	private string title = "Redirect to";
	
	public Redirect(Dragonstone.Registry.TranslationRegistry? translation = null) {
		if(translation != null){
			this.title = translation.localize("view.dragonstone.redirect.title");
		}
		nameLabel.valign = Gtk.Align.START;
		redirbutton.get_style_context().add_class("suggested-action");
		var outerBox = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		var centerBox = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		var label = new Gtk.Label(title);
		var icon = new Gtk.Image.from_icon_name("media-playlist-shuffle-symbolic",Gtk.IconSize.DIALOG);
		icon.icon_size=6;
		var labelAttrList = new Pango.AttrList();
		labelAttrList.insert(new Pango.AttrSize(48000));
		label.attributes = labelAttrList;
		centerBox.pack_start(icon);
		centerBox.pack_start(label);
		centerBox.pack_start(redirbutton);
		outerBox.set_center_widget(centerBox);
		outerBox.pack_start(nameLabel);
		var empty = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		outerBox.pack_end(empty);
		add(outerBox);
		show_all();
	}
	
	public bool displayResource(Dragonstone.Request request,Dragonstone.Tab tab){
		if (!(request.status.has_prefix("redirect"))) {return false;}
		this.request = request;
		redirbutton.label = request.substatus;
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
