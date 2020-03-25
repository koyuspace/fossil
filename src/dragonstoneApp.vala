
public class Dragonstone.Application : Gtk.Application {
	
	public Dragonstone.SuperRegistry super_registry { get; protected set; }
	
	public Application() {
		Object (
			application_id: "com.gitlab.baschdel.Dragonstone",
			flags: ApplicationFlags.FLAGS_NONE
		);
		super_registry = new Dragonstone.SuperRegistry();
		super_registry.store("gopher.types",new Dragonstone.Registry.GopherTypeRegistry.default_configuration());
		super_registry.store("core.mimeguesser",new Dragonstone.Registry.MimetypeGuesser.default_configuration());
		super_registry.store("core.stores",new Dragonstone.Registry.StoreRegistry.default_configuration());
		super_registry.store("core.uri_autoprefixer",new Dragonstone.Registry.UriAutoprefix.default_configuration());
		super_registry.store("gtk.views",new Dragonstone.Registry.ViewRegistry.default_configuration());
		super_registry.store("gtk.source_views",new Dragonstone.Registry.ViewRegistry.source_view_configuration());
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
