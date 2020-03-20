
public class Dragonstone.Application : Gtk.Application {
	
	public Application() {
		Object (
			application_id: "com.gitlab.baschdel.Dragonstone",
			flags: ApplicationFlags.FLAGS_NONE
		);
	}
	
	protected override void activate() {
		build_window();
	}
	
	protected override void open(GLib.File[] files, string hint) {
		build_window();
	}
	
	private void build_window() {
		var window = new Dragonstone.Window(this);
		add_window(window);
	}
}
