public class Dragonstone.View.Download : Gtk.Bin, Dragonstone.IView {
	
	private Dragonstone.Request request = null;
	private Gtk.Label name_label = new Gtk.Label("");
	private Gtk.Button save_button = new Gtk.Button.with_label("Save");
	private Gtk.Button open_button = new Gtk.Button.with_label("Open in external viewer");
	private string title = "Downloaded!";
	
	public Download(Dragonstone.Registry.TranslationRegistry? translation = null) {
		if (translation != null){
			save_button.label = translation.localize("view.dragonstone.download.save_button.label");
			open_button.label = translation.localize("view.dragonstone.download.open_button.label");
			this.title = translation.localize("view.dragonstone.download.title");
		}
		name_label.valign = Gtk.Align.START;
		save_button.get_style_context().add_class("suggested-action");
		var outerBox = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		var centerBox = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		var label = new Gtk.Label(this.title); //TOTRANSLATE
		var icon = new Gtk.Image.from_icon_name("document-save-symbolic",Gtk.IconSize.DIALOG);
		icon.icon_size=6;
		var labelAttrList = new Pango.AttrList();
		labelAttrList.insert(new Pango.AttrSize(48000));
		label.attributes = labelAttrList;
		centerBox.pack_start(icon);
		centerBox.pack_start(label);
		centerBox.pack_start(name_label);
		centerBox.pack_start(save_button);
		centerBox.pack_start(open_button);
		outerBox.set_center_widget(centerBox);
		var empty = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		outerBox.pack_end(empty);
		add(outerBox);
	}
	
	public bool displayResource(Dragonstone.Request request,Dragonstone.Tab tab){
		if (!(request.status == "success")) {return false;}
		this.request = request;
		name_label.label = Dragonstone.Util.Uri.get_filename(request.uri);
		save_button.clicked.connect(() => {
			tab.download();
		});
		open_button.clicked.connect(() => {
			tab.open_resource_externally();
		});
		show_all();
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
