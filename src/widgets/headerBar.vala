public class Dragonstone.HeaderBar : Gtk.HeaderBar {
	
	public Gtk.Notebook tabs { get; construct; }
	public Dragonstone.Window parent_window { get; construct; }
	private Dragonstone.Tab current_tab;
	
	private Gtk.Entry addressfield;
	private Gtk.Button backbutton;
	private Gtk.Button forwardbutton;
	private Gtk.Button loadbutton;
	private bool loadButtonReloadMode = false;
	private Gtk.Image reloadIcon = new Gtk.Image.from_icon_name("view-refresh-symbolic",Gtk.IconSize.BUTTON);
	private Gtk.Image goIcon = new Gtk.Image.from_icon_name("go-jump-symbolic",Gtk.IconSize.BUTTON);
	private Gtk.Button menubutton = new Gtk.Button.from_icon_name("open-menu-symbolic");
	private Gtk.Popover mainmenu;
	
	public HeaderBar (Dragonstone.Window parent_window) {
		Object (
			tabs: parent_window.tabs,
			parent_window: parent_window
		);
	}

	construct {
		//show_close_button = false;
		has_subtitle = false;
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
		var mainmenubox = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		//top row
		var mainmenuhbox = new Gtk.Box(Gtk.Orientation.HORIZONTAL,0);
		mainmenubox.margin = 8;
		mainmenuhbox.get_style_context().add_class("linked");
		mainmenuhbox.homogeneous = true;
		mainmenubox.pack_start(mainmenuhbox);
		var downloadbutton = new Gtk.Button.from_icon_name("document-save-symbolic",Gtk.IconSize.LARGE_TOOLBAR );
		//downloadbutton.relief = Gtk.ReliefStyle.NONE;
		mainmenuhbox.pack_start(downloadbutton);
		var savetodiskbutton = new Gtk.ToggleButton();
		var diskicon = new Gtk.Image.from_icon_name("drive-harddisk-symbolic",Gtk.IconSize.LARGE_TOOLBAR );
		savetodiskbutton.add(diskicon);
		//savetodiskbutton.relief = Gtk.ReliefStyle.NONE;
		mainmenuhbox.pack_start(savetodiskbutton);
		//Cache
		var cachebutton = new Gtk.Button.with_label("Cache"); //TOTRANSLATE
		cachebutton.relief = Gtk.ReliefStyle.NONE;
		cachebutton.halign = Gtk.Align.FILL;
		mainmenubox.pack_start(cachebutton);
		//Settings
		var settingsbutton = new Gtk.Button.with_label("Settings"); //TOTRANSLATE
		settingsbutton.relief = Gtk.ReliefStyle.NONE;
		settingsbutton.halign = Gtk.Align.FILL;
		mainmenubox.pack_start(settingsbutton);
		//About
		var aboutbutton = new Gtk.Button.with_label("About"); //TOTRANSLATE
		aboutbutton.relief = Gtk.ReliefStyle.NONE;
		aboutbutton.halign = Gtk.Align.FILL;
		mainmenubox.pack_start(aboutbutton);
		mainmenu.add(mainmenubox);
		//loadbutton
		loadbutton = new Gtk.Button.from_icon_name("dialog-error-symbolic");
		loadbutton.valign = Gtk.Align.CENTER;
		loadbutton.get_style_context().add_class("suggested-action");
		pack_end(loadbutton);
		
		//bookmarksbutton [user-bookmark]
		
		
		//connect ui signals
		addressfield.activate.connect(() =>{
			addressfield.text = tryUriCorrection(addressfield.text);
			if (current_tab != null){
				if (current_tab.uri != addressfield.text){
					current_tab.goToUri(addressfield.text,true);
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
				current_tab.goBack();
			}
		});
		forwardbutton.clicked.connect(e => {
			//print("GO forward!\n");
			if (current_tab != null) {
				current_tab.goForward();
			}
		});
		downloadbutton.clicked.connect(e => {
			if (current_tab != null) {
				current_tab.download();
			}
		});
		//connect stack signal
		tabs.switch_page.connect((widget,num) => {
			print("Page switch!\n");
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
		//disconnect old signals
		if (current_tab != null) {
			current_tab.uriChanged.disconnect(onUriChanged);
		}
		//set new tab
		if (!(tab is Dragonstone.Tab || tab == null)) { return; }
		current_tab = tab as Dragonstone.Tab;
		if (current_tab != null) {
			//connect new signal
			current_tab.uriChanged.connect(onUriChanged);
			//everything else
			onUriChanged(current_tab.uri);
		} else {
			onUriChanged("");
		}
	}
	
	private void onUriChanged(string uri){
		addressfield.text = uri;
		if (current_tab != null) {
			backbutton.set_sensitive(current_tab.canGoBack());
			forwardbutton.set_sensitive(current_tab.canGoForward());
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
		var scheme = Dragonstone.Util.Uri.get_scheme(uri);
		if (scheme == "") {
			//automatically add scheme based on lowestlevel domain
			var pfx = "";
			if (! ("/" in uri)){pfx = "/";}
			if (uri.has_prefix("gopher.")) {return "gopher://"+uri+pfx;}
			if (uri.has_prefix("gemini.")) {return "gemini://"+uri+pfx;}
			if (uri.has_prefix("www.")) {return "https://"+uri+pfx;}
			return uri;
		}	else if (scheme == "about"){
			return uri;
		} else {
			if (uri.length < scheme.length+3) {return uri;}
			if (uri[scheme.length:scheme.length+3] == "://"){ return uri; }
			if (uri[scheme.length:scheme.length+2] == ":/"){
				return scheme+"://"+uri.slice(scheme.length+2,uri.length);
			}
			if (uri[scheme.length:scheme.length+1] == ":"){
				return scheme+"://"+uri.slice(scheme.length+1,uri.length);
			}
		}
		return uri;
	}
	
}
