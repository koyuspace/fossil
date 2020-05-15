public class Dragonstone.Startup.Settings.Backend {

	public static void setup_providers(Dragonstone.SuperRegistry super_registry){
		print("[startup][settings][backend] setup_providers()\n");
		var settings_registry = super_registry.retrieve("core.settings") as Dragonstone.Registry.SettingsRegistry;
		if (settings_registry == null){
			print("[startup][settings][backend][error] No settings registry found!\n");
			return;
		}
		var defult_settings = new Dragonstone.Settings.RamProvider();
		settings_registry.add_provider(defult_settings);
		super_registry.store("core.settings.default_provider",defult_settings);
		//TODO: Replace with something truely persistant
		var peristant_settings = new Dragonstone.Settings.RamProvider();
		settings_registry.add_provider(peristant_settings);
	}
	
	public static void import_all(Dragonstone.SuperRegistry super_registry){
		print("[startup][settings][backend] import_all()\n");
		var settings_registry = super_registry.retrieve("core.settings") as Dragonstone.Registry.SettingsRegistry;
		if (settings_registry == null){ return; }
		settings_registry.import_all();
	}
}
