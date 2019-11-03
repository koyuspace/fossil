public class Dragonstone.Window : Gtk.ApplicationWindow {
	
	public GLib.Settings settings;
	public Gtk.Stack tabs;
	
	public Window(Gtk.Application application) {
		Object(
			application: application
		);
	}
	
	construct {
		title = "Gopher";
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
		var tab1 = new Dragonstone.Tab(new Dragonstone.GopherResourceStore(),"gopher://gopher.floodgap.com");
		var tab2 = new Dragonstone.Tab(new Dragonstone.GopherResourceStore(),"gopher://gopher.khzae.net");
		
		tabs.add_titled(tab1,"tab-1","TAB 1 (primary)");
		tabs.add_titled(tab2,"tab-2","TAB 2 (secondary)");
		
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
