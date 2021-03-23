
public class Fossil.GtkUi.Application : Gtk.Application {
	
	public Fossil.SuperRegistry? super_registry { get; protected set; default=null; }
	
	public Application() {
		Object (
			application_id: "com.gitlab.baschdel.Fossil",
			flags: ApplicationFlags.CAN_OVERRIDE_APP_ID | ApplicationFlags.HANDLES_COMMAND_LINE
		);
	}
	
	public void initalize() {
		if (super_registry != null) { return; }
		this.shutdown.connect(on_shutdown);
		super_registry = new Fossil.SuperRegistry();
		//TODO: remove this asm thingy together with the super_registry, was a bad idea
		//      integrate with settings (json) instead
		//Initalize ASM constructors
		var init_object = new Fossil.Asm.SimpleAsmObject();
		Fossil.AsmInit.Bookmarks.Registry.register_initalizer("bookmark_registry",init_object);
		Fossil.AsmInit.Mimeguesser.Registry.register_initalizer("mimeguesser_registry",init_object);
		Fossil.AsmInit.Session.Registry.register_initalizer("session_registry",init_object);
		Fossil.AsmInit.Store.Registry.register_initalizer("store_registry",init_object);
		Fossil.AsmInit.UriAutoprefix.Registry.register_initalizer("uri_autoprefix_registry",init_object);
		//make a scriptrunner
		var scriptrunner = new Fossil.Asm.Scriptrunner(super_registry);
		//Initalize core registries
		super_registry.store("init",init_object);
		super_registry.store("core.mimeguesser",new Fossil.Registry.MimetypeGuesser.default_configuration());
		super_registry.store("core.stores",new Fossil.Registry.StoreRegistry.default_configuration());
		scriptrunner.exec_line("init:uri_autoprefix_registry\tcore.uri_autoprefixer",super_registry);
		scriptrunner.exec_line("init:session_registry\tcore.sessions",super_registry);
		scriptrunner.exec_line("init:bookmark_registry\tcore.bookmarks",super_registry);
		//initalize settings
		var default_settings_provider = new Fossil.Settings.RamProvider();
		var persistant_settings_provider = Fossil.Startup.Settings.Backend.get_file_settings_provider("","settings.", "persistant_settings_provider");
		var theme_settings_provider = Fossil.Startup.Settings.Backend.get_file_settings_provider("themes/","themes.","theme_settings_provider");
		var core_settings_provider = new Fossil.Settings.Context.Fallback();
		core_settings_provider.add_fallback(persistant_settings_provider);
		core_settings_provider.add_fallback(theme_settings_provider);
		core_settings_provider.add_fallback(default_settings_provider);
		//setup setting logging
		core_settings_provider.submit_client_report.connect((report) => {
			print(@"[settings][client]$report\n");
		});
		core_settings_provider.provider_report.connect((report) => {
			print(@"[settings][provider]$report\n");
		});
		//Set defaults
		Fossil.Startup.Hypertext.Settings.register_default_settings(default_settings_provider);
		Fossil.Startup.Frontend.Settings.register_default_settings(default_settings_provider);
		Fossil.Startup.Bookmarks.Settings.register_default_settings(default_settings_provider);
		//Initaize settings bridges
		Fossil.Startup.Frontend.Settings.register_settings_object(super_registry, core_settings_provider);
		Fossil.Startup.Bookmarks.Settings.register_settings_bridge(super_registry, core_settings_provider);
		//Initalize Cache
		//Fossil.Startup.Cache.Backend.setup_store(super_registry); //register before switch
		Fossil.Startup.About.Backend.setup_store(super_registry);
		//register gophertypes
		Fossil.Startup.Gopher.Backend.setup_gophertypes(super_registry);
		Fossil.Startup.GopherWrite.Backend.setup_gophertypes(super_registry);
		//Initalize backends
		Fossil.Startup.Bookmarks.Backend.setup_about_page(super_registry);
		Fossil.Startup.Cache.Backend.setup_about_page(super_registry);
		Fossil.Startup.Gopher.Backend.setup_mimetypes(super_registry);
		Fossil.Startup.Gopher.Backend.setup_store(super_registry);
		Fossil.Startup.Gopher.Backend.setup_uri_autocompletion(super_registry);
		Fossil.Startup.GopherWrite.Backend.setup_store(super_registry);
		Fossil.Startup.Gemini.Backend.setup_mimetypes(super_registry);
		Fossil.Startup.Gemini.Backend.setup_store(super_registry);
		Fossil.Startup.Gemini.Backend.setup_uri_autocompletion(super_registry);
		Fossil.Startup.GeminiUpload.Backend.setup_store(super_registry);
		Fossil.Startup.GeminiWrite.Backend.setup_store(super_registry);
		Fossil.Startup.File.Backend.setup_store(super_registry);
		Fossil.Startup.File.Backend.setup_uri_autocompletion(super_registry);
		Fossil.Startup.Finger.Backend.setup_store(super_registry);
		Fossil.Startup.Finger.Backend.setup_uri_autocompletion(super_registry);
		Fossil.Startup.StoreSwitch.setup_store(super_registry);
		Fossil.Startup.Utilfossil.Backend.setup_about_page(super_registry);
		//Initalize sessions
		Fossil.Startup.Sessions.Backend.register_core_sessions(super_registry);
		//Initalize localization
		Fossil.Startup.LocalizationRegistry.setup_translation_registry(super_registry);
		Fossil.Startup.Localization.English.setup_language(super_registry);
		Fossil.Startup.Localization.English.use_language(super_registry);
		//Initalize fontend registries
		var translation = (super_registry.retrieve("localization.translation") as Fossil.Registry.TranslationRegistry);
		super_registry.store("gtk.views",new Fossil.GtkUi.LegacyViewRegistry.default_configuration(translation));
		//Initalize frontends
		Fossil.Startup.Bookmarks.Gtk.setup_views(super_registry);
		Fossil.Startup.Cache.Gtk.setup_views(super_registry);
		Fossil.Startup.Sessions.Gtk.setup_views(super_registry);
		Fossil.Startup.File.Gtk.setup_views(super_registry);
		Fossil.Startup.Hypertext.Gtk.setup_views(super_registry, core_settings_provider);
		Fossil.Startup.Gemini.Gtk.setup_views(super_registry);
		Fossil.Startup.Upload.Gtk.setup_views(super_registry);
		Fossil.Startup.Utilfossil.Gtk.setup_views(super_registry);
	}
	
	protected override void activate() {
		initalize();
		build_window();
	}
	
	protected override int command_line(ApplicationCommandLine command_line) {
		initalize();
		Fossil.Window? window = (Fossil.Window) get_active_window();
		bool new_window = false;
		if (window == null) {
			window = build_window();
			new_window = true;
		}
		string session_id = "core.default";
		bool next_is_sessionid = false;
		bool firstarg = true;
		bool uri_opened = false;
		foreach (string arg in command_line.get_arguments()){
			if (firstarg) {
				firstarg = false;
			} else if (next_is_sessionid) {
				session_id = arg;
			} else if (arg == "--new-window") {
				if (!new_window) {
					if (!uri_opened) {
						window.add_new_tab();
					}
					uri_opened = false;
					window = build_window();
				}
				new_window = false;
			} else if (arg == "--session") {
				next_is_sessionid = true;
			} else {
				string uri = arg;
				var pwd = command_line.get_cwd();
				if (pwd != null) {
					if (!pwd.has_suffix("/")) {
						pwd = pwd+"/";
					}
					uri = Fossil.Util.Uri.join("file://"+pwd, arg);
				}
				window.add_tab(uri,session_id);
				uri_opened = true;
				new_window = false;
			}
		}
		if (!uri_opened) {
			window.add_new_tab();
		}
		return 0;
	}
	
	protected void on_shutdown() {
		var cache = (super_registry.retrieve("core.stores.cache") as Fossil.Interface.Cache);
		if (cache != null){ cache.erase(); }
		var sessions = (super_registry.retrieve("core.sessions") as Fossil.Registry.SessionRegistry);
		if (sessions != null){ sessions.erase_all_caches(); }
		var bookmark_bridge = (super_registry.retrieve("bookmarks.settings_bridge") as Fossil.Settings.Bridge.Bookmarks);
		if (bookmark_bridge != null){ bookmark_bridge.export(); }
	}
	
	private Fossil.Window build_window() {
		var window = new Fossil.Window(this);
		add_window(window);
		return window;
	}
}
