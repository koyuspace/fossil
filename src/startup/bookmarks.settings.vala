public class Dragonstone.Startup.Bookmarks.Settings {
	public static void register_settings_bridge(Dragonstone.SuperRegistry super_registry){
		print("[startup][bookmarks][settings] register_settings_bridge()\n");
		var settings_registry = super_registry.retrieve("core.settings") as Dragonstone.Registry.SettingsRegistry;
		var bookmark_registry = (super_registry.retrieve("core.bookmarks") as Dragonstone.Registry.BookmarkRegistry);
		if (settings_registry == null){
			print("[startup][bookmarks][settings][error] No settings registry found!\n");
			return;
		}
		if (bookmark_registry == null){
			print("[startup][bookmarks][settings][error] No bookmark registry found!\n");
			return;
		}
		var settings_object = new Dragonstone.SettingsBridge.Bookmarks("settings.bookmarks",bookmark_registry);
		settings_registry.add_bridge("bookmarks",settings_object);
	}
	
	public static void register_default_settings(Dragonstone.SuperRegistry super_registry){
		print("[startup][bookmarks][settings] register_default_settings()\n");
		var provider = super_registry.retrieve("core.settings.default_provider") as Dragonstone.Settings.Provider;
		if (provider == null){
			print("[startup][bookmarks][settings][error] No default settings provider found!\n");
			return;
		}
		provider.upload_object("settings.bookmarks","
			test://	The builtin Homepage
			gemini://gemini.conman.org/	The first ever gemini server
			gopher://khzae.net/	An awesome gopher server
		");
	}
}
