public class Dragonstone.Startup.Bookmarks.Settings {
	public static void register_settings_bridge(Dragonstone.SuperRegistry super_registry, Dragonstone.Interface.Settings.Provider settings_provider){
		print("[startup][bookmarks][settings] register_settings_bridge()\n");
		var bookmark_registry = (super_registry.retrieve("core.bookmarks") as Dragonstone.Registry.BookmarkRegistry);
		if (bookmark_registry == null){
			print("[startup][bookmarks][settings][error] No bookmark registry found!\n");
			return;
		}
		var bookmarks_settings_bride = new Dragonstone.Settings.Bridge.Bookmarks(settings_provider, "settings.bookmarks", bookmark_registry);
		//store in super_registry for now to prevent it from getting unloaded
		super_registry.store("bookmarks.settings_bridge",bookmarks_settings_bride);
	}
	
	public static void register_default_settings(Dragonstone.Interface.Settings.Provider settings_provider){
		print("[startup][bookmarks][settings] register_default_settings()\n");
		settings_provider.write_object("settings.bookmarks","
			test://	The builtin Homepage
			gemini://gemini.conman.org/	The first ever gemini server
			gopher://khzae.net/	An awesome gopher server
		");
	}
}
