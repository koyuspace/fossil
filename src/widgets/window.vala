public class Dragonstone.Window : Gtk.ApplicationWindow {
	
	public GLib.Settings settings;
	public Gtk.Notebook tabs;
	public Dragonstone.ResourceStore store;	
	
	
	public Window(Gtk.Application application) {
		Object(
			application: application
		);
	}
	
	construct {
		title = "Project Dragonstone";
		window_position = Gtk.WindowPosition.CENTER;
		set_default_size(600,400);
		
		settings = new GLib.Settings("com.gitlab.baschdel.Dragonstone");
		
		//place window where it has been bofore closing
		move(settings.get_int("main-window-pos-x"),settings.get_int("main-window-pos-y"));
		resize(settings.get_int("main-window-width"),settings.get_int("main-window-height"));
		
		delete_event.connect( e => {
			return before_destroy();
		});
		
		//"content"
		tabs = new Gtk.Notebook();
		tabs.scrollable = true;
		
		var addButton = new Gtk.Button.from_icon_name("tab-new-symbolic");
		addButton.relief = Gtk.ReliefStyle.NONE;
		addButton.clicked.connect(add_new_tab);
		addButton.show_all();
		tabs.set_action_widget(addButton,Gtk.PackType.END);
		
		//add some dummy tabs
		store = new Dragonstone.Store.Switch.default_configuration();
		
		add_tab("test://");
		
		add(tabs);
		
		//header bar
		var headerbar = new Dragonstone.HeaderBar(tabs);
		set_titlebar (headerbar);
		
		show_all();
	}
	
	//fills out the destination with the default address
	public void add_new_tab(){
		add_tab("test://");
	}
	
	public void add_tab(string uri){
		var tab = new Dragonstone.Tab(store,uri,this);
		tabs.append_page(tab,new Dragonstone.Widget.TabHead(tab));
		tabs.set_tab_reorderable(tab,true);
		tabs.set_current_page(-1);
	}
	
	public void close_tab(Gtk.Widget tab){
		tabs.remove_page(tabs.page_num(tab));
		if (tab is Dragonstone.Tab && tab != null) {
			(tab as Dragonstone.Tab).cleanup();
		}
		if (tabs.get_n_pages() == 0) {
			add_new_tab();
		}
	}
	
	public void close_all_tabs(){
		while(tabs.get_n_pages()>0){
			var widget = tabs.get_nth_page(0);
			tabs.remove_page(0);
			if (widget is Dragonstone.Tab && widget != null) {
				(widget as Dragonstone.Tab).cleanup();
			}
		}
	}
	
	public bool before_destroy() {
		//save window dimensions and position before closing
		int width, height, x, y;
		get_size(out width,out height);
		get_position(out x,out y);
		settings.set_int("main-window-width",width);
		settings.set_int("main-window-height",height);
		settings.set_int("main-window-pos-x",x);
		settings.set_int("main-window-pos-y",y);
		close_all_tabs();
		return false;
	}
}
