public class Dragonstone.Widget.LinkButton : Gtk.Button {

	string uri;	
	private Dragonstone.Tab tab;
	private Gtk.GestureLongPress long_press_gesture;
	
	public LinkButton(Dragonstone.Tab tab,string name,string uri,string? icon_name = null){
		this.tab = tab;
		var icon_name_ = icon_name;
		halign = Gtk.Align.START;
		this.uri = uri;
		clicked.connect((s) => {
			//temporary
			//open http(s) and mailto links with xdg to make dragonstone a bit more useable
			if (uri.has_prefix("http://") || uri.has_prefix("https://") || uri.has_prefix("mailto:")){
				tab.open_uri_externally(this.uri);
			}else{
				tab.go_to_uri(this.uri);
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
		long_press_gesture = new Gtk.GestureLongPress(this);
		long_press_gesture.set_propagation_phase(Gtk.PropagationPhase.TARGET);
		long_press_gesture.pressed.connect((x,y) => {
			show_popover();
		});
		button_press_event.connect(handle_button_press);
		set_relief(Gtk.ReliefStyle.NONE);
	}
	
	private bool handle_button_press(Gdk.EventButton event){
		if (event.type == BUTTON_PRESS){
			if (event.button == 2) { //middleclick
				tab.open_uri_in_new_tab(uri);
				return true;
			} else if (event.button == 3) { //right click
				show_popover();
				return true;
			}
		}
		return false;
	}
	
	private void show_popover(){
		var popover = new Dragonstone.Widget.LinkButtonPopover(this.tab,uri);
		popover.set_relative_to(this);
		popover.popup();
		popover.show_all();
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

public class Dragonstone.Widget.LinkButtonPopover : Dragonstone.Widget.LinkPopover,Gtk.Popover {
	
	public Dragonstone.Tab tab;
	public string? uri { get; set; }
	
	private Gtk.Label uri_label;
	private Gtk.Button open_in_new_tab_button;
	private Gtk.Button open_externally_button;
	
	public LinkButtonPopover(Dragonstone.Tab tab, string? uri = null){
		this.tab = tab;
		this.uri = null; //uri gets set below with use_uri(uri);
		this.constrain_to = Gtk.PopoverConstraint.WINDOW;
		var box = new Gtk.Box(Gtk.Orientation.VERTICAL,0);
		uri_label = new Gtk.Label("");
		uri_label.selectable = true;
		uri_label.wrap_mode = Pango.WrapMode.WORD_CHAR;
		var open_in_new_tab_button_label = tab.translation.localize("action.open_in_new_tab");
		open_in_new_tab_button = new Gtk.Button.with_label(open_in_new_tab_button_label);
		open_in_new_tab_button.set_relief(Gtk.ReliefStyle.NONE);
		open_in_new_tab_button.clicked.connect(() => {
			if (this.uri != null){
				this.tab.open_uri_in_new_tab(this.uri);
			}
		});
		var open_externally_button_label = tab.translation.localize("action.open_uri_externally");
		open_externally_button = new Gtk.Button.with_label(open_externally_button_label);
		open_externally_button.set_relief(Gtk.ReliefStyle.NONE);
		open_externally_button.clicked.connect(() => {
			if (this.uri != null){
				this.tab.open_uri_externally(this.uri);
			}
		});
		box.pack_start(uri_label);
		box.pack_start(open_in_new_tab_button);
		box.pack_start(open_externally_button);
		/*var cache = tab.session.get_cache();
		if (cache != null){
			if(cache.can_serve_request(uri)){
				box.pack_start(new Gtk.Label(tab.translation.localize("linkbutton.resource_is_in_cache.tag")));
			}
		}*/
		add(box);
		this.set_position(Gtk.PositionType.BOTTOM);
		if (uri != null){
			use_uri(uri);
		}
	}
	
	public void use_uri(string uri){
		this.uri = uri;
		uri_label.label = uri;
	}
	
}
