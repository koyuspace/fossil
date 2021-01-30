public class Dragonstone.Startup.Frontend.Settings {

	public static void register_settings_object(Dragonstone.SuperRegistry super_registry){
		print("[startup][frontend][settings] register_settings_object()\n");
		var settings_registry = super_registry.retrieve("core.settings") as Dragonstone.Registry.SettingsRegistry;
		if (settings_registry == null){
			print("[startup][frontend][settings][error] No settings registry found!\n");
			return;
		}
		var settings_object = new Dragonstone.Settings.KVSettings("settings.frontend.kv");
		settings_registry.add_bridge("frontend",settings_object);
		super_registry.store("settings.frontend",settings_object);
	}
	
	public static void register_default_settings(Dragonstone.SuperRegistry super_registry){
		print("[startup][frontend][settings] register_default_settings()\n");
		var provider = super_registry.retrieve("core.settings.default_provider") as Dragonstone.Interface.Settings.Provider;
		if (provider == null){
			print("[startup][frontend][settings][error] No default settings provider found!\n");
			return;
		}
		provider.upload_object("settings.frontend.kv","
			new_tab_uri: test://
		");
	}
}
