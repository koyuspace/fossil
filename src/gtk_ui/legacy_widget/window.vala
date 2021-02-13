public class Dragonstone.Window : Gtk.ApplicationWindow {
	
	public Gtk.Notebook tabs;
	public Dragonstone.SuperRegistry super_registry { get; construct; }
	public Dragonstone.Registry.TranslationRegistry translation;
	private Dragonstone.GtkUi.Application app;
	private Dragonstone.Settings.Bridge.KV? settings = null;
	
	public Window(Dragonstone.GtkUi.Application application) {
		Object(
			application: application,
			super_registry: application.super_registry
		);
		this.app = application;
		load_translation();
		initalize();
	}
	
	public Window.from_dropped_tab(Dragonstone.GtkUi.Application application, int x, int y) {
		Object(
			application: application,
			super_registry: application.super_registry
		);
		this.app = application;
		move(x,y);
		load_translation();
		initalize();
	}
	
	private void load_translation() {
		this.translation = (super_registry.retrieve("localization.translation") as Dragonstone.Registry.TranslationRegistry);
		if (this.translation == null){
			print("[window] No translation resgistry found, falling back to an empty one!\n");
			this.translation = new Dragonstone.Registry.TranslationLanguageRegistry();
		}
		title = translation.get_localized_string("window.title");
	}
	
	private void initalize() {
		window_position = Gtk.WindowPosition.CENTER;
		set_default_size(800,600);
		
		set_events(Gdk.EventMask.ALL_EVENTS_MASK);
		
		settings = super_registry.retrieve("settings.frontend") as Dragonstone.Settings.Bridge.KV;
		
		//place window where it has been bofore closing
		//move(settings.get_int("main-window-pos-x"),settings.get_int("main-window-pos-y"));
		//resize(settings.get_int("main-window-width"),settings.get_int("main-window-height"));
		
		delete_event.connect( e => {
			return before_destroy();
		});
		
		//"content"
		tabs = new Gtk.Notebook();
		tabs.scrollable = true;
		tabs.set_group_name("dragonstone.tabs");
		
		tabs.page_added.connect((widget, pagenum) => {
			if (widget is Dragonstone.GtkUi.LegacyWidget.Tab){
				var tab = (widget as Dragonstone.GtkUi.LegacyWidget.Tab);
				tab.set_tab_parent_window(this);
			}
		});
		
		tabs.create_window.connect((page,x,y) => {
			var window = new Dragonstone.Window.from_dropped_tab(this.app,x,y);
			return window.tabs;
		});
		
		//new tab button
		var add_button = new Gtk.Button.from_icon_name("tab-new-symbolic");
		add_button.relief = Gtk.ReliefStyle.NONE;
		add_button.clicked.connect(add_new_tab);
		add_button.show_all();
		tabs.set_action_widget(add_button,Gtk.PackType.END);
		
		add(tabs);
		
		//header bar
		var headerbar = new Dragonstone.HeaderBar(this);
		set_titlebar (headerbar);
		
		//keyboard shortcuts
		var accelerator_group = new Gtk.AccelGroup();
		add_accel_group(accelerator_group);
		uint key;
		Gdk.ModifierType modifiers;
		Gtk.accelerator_parse("<alt>b",out key,out modifiers);
		headerbar.backbutton.add_accelerator("clicked",accelerator_group,key,modifiers,Gtk.AccelFlags.VISIBLE);
		Gtk.accelerator_parse("<alt>f",out key,out modifiers);
		headerbar.forwardbutton.add_accelerator("clicked",accelerator_group,key,modifiers,Gtk.AccelFlags.VISIBLE);
		Gtk.accelerator_parse("<control>l",out key,out modifiers);
		headerbar.addressfield.add_accelerator("grab_focus",accelerator_group,key,modifiers,Gtk.AccelFlags.VISIBLE);
		Gtk.accelerator_parse("<control>m",out key,out modifiers);
		headerbar.menubutton.add_accelerator("clicked",accelerator_group,key,modifiers,Gtk.AccelFlags.VISIBLE);
		Gtk.accelerator_parse("<control>t",out key,out modifiers);
		add_button.add_accelerator("clicked",accelerator_group,key,modifiers,Gtk.AccelFlags.VISIBLE);
		Gtk.accelerator_parse("<control>w",out key,out modifiers);
		accelerator_group.connect(key,modifiers,Gtk.AccelFlags.VISIBLE,() => {
			close_tab(null);
			return true;
		});
		Gtk.accelerator_parse("<control>p",out key,out modifiers);
		accelerator_group.connect(key,modifiers,Gtk.AccelFlags.VISIBLE,() => {
			tabs.prev_page();
			return true;
		});
		Gtk.accelerator_parse("<control>s",out key,out modifiers);
		accelerator_group.connect(key,modifiers,Gtk.AccelFlags.VISIBLE,() => {
			if(headerbar.current_tab != null){
				headerbar.current_tab.download();
			}
			return true;
		});
		Gtk.accelerator_parse("<control>n",out key,out modifiers);
		accelerator_group.connect(key,modifiers,Gtk.AccelFlags.VISIBLE,() => {
			tabs.next_page();
			return true;
		});
		Gtk.accelerator_parse("F5",out key,out modifiers);
		accelerator_group.connect(key,modifiers,Gtk.AccelFlags.VISIBLE,() => {
			headerbar.current_tab.reload();
			return true;
		});
		Gtk.accelerator_parse("F8",out key,out modifiers);
		accelerator_group.connect(key,modifiers,Gtk.AccelFlags.VISIBLE,() => {
			headerbar.show_close_button = !headerbar.show_close_button;
			headerbar.visible = false;
			headerbar.visible = true;
			return true;
		});
		show_all();
		
		this.key_press_event.connect((event) => {
			//print(@"Key pressed! $(event.keyval) $(event.str) $(event.is_modifier)\n");
			return false;
		});
	}
	
	private string get_settings_value(string key, string default_value){
		if (settings != null){
			var ret = settings.values.get(key);
			if (ret != null){
				return ret;
			}
		}
		return default_value;
	}
	
	//fills out the destination with the default address
	public void add_new_tab(){
		add_tab(get_settings_value("new_tab_uri","about:blank"));
	}
	
	public void add_tab(string uri, string session_id = "core.default"){
		add_tab_object(new Dragonstone.GtkUi.LegacyWidget.Tab(session_id,uri,this,super_registry));
	}
	
	public void add_tab_object(Dragonstone.GtkUi.LegacyWidget.Tab tab){
		tabs.append_page(tab,new Dragonstone.GtkUi.LegacyWidget.TabHead(tab));
		tabs.set_tab_reorderable(tab,true);
		tabs.set_tab_detachable(tab,true);
		tabs.set_current_page(-1);
	}
	
	public void close_tab(Gtk.Widget? tab){
		int page_num = -1;
		var tabx = tab;
		if (tabx != null){
			page_num = tabs.page_num(tab);
		} else {
			page_num = tabs.get_current_page();
			tabx = tabs.get_nth_page(page_num);
		}
		if(page_num < 0) { return; }
		tabs.remove_page(page_num);
		Dragonstone.GtkUi.LegacyWidget.Tab dt = (tabx as Dragonstone.GtkUi.LegacyWidget.Tab);
		if (dt is Dragonstone.GtkUi.LegacyWidget.Tab && dt != null) {
			dt.cleanup();
		}
		//if (tabs.get_n_pages() == 0) { add_new_tab(); }
	}
	
	public void close_all_tabs(){
		while(tabs.get_n_pages()>0){
			var widget = tabs.get_nth_page(0);
			tabs.remove_page(0);
			Dragonstone.GtkUi.LegacyWidget.Tab dt = (widget as Dragonstone.GtkUi.LegacyWidget.Tab);
			if (dt is Dragonstone.GtkUi.LegacyWidget.Tab && dt != null) {
				dt.cleanup();
			}
		}
	}
	
	public bool before_destroy() {
		//save window dimensions and position before closing
		/*int width, height, x, y;
		get_size(out width,out height);
		get_position(out x,out y);
		settings.set_int("main-window-width",width);
		settings.set_int("main-window-height",height);
		settings.set_int("main-window-pos-x",x);
		settings.set_int("main-window-pos-y",y);*/
		close_all_tabs();
		return false;
	}
}
