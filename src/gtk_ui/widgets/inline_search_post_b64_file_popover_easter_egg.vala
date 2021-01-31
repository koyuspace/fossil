public class Dragonstone.GtkUi.Widget.InlineSearchPostB64FilePopoverEasterEgg : Gtk.Popover {
	
	private string base64_buffer = "";
	private string base_uri = "";
	private Dragonstone.GtkUi.Widget.InlineSearch parent_entry;
	private uint64 max_file_size = 1024*1024*128;
	private Gtk.Label error_label = new Gtk.Label("");
	private Gtk.Entry comment_entry = new Gtk.Entry();
	private Gtk.FileChooserButton file_button;
	private Gtk.Button post_button;
	private bool uploading = false;
	
	public InlineSearchPostB64FilePopoverEasterEgg(Dragonstone.GtkUi.Widget.InlineSearch parent, string uri){
		this.base_uri = uri;
		this.parent_entry = parent;
		var box = new Gtk.Box(Gtk.Orientation.VERTICAL,4);
		box.margin = 8;
		var title_label = new Gtk.Label("This will post a base64 encoded file with a space seperated comment appended to it to");
		title_label.set_tooltip_text("This feataure is intended to work with the gopherboard over at gopher://khzae.net");
		var uri_label = new Gtk.Label(uri);
		uri_label.selectable = true;
		//filebutton
		file_button = new Gtk.FileChooserButton("Select a file to upload",Gtk.FileChooserAction.OPEN);
		//postbutton
		var post_button_label = "Upload!"; //tab.translation.localize("action.upload_file");
		var post_button = new Gtk.Button.with_label(post_button_label);
		post_button.sensitive = false;
		post_button.clicked.connect(this.activate_upload);
		//comment_entry
		comment_entry.placeholder_text = "Add comment (my not be supported everywhere)";
		comment_entry.activate.connect(this.activate_upload);
		//make file button work
		file_button.file_set.connect(() => {
			post_button.sensitive = true;
		});
		box.pack_start(title_label);
		box.pack_start(uri_label);
		box.pack_start(file_button);
		box.pack_start(comment_entry);
		box.pack_start(error_label);
		box.pack_start(post_button);
		add(box);
		this.set_position(Gtk.PositionType.BOTTOM);
	}
	
	private void activate_upload(){
		if (!uploading){
			var file = file_button.get_file();
			if (file != null){
				post_button.sensitive = false;
				encode_and_send_file(file);
			}
		}	
	}
	
	private void display_error(string error){
		Timeout.add(0,() => {
			error_label.label = error;
			return false;
		},Priority.HIGH);
	}
	
	private void send(){
		Timeout.add(0,() => {
			string comment = "";
			if (comment_entry.text != ""){
				comment = "%20"+Uri.escape_string(comment_entry.text);
			}
			parent_entry.go(@"$base_uri%09$base64_buffer$comment");
			return false;
		},Priority.HIGH);
	}
	
	private void encode_and_send_file(File file){
		uploading = true;
		try {
			var input_stream = file.read();
			uint64 size = 0;
			uint8[] readbuffer = new uint8[1024*4*3]; //make sure the size of this is dividable by 3!
			while (size < max_file_size){
				var bytes = input_stream.read_bytes(1024*4*3);
				var bytes_read = (uint64) bytes.length;
				size += (uint64) bytes_read;
				base64_buffer = base64_buffer+Base64.encode(bytes.get_data());
				if (bytes_read != readbuffer.length){	
					break;
				}
			}
			print(@"Read $size bytes\n");
			if (size > max_file_size){
				display_error("File too large (max 128MB)");
			}
			send();
		} catch (GLib.Error e) {
			print("[gopher.gtk][base64_file_upload][error] "+e.message);
			display_error(e.message);
		}
		uploading = false;
	}	
	
}
