public class Dragonstone.View.UnknownUriScheme : Gtk.Bin, Dragonstone.IView {
	
	private Dragonstone.Request request = null;
	private Gtk.Label nameLabel = new Gtk.Label("");
	private Gtk.Button redirbutton = new Gtk.Button.with_label("");
	private string title = "Unknown Uri Scheme";
	
	public UnknownUriScheme(Dragonstone.Registry.TranslationRegistry? translation = null) {
		if(translation != null){
			this.title = translation.localize("view.dragonstone.unknown_uri_scheme.title");
			this.redirbutton.label = translation.localize("action.open_uri_externally");
		}
		nameLabel.valign = Gtk.Align.START;
		redirbutton.get_style_context().add_class("suggested-action");
		var outerBox = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		var centerBox = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		var label = new Gtk.Label(title);
		var icon = new Gtk.Image.from_icon_name("dialog-question-symbolic",Gtk.IconSize.DIALOG);
		icon.icon_size=6;
		var labelAttrList = new Pango.AttrList();
		labelAttrList.insert(new Pango.AttrSize(48000));
		label.attributes = labelAttrList;
		label.wrap_mode = Pango.WrapMode.WORD_CHAR;
		label.wrap = true;
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
		if (request.status != "error/uri/unknownScheme") {return false;}
		this.request = request;
		redirbutton.clicked.connect(() => {
			tab.open_uri_externally(this.request.uri);
		});
		return true;
	}
	
	public bool canHandleCurrentResource(){
		if (request == null){
			return false;
		}else{
			return request.status == "error/uri/unknownScheme";
		}
	}
	
}
