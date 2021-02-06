public class Dragonstone.GtkUi.SettingsIntegration.SettingsHypertextJsonThemeLoader : Dragonstone.GtkUi.Interface.Theming.HyperTextThemeLoader, Object {
	
	public string module_name = "Dragonstone.GtkUi.SettingsIntegration.SettingsHypertextJsonThemeLoader";
	
	private Dragonstone.Interface.Settings.Provider settings_provider;
	private string prefix;
	
	public SettingsHypertextJsonThemeLoader(Dragonstone.Interface.Settings.Provider settings_provider, string prefix){
		this.settings_provider = settings_provider;
		this.prefix = prefix;
	}
	
	  //////////////////////////////////////////////////////////////
	 // Dragonstone.GtkUi.Interface.Theming.HyperTextThemeLoader //
	//////////////////////////////////////////////////////////////
	
	public Dragonstone.GtkUi.Interface.Theming.HyperTextViewTheme? get_theme_by_name(string name){
		print(@"[Dragonstone.GtkUi.SettingsIntegration.SettingsHypertextJsonThemeLoader] Loading theme $name at $prefix$name.json\n");
		string path = @"$prefix$name.json";
		var theme_json = settings_provider.read_object(path);
		if (theme_json != null) {
			try {
				Json.Parser parser = new Json.Parser();
				parser.load_from_data(theme_json);
				var root_node = parser.get_root();
				if (root_node != null){
					if (root_node.get_node_type() == OBJECT) {
						var theme_object = root_node.get_object();
						return Dragonstone.GtkUi.JsonIntegration.Theming.HyperTextViewTheme.hyper_text_view_theme_from_json(theme_object);
					}
				}
				settings_provider.submit_client_report(new Dragonstone.Settings.Report(module_name, path, null, null, @"Imported theme"));
			} catch (Error e) {
				settings_provider.submit_client_report(new Dragonstone.Settings.Report(module_name, path, e.message, null, "Error while decoding json"));
				//print("[Dragonstone.GtkUi.SettingsIntegration.SettingsHypertextJsonThemeLoader] Error while parsing theme json: "+e.message+"\n");
			}
		}
		return null;
	}
	
}
