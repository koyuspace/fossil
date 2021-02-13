public class Dragonstone.GtkUi.LegacyWidget.LinkButton : Gtk.Button {

	string uri;	
	private Dragonstone.GtkUi.LegacyWidget.Tab tab;
	private Gtk.GestureLongPress long_press_gesture;
	
	public LinkButton(Dragonstone.GtkUi.LegacyWidget.Tab tab,string name,string uri,string? icon_name = null){
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
			icon_name_ = Dragonstone.GtkUi.LegacyUtil.DefaultGtkLinkIconLoader.guess_icon_name_for_uri(uri);
		}
		always_show_image = true;
		image = new Gtk.Image.from_icon_name(icon_name_,Gtk.IconSize.LARGE_TOOLBAR);
		image_position = Gtk.PositionType.LEFT;
		if (name == ""){
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
	
	public void use_uri(string uri, bool update_icon){
		this.uri = uri;
		if (update_icon){
			var icon_name = Dragonstone.GtkUi.LegacyUtil.DefaultGtkLinkIconLoader.guess_icon_name_for_uri(uri);
			image = new Gtk.Image.from_icon_name(icon_name,Gtk.IconSize.LARGE_TOOLBAR);
		}
	}
	
	public void set_name(string name){
		if (name == ""){
			label = @"$uri";
		} else {
			label = @"$name";
		}
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
		var popover = new Dragonstone.GtkUi.LegacyWidget.LinkButtonPopover(this.tab,uri);
		popover.set_relative_to(this);
		popover.popup();
		popover.show_all();
	}
	
}

public class Dragonstone.GtkUi.LegacyWidget.LinkButtonPopover : Dragonstone.GtkUi.LegacyWidget.LinkPopover,Gtk.Popover {
	
	public Dragonstone.GtkUi.LegacyWidget.Tab tab;
	public string? uri { get; set; }
	
	private Dragonstone.GtkUi.LegacyWidget.MenuBigTextDisplay uri_display;
	private Gtk.Button open_in_new_tab_button;
	private Gtk.Button open_externally_button;
	
	public LinkButtonPopover(Dragonstone.GtkUi.LegacyWidget.Tab tab, string? uri = null){
		this.tab = tab;
		this.uri = null; //uri gets set below with use_uri(uri);
		//this.constrain_to = Gtk.PopoverConstraint.WINDOW;
		var box = new Gtk.Box(Gtk.Orientation.VERTICAL,2);
		box.margin = 4;
		var dummy_text_view = new Dragonstone.GtkUi.LegacyWidget.MenuBigTextDisplay("");
		box.pack_start(dummy_text_view);
		box.remove(dummy_text_view);
		uri_display = new Dragonstone.GtkUi.LegacyWidget.MenuBigTextDisplay("");
		var open_in_new_tab_button_label = tab.translation.localize("action.open_in_new_tab");
		open_in_new_tab_button = new Dragonstone.GtkUi.LegacyWidget.MenuButton(open_in_new_tab_button_label);
		open_in_new_tab_button.set_relief(Gtk.ReliefStyle.NONE);
		open_in_new_tab_button.clicked.connect(() => {
			if (this.uri != null){
				this.tab.open_uri_in_new_tab(this.uri);
			}
		});
		var open_externally_button_label = tab.translation.localize("action.open_uri_externally");
		open_externally_button = new Dragonstone.GtkUi.LegacyWidget.MenuButton(open_externally_button_label);
		open_externally_button.set_relief(Gtk.ReliefStyle.NONE);
		open_externally_button.clicked.connect(() => {
			if (this.uri != null){
				this.tab.open_uri_externally(this.uri);
			}
		});
		box.pack_start(open_in_new_tab_button);
		box.pack_start(open_externally_button);
		box.pack_start(uri_display);
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
		uri_display.text = uri;
	}
	
}
