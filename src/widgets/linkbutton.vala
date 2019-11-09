public class Dragonstone.Widget.LinkButton : Gtk.Button {

	string uri;	
	
	public LinkButton(Dragonstone.Tab tab,string name,string uri,string? icon_name = null){
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
		var linkwidget = new Dragonstone.Widget.LinkButtonDisplay(name,uri,icon_name_);
		add(linkwidget);
		set_relief(Gtk.ReliefStyle.NONE);
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
			return "folder-download-symbolic";
		} else if (uri.has_suffix(".gz")){
			return "folder-download-symbolic";
		} else if (uri.has_suffix(".xz")){
			return "folder-download-symbolic";
		} else if (uri.has_suffix(".zip")){
			return "folder-download-symbolic";
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
				return "folder-download-symbolic";
			} else if (gophertype == 'g'){ //gif
				return "image-x-generic-symbolic";
			} else if (gophertype == 'I'){ //image
				return "image-x-generic-symbolic";
			}
		}
		return "go-jump-symbolic";
	}
}

private class Dragonstone.Widget.LinkButtonDisplay : Gtk.Bin {
	public LinkButtonDisplay(string name,string uri,string icon_name){
		var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL,4);
		box.homogeneous = false;
		var labeltext = @"$name [$uri]";
		if (name == uri){
			labeltext = @"[$uri]";
		}
		var label = new Gtk.Label(labeltext);
		label.selectable = true;
		label.halign = Gtk.Align.START;
		var labelAttrList = new Pango.AttrList();
		labelAttrList.insert(new Pango.AttrSize(12000));
		label.attributes = labelAttrList;
		var icon = new Gtk.Image.from_icon_name(icon_name,Gtk.IconSize.LARGE_TOOLBAR);
		icon.halign = Gtk.Align.START;
		box.pack_start(icon);
		box.pack_start(label);
		box.halign = Gtk.Align.START;
		add(box);
	}
}
