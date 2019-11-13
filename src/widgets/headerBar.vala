public class Dragonstone.HeaderBar : Gtk.HeaderBar {
	
	public Gtk.Stack tabs { get; construct; }
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
	
	public HeaderBar (Gtk.Stack tabs) {
		Object (
			tabs: tabs
		);
	}

	construct {
		show_close_button = true;
		//backbutton
		backbutton = new Gtk.Button.from_icon_name("go-previous-symbolic");
		backbutton.relief = Gtk.ReliefStyle.NONE;
		backbutton.valign = Gtk.Align.CENTER;
		pack_start(backbutton);
		//forwardbutton
		forwardbutton = new Gtk.Button.from_icon_name("go-next-symbolic");
		forwardbutton.relief = Gtk.ReliefStyle.NONE;
		backbutton.valign = Gtk.Align.CENTER;
		pack_start(forwardbutton);
		//addressfield
		addressfield = new Gtk.Entry();
		addressfield.expand = true;
		pack_start(addressfield);
		backbutton.valign = Gtk.Align.CENTER;
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
		backbutton.valign = Gtk.Align.CENTER;
		loadbutton.get_style_context().add_class("suggested-action");
		pack_start(loadbutton);
		//tabsbutton
		//TEMPORARY
		var stackswitcher = new Gtk.StackSwitcher();
		
		stackswitcher.stack = tabs;
		
		pack_end(stackswitcher);
		
		//bookmarksbutton [user-bookmark]
		
		
		//connect ui signals
		addressfield.activate.connect(() =>{
			if (current_tab != null){
				if (current_tab.uri != addressfield.text){
					print(@"Going to uri: $(addressfield.text)\n");
					current_tab.goToUri(addressfield.text);
				}
			} else {
				print(@"No current_tab!\nWould have gone to $(addressfield.text)\n");
			}
		});
		addressfield.focus_out_event.connect(() => {
			if (addressfield.text == ""){
				addressfield.text = current_tab.uri;
			}
			return false;
		});
		addressfield.notify["text"].connect(() =>{
			relabelLoadButton();
		});
		loadbutton.clicked.connect(e => {
			if (loadButtonReloadMode){
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
			current_tab.goBack();
		});
		forwardbutton.clicked.connect(e => {
			//print("GO forward!\n");
			current_tab.goForward();
		});
		downloadbutton.clicked.connect(e => {
			current_tab.download();
		});
		//connect stack signal
		tabs.notify["visible-child"].connect((s,t) => {onVisibleTabChanged();});
		//fire events
		onVisibleTabChanged();
	}
	
	private void onVisibleTabChanged(){
		//disconnect old signals
		if (current_tab != null){
			current_tab.uriChanged.disconnect(onUriChanged);
		}
		//set new tab
		if (!(tabs.visible_child is Dragonstone.Tab)) { return; }
		current_tab = tabs.visible_child as Dragonstone.Tab;
		//connect new signa
		current_tab.uriChanged.connect(onUriChanged);
		//everything else
		onUriChanged(current_tab.uri);
	}
	
	private void onUriChanged(string uri){
		addressfield.text = uri;
		backbutton.set_sensitive(current_tab.canGoBack());
		forwardbutton.set_sensitive(current_tab.canGoForward());
		relabelLoadButton();
	}
	
	private void relabelLoadButton(){
		if (addressfield.text == "" || addressfield.text == current_tab.uri){
			loadButtonReloadMode = true;
			//loadbutton.label = "Reload!"; //TOTRANSLATE
			loadbutton.image = reloadIcon;
		} else {
			loadButtonReloadMode = false;
			//loadbutton.label = "Go!"; //TOTRANSLATE
			loadbutton.image = goIcon;
		}
	}
	
}
