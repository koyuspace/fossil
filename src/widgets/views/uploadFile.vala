public class Dragonstone.View.UploadFile : Dragonstone.Widget.DialogViewBase, Dragonstone.IView {

	private Dragonstone.Request? request = null;
	private Dragonstone.Tab tab = null;
	private Dragonstone.Registry.MimetypeGuesser mimeguesser;
	private File? choosen_file = null;
	private string? choosen_file_path = null;
	
	private Gtk.FileChooserButton file_chooser_button;
	private Gtk.Label size_label;
	private Gtk.Button upload_button;
	
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
		this.append_widget(file_chooser_button);
		this.size_label = this.append_label("");
		var upload_button_label = translation.localize("view.upload_file.uploadbutton.label");
		this.upload_button = new Gtk.Button.with_label(upload_button_label);
		this.upload_button.get_style_context().add_class("suggested-action");
		upload_button.sensitive = false;
		this.append_widget(upload_button);
		this.show_all();
		var error_remote_files_not_supported = translation.localize("view.upload_file.error.no_remote_files");
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
				if (size != null){
					float kb = size/1000;
					this.size_label.label = @"$kb KB";
				} else {
					this.size_label.label = error_unknown_size;
				}
				this.upload_button.sensitive = true;
			} else {
				print("[gtk][upload][error] uploading remote files is not supported");
				this.size_label.label = error_remote_files_not_supported;
				this.upload_button.sensitive = false;
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
	}
	
	public bool displayResource(Dragonstone.Request request, Dragonstone.Tab tab, bool as_subview){
		if (!(request.status.has_prefix("interactive/upload"))) {return false;}
		this.request = request;
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
