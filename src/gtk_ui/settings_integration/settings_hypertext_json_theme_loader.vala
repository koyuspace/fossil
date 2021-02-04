public class Dragonstone.GtkUi.SettingsIntegration.SettingsHypertextJsonThemeLoader : Dragonstone.GtkUi.Interface.Theming.HyperTextThemeLoader, Object {
	
	public static Dragonstone.GtkUi.Theming.HyperTextViewTheme? load_theme(string json){
		try {
			Json.Parser parser = new Json.Parser();
			parser.load_from_data(json);
			var root_node = parser.get_root();
			if (root_node != null){
				if (root_node.get_node_type() == OBJECT) {
					var theme_object = root_node.get_object();
					return Dragonstone.GtkUi.JsonIntegration.Theming.HyperTextViewTheme.hyper_text_view_theme_from_json(theme_object);
				}
			}
		} catch (Error e) {
			print("[Dragonstone.GtkUi.SettingsIntegration.SettingsHypertextJsonThemeLoader] Error while parsing theme json: "+e.message+"\n");
		}
		return null;
	}
	
	private Dragonstone.Registry.SettingsRegistry settings_registry;
	private string prefix;
	
	public SettingsHypertextJsonThemeLoader(Dragonstone.Registry.SettingsRegistry settings_registry, string prefix){
		this. settings_registry = settings_registry;
		this.prefix = prefix;
	}
	
	  //////////////////////////////////////////////////////////////
	 // Dragonstone.GtkUi.Interface.Theming.HyperTextThemeLoader //
	//////////////////////////////////////////////////////////////
	
	public Dragonstone.GtkUi.Interface.Theming.HyperTextViewTheme? get_theme_by_name(string name){
		print(@"[Dragonstone.GtkUi.SettingsIntegration.SettingsHypertextJsonThemeLoader] Loading theme $name at $prefix$name.json\n");
		var theme_rom = settings_registry.get_object(@"$prefix$name.json");
		if (theme_rom != null) {
			return load_theme(theme_rom.content);
		}
		return null;
	}
	
}
