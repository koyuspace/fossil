public class Dragonstone.View.Download : Gtk.Bin, Dragonstone.IView {
	
	private Dragonstone.Request request = null;
	private Gtk.Label nameLabel = new Gtk.Label("");
	private Gtk.Button save_button = new Gtk.Button.with_label("");
	
	construct {
		nameLabel.valign = Gtk.Align.START;
		save_button.get_style_context().add_class("suggested-action");
		var outerBox = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		var centerBox = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		var label = new Gtk.Label("Downloaded!"); //TOTRANSLATE
		var icon = new Gtk.Image.from_icon_name("document-save-symbolic",Gtk.IconSize.DIALOG);
		icon.icon_size=6;
		var labelAttrList = new Pango.AttrList();
		labelAttrList.insert(new Pango.AttrSize(48000));
		label.attributes = labelAttrList;
		centerBox.pack_start(icon);
		centerBox.pack_start(label);
		centerBox.pack_start(save_button);
		outerBox.set_center_widget(centerBox);
		outerBox.pack_start(nameLabel);
		var empty = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		outerBox.pack_end(empty);
		add(outerBox);
	}
	
	public bool displayResource(Dragonstone.Request request,Dragonstone.Tab tab){
		if (!(request.status == "success")) {return false;}
		this.request = request;
		//nameLabel.label = request.uri;
		var filename = Dragonstone.Util.Uri.get_filename(request.uri);
		save_button.label = @"Save $(filename)";
		save_button.clicked.connect(() => {
			tab.download();
		});
		return true;
	}
	
	public bool canHandleCurrentResource(){
		if (request == null){
			return false;
		}else{
			return request.status == "success";
		}
	}
	
}
