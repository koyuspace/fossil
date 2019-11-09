public class Dragonstone.View.Redirect : Gtk.Bin, Dragonstone.IView {
	
	private Dragonstone.Resource resource = null;
	private Gtk.Label nameLabel = new Gtk.Label("");
	private Gtk.Button redirbutton = new Gtk.Button.with_label("");
	
	construct {
		nameLabel.valign = Gtk.Align.START;
		redirbutton.get_style_context().add_class("suggested-action");
		var outerBox = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		var centerBox = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		var label = new Gtk.Label("Redirect to"); //TOTRANSLATE
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
	}
	
	public bool displayResource(Dragonstone.Resource resource,Dragonstone.Tab tab){
		if (!(resource.resourcetype == Dragonstone.ResourceType.REDIRECT)) {return false;}
		this.resource = resource;
		redirbutton.label = resource.subtype;
		redirbutton.clicked.connect(() => {
			tab.redirect(this.resource.subtype);
		});
		return true;
	}
	
	public bool canHandleCurrentResource(){
		if (resource == null){
			return false;
		}else{
			return resource.resourcetype == Dragonstone.ResourceType.REDIRECT;
		}
	}
	
}
