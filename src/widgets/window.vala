public class Dragonstone.Window : Gtk.ApplicationWindow {
	
	public GLib.Settings settings;
	public Gtk.Notebook tabs;
	public Dragonstone.ResourceStore store;	
	public Dragonstone.SuperRegistry super_registry { get; construct; }
	
	public Window(Dragonstone.Application application) {
		Object(
			application: application,
			super_registry: application.super_registry
		);
		add_new_tab();
	}
	
	public Window.from_dropped_Tab(Dragonstone.Application application,Dragonstone.Tab tab,int x,int y) {
		Object(
			application: application,
			super_registry: application.super_registry
		);
		move(x,y);
		add_tab_object(tab);
	}
	
	construct {
		title = "Project Dragonstone";
		window_position = Gtk.WindowPosition.CENTER;
		set_default_size(600,400);
		
		//settings = new GLib.Settings("com.gitlab.baschdel.Dragonstone");
		
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
			if (widget is Dragonstone.Tab){
				var tab = (widget as Dragonstone.Tab);
				tab.set_tab_parent_window(this);
			}
		});
		
		//new tab button
		var add_button = new Gtk.Button.from_icon_name("tab-new-symbolic");
		add_button.relief = Gtk.ReliefStyle.NONE;
		add_button.clicked.connect(add_new_tab);
		add_button.show_all();
		tabs.set_action_widget(add_button,Gtk.PackType.END);
		
		add(tabs);
		
		//initalize resource store //TODO move to application
		store = new Dragonstone.Store.Switch.default_configuration();
		
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
		});
		Gtk.accelerator_parse("<control>p",out key,out modifiers);
		accelerator_group.connect(key,modifiers,Gtk.AccelFlags.VISIBLE,() => {
			tabs.prev_page();
		});
		Gtk.accelerator_parse("<control>n",out key,out modifiers);
		accelerator_group.connect(key,modifiers,Gtk.AccelFlags.VISIBLE,() => {
			tabs.next_page();
		});
		Gtk.accelerator_parse("F5",out key,out modifiers);
		accelerator_group.connect(key,modifiers,Gtk.AccelFlags.VISIBLE,() => {
			headerbar.current_tab.reload();
		});
		show_all();
	}
	
	//fills out the destination with the default address
	public void add_new_tab(){
		add_tab("test://");
	}
	
	public void add_tab(string uri){
		add_tab_object(new Dragonstone.Tab(store,uri,this,super_registry));
	}
	
	public void add_tab_object(Dragonstone.Tab tab){
		tabs.append_page(tab,new Dragonstone.Widget.TabHead(tab));
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
		Dragonstone.Tab dt = (tabx as Dragonstone.Tab);
		if (dt is Dragonstone.Tab && dt != null) {
			dt.cleanup();
		}
		//if (tabs.get_n_pages() == 0) { add_new_tab(); }
	}
	
	public void close_all_tabs(){
		while(tabs.get_n_pages()>0){
			var widget = tabs.get_nth_page(0);
			tabs.remove_page(0);
			Dragonstone.Tab dt = (widget as Dragonstone.Tab);
			if (dt is Dragonstone.Tab && dt != null) {
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
