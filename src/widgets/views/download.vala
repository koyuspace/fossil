public class Dragonstone.View.Download : Gtk.Box, Dragonstone.IView {
	
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
		this.orientation = Gtk.Orientation.VERTICAL;
		var name_attr_list = new Pango.AttrList();
		name_attr_list.insert(new Pango.AttrSize(16000));
		name_label.attributes = name_attr_list;
		save_button.get_style_context().add_class("suggested-action");
		var center_box = new Gtk.Box(Gtk.Orientation.VERTICAL,8);
		center_box.margin = 16;
		var label = new Gtk.Label(this.title); //TOTRANSLATE
		var icon = new Gtk.Image.from_icon_name("document-save-symbolic",Gtk.IconSize.DIALOG);
		icon.icon_size=6;
		var labelAttrList = new Pango.AttrList();
		labelAttrList.insert(new Pango.AttrSize(48000));
		label.attributes = labelAttrList;
		center_box.pack_start(icon);
		center_box.pack_start(label);
		center_box.pack_start(name_label);
		center_box.pack_start(save_button);
		center_box.pack_start(open_button);
		this.set_center_widget(center_box);
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
