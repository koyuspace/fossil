public class Dragonstone.Startup.Frontend.Settings {

	public static void register_settings_object(Dragonstone.SuperRegistry super_registry, Dragonstone.Interface.Settings.Provider settings_provider){
		print("[startup][frontend][settings] register_settings_object()\n");
		var settings_object = new Dragonstone.Settings.Bridge.KV(settings_provider, "settings.frontend.kv");
		super_registry.store("settings.frontend",settings_object);
	}
	
	public static void register_default_settings(Dragonstone.Interface.Settings.Provider settings_provider){
		print("[startup][frontend][settings] register_default_settings()\n");
		settings_provider.write_object("settings.frontend.kv","
			new_tab_uri: test://
		");
	}
}
