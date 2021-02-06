public class Dragonstone.Startup.Settings.Backend {
	
	public static Dragonstone.Interface.Settings.Provider? get_file_settings_provider(string subdirectory, string prefix, string name){
		string settingsdir = GLib.Environment.get_user_config_dir();
		settingsdir = settingsdir+"/dragonstone/"+subdirectory;
		GLib.DirUtils.create_with_parents(settingsdir,16832);
		var provider = new Dragonstone.Settings.FileProvider(settingsdir, name, prefix);
		return provider;
	}
	
}
