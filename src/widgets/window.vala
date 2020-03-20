public class Dragonstone.Window : Gtk.ApplicationWindow {
	
	public GLib.Settings settings;
	public Gtk.Stack tabs;
	
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
		tabs = new Gtk.Stack();
		tabs.expand = true;
		
		//add some dummy tabs
		var store = new Dragonstone.Store.Switch.default_configuration();
		
		var tab0 = new Dragonstone.Tab(store,"test://",this);
		var tab1 = new Dragonstone.Tab(store,"test://",this);
		
		tabs.add_titled(tab0,"tab-0","TAB 0");
		tabs.add_titled(tab1,"tab-1","TAB 1");
		
		add(tabs);
		
		//header bar
		var headerbar = new Dragonstone.HeaderBar(tabs);
		set_titlebar (headerbar);
		
		show_all();
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
		return false;
	}
}
