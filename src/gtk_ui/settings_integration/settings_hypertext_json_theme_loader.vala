public class Fossil.GtkUi.SettingsIntegration.SettingsHypertextJsonThemeLoader : Fossil.GtkUi.Interface.Theming.HypertextThemeLoader, Object {
	
	public string module_name = "Fossil.GtkUi.SettingsIntegration.SettingsHypertextJsonThemeLoader";
	
	private Fossil.Interface.Settings.Provider settings_provider;
	private string prefix;
	private HashTable<string,Fossil.GtkUi.Interface.Theming.HypertextViewTheme> theme_cache = new HashTable<string,Fossil.GtkUi.Interface.Theming.HypertextViewTheme>(str_hash, str_equal);
	
	public SettingsHypertextJsonThemeLoader(Fossil.Interface.Settings.Provider settings_provider, string prefix){
		this.settings_provider = settings_provider;
		this.prefix = prefix;
		this.settings_provider.settings_updated.connect(on_settings_updated);
	}
	
	~SettingsHypertextJsonThemeLoader(){
		this.settings_provider.settings_updated.disconnect(on_settings_updated);
	}
	
	private void on_settings_updated(string path){
		lock(theme_cache){
			if (path.has_prefix(prefix)){
				if (path == prefix || path+"." == prefix){
					theme_cache.remove_all();	
				} else {
					theme_cache.remove(path.substring(prefix.length));
				}
			}
		}
	}
	
	private Fossil.GtkUi.Interface.Theming.HypertextViewTheme? load_theme_by_name(string name){
		print(@"[Fossil.GtkUi.SettingsIntegration.SettingsHypertextJsonThemeLoader] Loading theme $name at $prefix$name.json\n");
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
						return Fossil.GtkUi.JsonIntegration.Theming.HypertextViewTheme.hyper_text_view_theme_from_json(theme_object);
					}
				}
				settings_provider.submit_client_report(new Fossil.Settings.Report(module_name, path, null, null, @"Imported theme"));
			} catch (Error e) {
				settings_provider.submit_client_report(new Fossil.Settings.Report(module_name, path, e.message, null, "Error while decoding json"));
				//print("[Fossil.GtkUi.SettingsIntegration.SettingsHypertextJsonThemeLoader] Error while parsing theme json: "+e.message+"\n");
			}
		}
		return null;
	}
	
	  //////////////////////////////////////////////////////////////
	 // Fossil.GtkUi.Interface.Theming.HypertextThemeLoader //
	//////////////////////////////////////////////////////////////
	
	public Fossil.GtkUi.Interface.Theming.HypertextViewTheme? get_theme_by_name(string name){
		lock (theme_cache) {
			Fossil.GtkUi.Interface.Theming.HypertextViewTheme? theme = theme_cache.get(@"$name.json");
			if (theme != null){
				return theme;
			}
			theme = load_theme_by_name(name);
			theme_cache.set(@"$name.json", theme);
			return theme;
		}
	}
	
}
