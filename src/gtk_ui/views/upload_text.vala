public class Fossil.GtkUi.View.UploadText : Gtk.Box, Fossil.GtkUi.Interface.LegacyView {
	
	private Fossil.Request? request = null;
	private Fossil.GtkUi.LegacyWidget.Tab? tab = null;
	private Fossil.Registry.MimetypeGuesser mimeguesser;
	private string tempfile;
	private Fossil.Resource resource;
	private bool use_tempfile = true;
	private string open_file_localized = "";
	private bool uploading = false;
	
	private Gtk.ActionBar actionbar = new Gtk.ActionBar();
	private Gtk.ScrolledWindow scrolled_window = new Gtk.ScrolledWindow(null,null);
	private Gtk.TextView textview = new Gtk.TextView();
	
	private Gtk.Button backbutton = new Gtk.Button.from_icon_name("go-previous-symbolic");
	private Gtk.Button open_button = new Gtk.Button.from_icon_name("document-open-symbolic");
	private Gtk.Button save_button = new Gtk.Button.from_icon_name("document-save-symbolic");
	private Gtk.Button upload_button;
	
	public UploadText(string tempfile, Fossil.Registry.TranslationRegistry translation, Fossil.Registry.MimetypeGuesser? mimeguesser){
		if (mimeguesser == null){
			this.mimeguesser = new Fossil.Registry.MimetypeGuesser.default_configuration();
		} else {
			this.mimeguesser = mimeguesser;
		}
		//backbutton
		backbutton.clicked.connect(() => {
			if (this.tab != null){
				this.tab.go_back_subview();
			}
		});
		this.tempfile = tempfile;
		resource = new Fossil.Resource(null,tempfile,true,false);
		resource.derive_uri_from_filepath();
		var upload_button_label = translation.localize("view.upload_text.uploadbutton.label");
		var open_button_tooltip = translation.localize("view.upload_text.openbutton.tooltip");
		var save_button_tooltip = translation.localize("view.upload_text.savebutton.tooltip");
		open_file_localized = translation.localize("view.upload_text.open_file_dialog.title");
		//setup textview
		textview.wrap_mode = Gtk.WrapMode.WORD;
		textview.set_monospace(true);
		textview.set_left_margin(4);
		//initialize actionsbar buttons
		upload_button = new Gtk.Button.with_label(upload_button_label);
		upload_button.get_style_context().add_class("suggested-action");
		upload_button.sensitive = false;
		open_button.set_tooltip_text(open_button_tooltip);
		save_button.set_tooltip_text(save_button_tooltip);
		//put buttons on actionsbar
		actionbar.pack_start(backbutton);
		actionbar.pack_start(open_button);
		actionbar.pack_start(save_button);
		actionbar.pack_end(upload_button);
		//initialize box
		this.orientation = Gtk.Orientation.VERTICAL;
		scrolled_window.add(textview);
		this.pack_start(actionbar);
		this.pack_start(scrolled_window);
		this.set_child_packing(actionbar,false,true,0,Gtk.PackType.START);
		this.set_child_packing(scrolled_window,true,true,0,Gtk.PackType.START);
		show_all();
		//connect signals
		open_button.clicked.connect(open_file);
		save_button.clicked.connect(download);
		upload_button.clicked.connect(upload);
		textview.buffer.changed.connect(textbuffer_changed);
	}
	
	private bool was_empty = true;
	
	private void textbuffer_changed(){
		if (!use_tempfile){
			use_tempfile = true;
			resource.update_filepath(tempfile,true);
			resource.derive_uri_from_filepath();
		}
		bool empty = textview.buffer.get_char_count() == 0;
		if (empty != was_empty){
			was_empty = empty;
			upload_button.sensitive = !empty;
			if (empty){
				open_button.get_style_context().remove_class("destructive-action");
				backbutton.get_style_context().remove_class("destructive-action");
			} else {
				open_button.get_style_context().add_class("destructive-action");
				backbutton.get_style_context().add_class("destructive-action");
			}
		}
	}
	
	private void open_file(){
		if (tab != null){
			var filechooser = new Gtk.FileChooserNative(open_file_localized,this.tab.parent_window,Gtk.FileChooserAction.OPEN,"_Open","_Cancel");
			filechooser.set_current_folder(Environment.get_home_dir());
			filechooser.set_select_multiple(false);
			filechooser.local_only = true;
			filechooser.select_multiple = false;
			var response = filechooser.run();
			if (response == Gtk.ResponseType.ACCEPT){
				textview.sensitive = false;
				File file = filechooser.get_file();
				string text = "";
				try {
					var data_input_stream = new DataInputStream (file.read ());
					string line;
					while ((line = data_input_stream.read_line (null)) != null) {
						if (line.validate(line.length)){
							text = text+line+"\n";
						}
					}
				} catch (GLib.Error e) {
					text = "ERROR WHILE READING FILE:\n"+e.message;
				}
				textview.buffer.text = text;
				var choosen_file_path = file.get_path();
				if (choosen_file_path != null){
					resource.update_filepath(choosen_file_path,false);
					resource.derive_uri_from_filepath();
					this.use_tempfile = false;
				} else {
					print("[gtk][upload_text][error]choosen filepath is null!");
				}
				textview.sensitive = true;
			}
		}
	}
	
	private bool write_tempfile(){
		try {
			var file = File.new_for_path(tempfile);
			var file_output_stream = file.create(FileCreateFlags.PRIVATE | FileCreateFlags.REPLACE_DESTINATION);
			file_output_stream.write(textview.buffer.text.data);
			file_output_stream.close();
			return true;
		}catch(GLib.Error e){
			print("[gtk][upload_text][error] Error while writing to temfile"+e.message);
			return false;
		}
	}
	
	private void delete_tempfile(){
		var file = File.new_for_path(this.tempfile);
		if (file.query_exists()){
			try{
				file.delete();
			}catch( GLib.Error e ){
				//do nothing
			}
		}
	}
	
	private void upload(){
		resource.lock_resource();
		bool error = false;
		if (use_tempfile){
			error = !write_tempfile();
		} else {
			delete_tempfile();
		}
		if (!error){
			//print(@"[gtk][upload_text][debug] uploading: $(resource.uri) $(resource.filepath) $(resource.is_temporary)\n");
			resource.add_metadata(this.mimeguesser.get_closest_match(resource.filepath,"text/plain"),resource.filepath);
			this.uploading = true;
			this.tab.upload_to_uri(this.request.uri,resource);
		}
	}
	
	private void download(){
		if (tab != null){
			if (use_tempfile){
				if (write_tempfile()) {
					tab.download();
				} else {
					print(@"[gtk][upload_text][error] unable to write to tempfile, not downloading");
				}
			} else {
				tab.download();
			}
		}
	}
	
	public bool display_resource(Fossil.Request request, Fossil.GtkUi.LegacyWidget.Tab tab, bool as_subview){
		if (!(request.status.has_prefix("interactive/upload"))) {return false;}
		this.request = request;
		this.tab = tab;
		request.setResource(resource, "text_upload_view", request.status, request.substatus);
		this.upload_button.set_tooltip_text(request.uri);
		if (!as_subview){
			backbutton.hide();
		}
		return true;
	}
	
	public bool canHandleCurrentResource(){
		if (request == null){
			return false;
		}else{
			return request.status.has_prefix("interactive/upload");
		}
	}
	
	public void cleanup(){
		if (!uploading || !use_tempfile){
			delete_tempfile();
		}
	}
	
}
