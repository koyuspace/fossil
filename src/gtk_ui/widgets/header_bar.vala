public class Dragonstone.HeaderBar : Gtk.HeaderBar {
	
	public Gtk.Notebook tabs { get; construct; }
	public Dragonstone.Window parent_window { get; construct; }
	public Dragonstone.SuperRegistry super_registry { get; construct; }
	public Dragonstone.Tab current_tab { get; protected set; }
	public Dragonstone.Registry.UriAutoprefix uri_autoprefixer;
	
	public Gtk.Entry addressfield;
	public Gtk.Button backbutton;
	public Gtk.Button forwardbutton;
	public Gtk.Button loadbutton;
	private Dragonstone.GtkUi.Widget.ViewChooser view_chooser;
	private Dragonstone.GtkUi.Widget.SessionChooser session_chooser;
	private Gtk.Button savetodiskbutton;
	private Gtk.Button downloadbutton;
	private Gtk.Button bookmarkbutton;
	private bool loadButtonReloadMode = false;
	private bool switching_tab = false;
	private Gtk.Image reloadIcon = new Gtk.Image.from_icon_name("view-refresh-symbolic",Gtk.IconSize.BUTTON);
	private Gtk.Image goIcon = new Gtk.Image.from_icon_name("go-jump-symbolic",Gtk.IconSize.BUTTON);
	public Gtk.Button menubutton = new Gtk.Button.from_icon_name("open-menu-symbolic");
	public Gtk.Popover mainmenu;
	
	private Gtk.Switch prefer_source_view_switch;
	
	public Gtk.Button close_tab_button;
	
	public HeaderBar (Dragonstone.Window parent_window) {
		Object (
			tabs: parent_window.tabs,
			parent_window: parent_window,
			super_registry: parent_window.super_registry
		);
		uri_autoprefixer = (super_registry.retrieve("core.uri_autoprefixer") as Dragonstone.Registry.UriAutoprefix);
		if (uri_autoprefixer == null) {
			uri_autoprefixer = new Dragonstone.Registry.UriAutoprefix();
		}
	
		show_close_button = true;
		has_subtitle = false;
		//load translation
		//backbutton
		backbutton = new Gtk.Button.from_icon_name("go-previous-symbolic");
		backbutton.relief = Gtk.ReliefStyle.NONE;
		backbutton.valign = Gtk.Align.CENTER;
		pack_start(backbutton);
		//forwardbutton
		forwardbutton = new Gtk.Button.from_icon_name("go-next-symbolic");
		forwardbutton.relief = Gtk.ReliefStyle.NONE;
		forwardbutton.valign = Gtk.Align.CENTER;
		pack_start(forwardbutton);
		//addressfield
		addressfield = new Gtk.Entry();
		addressfield.expand = true;
		addressfield.input_purpose = Gtk.InputPurpose.URL;
		addressfield.valign = Gtk.Align.CENTER;
		custom_title=addressfield;
		//pack_start(addressfield);
		//menubutton
		pack_end(menubutton);
		//mainmenu
		mainmenu = new Gtk.Popover(menubutton);
		var mainmenubox = new Gtk.Box(Gtk.Orientation.VERTICAL,4);
		//top row
		var mainmenuhbox = new Gtk.Box(Gtk.Orientation.HORIZONTAL,0);
		mainmenubox.margin = 8;
		mainmenuhbox.margin_bottom = 4;
		mainmenuhbox.get_style_context().add_class("linked");
		mainmenuhbox.homogeneous = true;
		mainmenubox.pack_start(mainmenuhbox);
		downloadbutton = new Gtk.Button.from_icon_name("document-save-symbolic",Gtk.IconSize.LARGE_TOOLBAR );
		mainmenuhbox.pack_start(downloadbutton);
		bookmarkbutton = new Gtk.Button.from_icon_name("user-bookmarks-symbolic",Gtk.IconSize.LARGE_TOOLBAR );
		mainmenuhbox.pack_start(bookmarkbutton);
		savetodiskbutton = new Gtk.ToggleButton();
		var diskicon = new Gtk.Image.from_icon_name("drive-harddisk-symbolic",Gtk.IconSize.LARGE_TOOLBAR );
		savetodiskbutton.add(diskicon);
		savetodiskbutton.sensitive = false;
		mainmenuhbox.pack_start(savetodiskbutton);
		//dummy button and switch to fix a wired bug where they dont get stylized like we want them to be
		var dummy_button = new Dragonstone.GtkUi.Widget.MenuButton("---");
		mainmenubox.pack_start(dummy_button);
		mainmenubox.remove(dummy_button);
		var dummy_switch = new Dragonstone.GtkUi.Widget.MenuSwitch("---");
		mainmenubox.pack_start(dummy_switch);
		mainmenubox.remove(dummy_switch);
		//show_tabs
		var show_tabs_localized = parent_window.translation.get_localized_string("window.main_menu.show_tabs.label");
		var show_tabs_widget = new Dragonstone.GtkUi.Widget.MenuSwitch(show_tabs_localized);
		var show_tabs_switch = show_tabs_widget.switch_widget;
		mainmenubox.pack_start(show_tabs_widget);
		//prefer_source_view
		var view_source_localized = parent_window.translation.get_localized_string("window.main_menu.prefer_source_view.label");
		var prefer_source_view_widget = new Dragonstone.GtkUi.Widget.MenuSwitch(view_source_localized);
		prefer_source_view_switch = prefer_source_view_widget.switch_widget;
		mainmenubox.pack_start(prefer_source_view_widget);
		//view chooser
		view_chooser = new Dragonstone.GtkUi.Widget.ViewChooser();
		var view_chooser_tooltip_localized = parent_window.translation.get_localized_string("window.main_menu.choose_view.tooltip");
		view_chooser.set_tooltip_text(view_chooser_tooltip_localized);
		mainmenubox.pack_start(view_chooser);
		//seperator
		mainmenubox.pack_start(new Gtk.Separator(Gtk.Orientation.HORIZONTAL));
		//session chooser
		session_chooser = new Dragonstone.GtkUi.Widget.SessionChooser();
		var session_chooser_tooltip_localized = parent_window.translation.get_localized_string("window.main_menu.choose_session.tooltip");
		session_chooser.set_tooltip_text(session_chooser_tooltip_localized);
		mainmenubox.pack_start(session_chooser);
		//seperator
		mainmenubox.pack_start(new Gtk.Separator(Gtk.Orientation.HORIZONTAL));
		//open uri external
		var open_uri_externally_localized = parent_window.translation.get_localized_string("window.main_menu.open_uri_externally.label");
		var openuriexternllybutton = new Dragonstone.GtkUi.Widget.MenuButton(open_uri_externally_localized);
		mainmenubox.pack_start(openuriexternllybutton);
		//open file external
		var open_file_externally_localized = parent_window.translation.get_localized_string("window.main_menu.open_file_externally.label");
		var openfileexternllybutton = new Dragonstone.GtkUi.Widget.MenuButton(open_file_externally_localized);
		mainmenubox.pack_start(openfileexternllybutton);
		//seperator
		mainmenubox.pack_start(new Gtk.Separator(Gtk.Orientation.HORIZONTAL));
		//Cache
		var view_cache_localized = parent_window.translation.get_localized_string("window.main_menu.cache.label");
		var cachebutton = new Dragonstone.GtkUi.Widget.MenuButton(view_cache_localized);
		mainmenubox.pack_start(cachebutton);
		//Session
		var view_session_localized = parent_window.translation.get_localized_string("window.main_menu.session.label");
		var sessionbutton = new Dragonstone.GtkUi.Widget.MenuButton(view_session_localized);
		mainmenubox.pack_start(sessionbutton);
		//seperator
		mainmenubox.pack_start(new Gtk.Separator(Gtk.Orientation.HORIZONTAL));
		//Settings
		var view_settings_localized = parent_window.translation.get_localized_string("window.main_menu.settings.label");
		var settingsbutton = new Dragonstone.GtkUi.Widget.MenuButton(view_settings_localized);
		settingsbutton.sensitive = false;
		mainmenubox.pack_start(settingsbutton);
		//close tabs button
		var close_tab_localized = parent_window.translation.get_localized_string("window.main_menu.close_tab.label");		
		close_tab_button = new Dragonstone.GtkUi.Widget.MenuButton(close_tab_localized);
		mainmenubox.pack_start(close_tab_button);
		//main menu end
		mainmenu.add(mainmenubox);
		//loadbutton
		loadbutton = new Gtk.Button.from_icon_name("dialog-error-symbolic");
		loadbutton.valign = Gtk.Align.CENTER;
		loadbutton.get_style_context().add_class("suggested-action");
		pack_end(loadbutton);
		
		//connect ui signals
		addressfield.activate.connect(() =>{
			addressfield.text = tryUriCorrection(addressfield.text);
			if (current_tab != null){
				if (current_tab.uri != addressfield.text){
					current_tab.go_to_uri(addressfield.text,true);
				}
			} else {
				parent_window.add_tab(addressfield.text);
			}
		});
		addressfield.focus_out_event.connect(() => {
			if (addressfield.text == "" && current_tab != null) {
				addressfield.text = current_tab.uri;
			}
			return false;
		});
		addressfield.notify["text"].connect(() =>{
			relabelLoadButton();
		});
		loadbutton.clicked.connect(e => {
			if (loadButtonReloadMode && current_tab != null) {
				print("RELOAD!\n");
				current_tab.reload();
			} else {
				print("GO!\n");
				addressfield.activate();
			}
		});
		menubutton.clicked.connect(e => {
			print("OPEN main menu!\n");
			mainmenu.show_all();
		});
		backbutton.clicked.connect(e => {
			//print("GO back!\n");
			if (current_tab != null) {
				current_tab.go_back();
			}
		});
		forwardbutton.clicked.connect(e => {
			//print("GO forward!\n");
			if (current_tab != null) {
				current_tab.go_forward();
			}
		});
		downloadbutton.clicked.connect(e => {
			if (current_tab != null) {
				current_tab.download();
			}
		});
		bookmarkbutton.clicked.connect(e => {
			if (current_tab != null) {
				current_tab.open_subview("dragonstone.bookmarks");
			}
		});
		openfileexternllybutton.clicked.connect(e => {
			if (current_tab != null) {
				current_tab.open_resource_externally();
			}
		});
		openuriexternllybutton.clicked.connect(e => {
			if (current_tab != null) {
				current_tab.open_uri_externally();
			}
		});
		close_tab_button.clicked.connect(e => {
			if (current_tab != null) {
				current_tab.close();
			}
		});
		show_tabs_switch.state_set.connect(e => {
			tabs.show_tabs = show_tabs_switch.state;
			return true;
		});
		show_tabs_switch.state = true;
		prefer_source_view_switch.state_set.connect(e => {
			if (current_tab != null && !switching_tab) {
				current_tab.view_flags.set_flag("sourceview",prefer_source_view_switch.state);
				current_tab.update_view();
				return false;
			}
			return true;
		});
		cachebutton.clicked.connect(e => {
			if (current_tab != null){
				current_tab.open_uri_in_new_tab("about:cache");
			} else {
				parent_window.add_tab("about:cache");
			}
		});
		sessionbutton.clicked.connect(e => {
			if (current_tab != null){
				current_tab.open_uri_in_new_tab("session://");
			} else {
				parent_window.add_tab("session://");
			}
		});
		//connect stack signal
		tabs.switch_page.connect((widget,num) => {
			onVisibleTabChanged(widget);
		});
		tabs.page_removed.connect((widget,num) => {
			if (tabs.get_n_pages() == 0){
				onVisibleTabChanged(null);
			}
		});
		//fire events
		onVisibleTabChanged(tabs.get_nth_page(tabs.get_current_page()));
	}
	
	private void onVisibleTabChanged(Gtk.Widget? tab){
		switching_tab = true;
		//disconnect old signals
		if (current_tab != null) {
			current_tab.uri_changed.disconnect(onUriChanged);
		}
		//set new tab
		if (!(tab is Dragonstone.Tab || tab == null)) {
			switching_tab = false;
			return;
		}
		current_tab = tab as Dragonstone.Tab;
		view_chooser.use_tab(current_tab);
		session_chooser.use_tab(current_tab);
		if (current_tab != null) {
			//connect new signal
			current_tab.uri_changed.connect(onUriChanged);
			//everything else
			onUriChanged(current_tab.uri);
			prefer_source_view_switch.active = current_tab.view_flags.has_flag("sourceview");
		} else {
			onUriChanged("");
		}
		switching_tab = false;
	}
	
	private void onUriChanged(string uri){
		addressfield.text = uri;
		if (current_tab != null) {
			backbutton.set_sensitive(current_tab.can_go_back());
			forwardbutton.set_sensitive(current_tab.can_go_forward());
		} else {
			backbutton.set_sensitive(false);
			forwardbutton.set_sensitive(false);
		}
		relabelLoadButton();
	}
	
	private void relabelLoadButton(){
		if (current_tab != null) {
			if (addressfield.text == "" || addressfield.text == current_tab.uri){
				loadButtonReloadMode = true;
				//loadbutton.label = "Reload!"; //TOTRANSLATE
				loadbutton.image = reloadIcon;
				return;
			}
		}
		loadButtonReloadMode = false;
		//loadbutton.label = "Go!"; //TOTRANSLATE
		loadbutton.image = goIcon;
	}
	
	public string tryUriCorrection(string uri){
		if(uri == "") { return "about:blank"; }
		return uri_autoprefixer.try_autoprefix(uri);
	}
	
}
