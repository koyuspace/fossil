public class Dragonstone.GtkUi.View.UploadFile : Dragonstone.GtkUi.LegacyWidget.DialogViewBase, Dragonstone.GtkUi.Interface.LegacyView {

	private Dragonstone.Request? request = null;
	private Dragonstone.GtkUi.LegacyWidget.Tab tab = null;
	private Dragonstone.Registry.MimetypeGuesser mimeguesser;
	private File? choosen_file = null;
	private string? choosen_file_path = null;
	
	private Gtk.FileChooserButton file_chooser_button;
	private Gtk.Button clear_button;
	private Gtk.Button upload_button;
	private Gtk.Button upload_text_button;	
		
	public UploadFile(Dragonstone.Registry.TranslationRegistry translation, Dragonstone.Registry.MimetypeGuesser? mimeguesser){
		if (mimeguesser == null){
			this.mimeguesser = new Dragonstone.Registry.MimetypeGuesser.default_configuration();
		} else {
			this.mimeguesser = mimeguesser;
		}
		this.append_big_icon("document-open-symbolic");
		this.append_big_headline(translation.localize("view.upload_file.title"));
		var file_chooser_label = translation.localize("view.upload_file.file_chooser.label");
		this.file_chooser_button = new Gtk.FileChooserButton(file_chooser_label,Gtk.FileChooserAction.OPEN);
		this.file_chooser_button.local_only = true;
		this.clear_button = new Gtk.Button.from_icon_name("edit-clear-symbolic");
		this.clear_button.get_style_context().add_class("destructive-action");
		this.clear_button.sensitive = false;
		var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL,4);
		box.pack_start(file_chooser_button);
		box.pack_start(clear_button);
		box.set_child_packing(clear_button,false,false,0,Gtk.PackType.START);
		box.set_child_packing(file_chooser_button,true,true,0,Gtk.PackType.START);
		this.append_widget(box);
		var upload_button_label = translation.localize("view.upload_file.uploadbutton.label");
		this.upload_button = new Gtk.Button.with_label(upload_button_label);
		this.upload_button.get_style_context().add_class("suggested-action");
		this.append_widget(upload_button);
		//this.append_small_headline(translation.localize("view.upload_file.or"));
		var upload_text_button_label = translation.localize("view.upload_file.upload_text.label");
		this.upload_text_button = new Gtk.Button.with_label(upload_text_button_label);
		this.append_widget(upload_text_button);
		this.show_all();
		var error_unknown_size = translation.localize("view.upload_file.error.unknown_size");
		//hook up events
		file_chooser_button.file_set.connect(() => {
			this.choosen_file = this.file_chooser_button.get_file();
			this.choosen_file_path = this.choosen_file.get_path();
			if (this.choosen_file_path != null){
				int64? size = null;
				try {
					var fileinfo = choosen_file.query_info(GLib.FileAttribute.STANDARD_SIZE,GLib.FileQueryInfoFlags.NONE);
					size = fileinfo.get_size();
				} catch(GLib.Error e) {
					print(@"[gtk][upload_file][error] cannot determine filesize for $(request.resource.filepath)\n");
				}
				string sizelabel = error_unknown_size;
				if (size != null){
					float kb = size/1000;
					sizelabel = @"$kb KB";
				}
				this.upload_button.label = @"$upload_button_label ($sizelabel)";
				this.upload_button.show();
				this.clear_button.sensitive = true;
				this.upload_text_button.hide();
			}
		});
		upload_button.clicked.connect(() => {
			if (choosen_file_path != null){
				var basename = choosen_file.get_basename();
				if (basename == null){
					basename = choosen_file_path;
				}
				var resource = new Dragonstone.Resource(null,choosen_file_path,false);
				resource.add_metadata(this.mimeguesser.get_closest_match(basename,"text/plain"),basename);
				this.tab.upload_to_uri(this.request.uri,resource);
			}
		});
		clear_button.clicked.connect(() => {
			this.file_chooser_button.unselect_all();
			this.upload_button.hide();
			this.clear_button.sensitive = false;
			this.upload_text_button.show();
		});
		upload_text_button.clicked.connect(() => {
			this.tab.open_subview("upload.text");
		});
		this.upload_button.hide();
	}
	
	public bool display_resource(Dragonstone.Request request, Dragonstone.GtkUi.LegacyWidget.Tab tab, bool as_subview){
		if (!(request.status.has_prefix("interactive/upload"))) {return false;}
		this.request = request;
		this.upload_button.set_tooltip_text(request.uri);
		this.tab = tab;
		return true;
	}
	
	public bool canHandleCurrentResource(){
		if (request == null){
			return false;
		}else{
			return request.status.has_prefix("interactive/upload");
		}
	}
}

/*
int64? size = null;
try {
	var fileinfo = file.query_info(GLib.FileAttribute.STANDARD_SIZE,GLib.FileQueryInfoFlags.NONE);
	size = fileinfo.get_size();
} catch(Error e) {
	print(@"[gtk][upload_file][error] cannot determine filesize for $(request.resource.filepath)\n");
}
*/
