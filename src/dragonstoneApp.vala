
public class Dragonstone.Application : Gtk.Application {
	
	public Dragonstone.SuperRegistry super_registry { get; protected set; }
	
	public Application() {
		Object (
			application_id: "com.gitlab.baschdel.Dragonstone",
			flags: ApplicationFlags.FLAGS_NONE
		);
		this.shutdown.connect(on_shutdown);
		super_registry = new Dragonstone.SuperRegistry();
		//Initalize core registries
		super_registry.store("core.mimeguesser",new Dragonstone.Registry.MimetypeGuesser.default_configuration());
		super_registry.store("core.stores",new Dragonstone.Registry.StoreRegistry.default_configuration());
		super_registry.store("core.uri_autoprefixer",new Dragonstone.Registry.UriAutoprefix());
		//Initalize Cache
		Dragonstone.Startup.Cache.Backend.setup_store(super_registry); //register before switch
		Dragonstone.Startup.About.Backend.setup_store(super_registry);
		//Initalize Bookmarks
		//Dragonstone.Startup.Bookmarks.Backend.setup_registry(super_registry);
		//Dragonstone.Startup.Bookmarks.Backend.setup_default_folders(super_registry);
		//Dragonstone.Startup.Bookmarks.Backend.setup_about_page(super_registry);
		//Dragonstone.Startup.Bookmarks.Backend.setup_store(super_registry);
		//Initalize backends
		Dragonstone.Startup.Cache.Backend.setup_about_page(super_registry);
		Dragonstone.Startup.Gopher.Backend.setup_gophertypes(super_registry);
		Dragonstone.Startup.Gopher.Backend.setup_mimetypes(super_registry);
		Dragonstone.Startup.Gopher.Backend.setup_store(super_registry);
		Dragonstone.Startup.Gopher.Backend.setup_uri_autocompletion(super_registry);
		Dragonstone.Startup.Gemini.Backend.setup_mimetypes(super_registry);
		Dragonstone.Startup.Gemini.Backend.setup_store(super_registry);
		Dragonstone.Startup.Gemini.Backend.setup_uri_autocompletion(super_registry);
		Dragonstone.Startup.File.Backend.setup_store(super_registry);
		Dragonstone.Startup.File.Backend.setup_uri_autocompletion(super_registry);
		Dragonstone.Startup.Finger.Backend.setup_store(super_registry);
		Dragonstone.Startup.Finger.Backend.setup_uri_autocompletion(super_registry);
		Dragonstone.Startup.StoreSwitch.setup_store(super_registry);
		//Initalize localization
		Dragonstone.Startup.LocalizationRegistry.setup_translation_registry(super_registry);
		Dragonstone.Startup.Localization.English.setup_language(super_registry);
		Dragonstone.Startup.Localization.English.use_language(super_registry);
		//Initalize fontend registries
		var translation = (super_registry.retrieve("localization.translation") as Dragonstone.Registry.TranslationRegistry);
		super_registry.store("gtk.views",new Dragonstone.Registry.ViewRegistry.default_configuration(translation));
		super_registry.store("gtk.source_views",new Dragonstone.Registry.ViewRegistry.source_view_configuration());
		//Initalize frontends
		Dragonstone.Startup.Cache.Gtk.setup_views(super_registry);
		//Dragonstone.Startup.Bookmarks.Gtk.setup_views(super_registry);
		Dragonstone.Startup.File.Gtk.setup_views(super_registry);
		Dragonstone.Startup.Gopher.Gtk.setup_views(super_registry);
		Dragonstone.Startup.Gemini.Gtk.setup_views(super_registry);
	}
	
	protected override void activate() {
		build_window();
	}
	
	protected override void open(GLib.File[] files, string hint) {
		build_window();
	}
	
	protected void on_shutdown() {
		var cache = (super_registry.retrieve("core.stores.cache") as Dragonstone.Cache);
		if (cache != null){ cache.erase(); }
	}
	
	private void build_window() {
		var window = new Dragonstone.Window(this);
		add_window(window);
	}
}
