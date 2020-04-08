public class Dragonstone.Widget.LinkButton : Gtk.Button {

	string uri;	
	private Dragonstone.Tab tab;
	
	public LinkButton(Dragonstone.Tab tab,string name,string uri,string? icon_name = null){
		this.tab = tab;
		var icon_name_ = icon_name;
		halign = Gtk.Align.START;
		this.uri = uri;
		clicked.connect((s) => {
			//temporary
			//open http(s) and mailto links with xdg to make dragonstone a bit more useable
			if (uri.has_prefix("http://") || uri.has_prefix("https://") || uri.has_prefix("mailto:")){
				try {
					Pid child_pid;
					GLib.Process.spawn_async (null, {"xdg-open",uri}, null, GLib.SpawnFlags.SEARCH_PATH, null, out child_pid);
				} catch (Error e){
					print(@"Error while spawing xdg-open: $(e.message)\n");
				}
			}else{
				tab.goToUri(this.uri);
			}
		});
		if(icon_name_ == null){
			icon_name_ = guessIconNameByUri(uri);
		}
		always_show_image = true;
		image = new Gtk.Image.from_icon_name(icon_name_,Gtk.IconSize.LARGE_TOOLBAR);
		image_position = Gtk.PositionType.LEFT;
		if (name == uri || name == ""){
			label = @"$uri";
		} else {
			label = @"$name";
		}
		set_tooltip_text(uri);
		button_press_event.connect(handle_button_press);
		set_relief(Gtk.ReliefStyle.NONE);
	}
	
	private bool handle_button_press(Gdk.EventButton event){
		if (event.type == BUTTON_PRESS){
			if (event.button == 2) { //middleclick
				tab.open_uri_in_new_tab(uri);
				return true;
			} else if (event.button == 3) { //right click
				var popover = new Dragonstone.Widget.LinkButtonPopover(this.tab,uri);
				popover.set_relative_to(this);
				popover.popup();
				popover.show_all();
				return true;
			}
		}
		return false;
	}
	
	private string guessIconNameByUri(string uri){
		if (uri.has_prefix("http")){ //move to before gopher when implemented
			return "text-html-symbolic";
		} else if (uri.has_prefix("mailto:")){
			return "mail-message-new-symbolic";
		} else if (uri.has_suffix("/")){
			return "folder-symbolic";
		} else if (uri.has_suffix(".txt")){
			return "text-x-generic-symbolic";
		} else if (uri.has_suffix(".jpg")){
			return "image-x-generic-symbolic";
		} else if (uri.has_suffix(".jpeg")){
			return "image-x-generic-symbolic";
		} else if (uri.has_suffix(".png")){
			return "image-x-generic-symbolic";
		} else if (uri.has_suffix(".bmp")){
			return "image-x-generic-symbolic";
		} else if (uri.has_suffix(".gopher")){
			return "folder-symbolic";
		} else if (uri.has_suffix(".gemini")){
			return "folder-symbolic";
		} else if (uri.has_suffix(".tar")){
			return "document-save-symbolic";
		} else if (uri.has_suffix(".gz")){
			return "document-save-symbolic";
		} else if (uri.has_suffix(".xz")){
			return "document-save-symbolic";
		} else if (uri.has_suffix(".zip")){
			return "document-save-symbolic";
		} else if (uri.has_prefix("gopher://")){
			var slashindex = uri.index_of_char('/',10);
			if (slashindex < 0 || slashindex+1 >= uri.length){
				return "folder-symbolic";
			}
			var gophertype = uri.get(slashindex+1);
			if (gophertype == '0'){ //file
				return "text-x-generic-symbolic";
			} else if (gophertype == '1'){ //directory
				return "folder-symbolic";
			} else if (gophertype == '7'){ //search
				return "system-search-symbolic";
			} else if (gophertype == '9'){ //binary
				return "document-save-symbolic";
			} else if (gophertype == 'g'){ //gif
				return "image-x-generic-symbolic";
			} else if (gophertype == 'I'){ //image
				return "image-x-generic-symbolic";
			} else if (gophertype == 'p'){ //image
				return "image-x-generic-symbolic";
			}
		}
		return "go-jump-symbolic";
	}
}

public class Dragonstone.Widget.LinkButtonPopover : Gtk.Popover {
	
	public LinkButtonPopover(Dragonstone.Tab tab,string uri){
		var box = new Gtk.Box(Gtk.Orientation.VERTICAL,0);
		var uri_label = new Gtk.Label(uri);
		uri_label.selectable = true;
		var open_in_new_tab_button_label = tab.translation.localize("action.open_in_new_tab");
		var open_in_new_tab_button = new Gtk.Button.with_label(open_in_new_tab_button_label);
		open_in_new_tab_button.set_relief(Gtk.ReliefStyle.NONE);
		open_in_new_tab_button.clicked.connect(() => {
			tab.open_uri_in_new_tab(uri);
		});
		box.pack_start(uri_label);
		box.pack_start(open_in_new_tab_button);
		add(box);
	}
}
