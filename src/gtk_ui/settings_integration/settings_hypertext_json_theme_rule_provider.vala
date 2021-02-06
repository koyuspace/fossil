public class Dragonstone.GtkUi.SettingsIntegration.SettingsHypertextJsonThemeRuleProvider : Dragonstone.GtkUi.Interface.HyperTextThemeRuleProvider, Object {
	
	private List<Dragonstone.GtkUi.Theming.HyperTextThemeRule> rules = new List<Dragonstone.GtkUi.Theming.HyperTextThemeRule>();
	private Dragonstone.Interface.Settings.Provider settings_provider;
	private string path;
	public string module_name = "Dragonstone.GtkUi.SettingsIntegration.SettingsHypertextJsonThemeRuleProvider";
	
	public SettingsHypertextJsonThemeRuleProvider(Dragonstone.Interface.Settings.Provider settings_provider, string path){
		this.settings_provider = settings_provider;
		this.path = path;
		reload();
		settings_provider.settings_updated.connect(update_listener);
	}
	
	~SettingsHypertextJsonThemeRuleProvider(){
		settings_provider.settings_updated.disconnect(update_listener);
	}
	
	private void update_listener(string path_prefix){
		if (path.has_prefix(path_prefix)) {
			reload();
		}
	}
	
	public void reload(){
		lock(rules) {
			if (rules.length()>0){
				rules = new List<Dragonstone.GtkUi.Theming.HyperTextThemeRule>();
			}
			var rules_json = settings_provider.read_object(path);
			if (rules_json == null) {
				return;
			}
			try {
				uint counter = 0;
				Json.Parser parser = new Json.Parser();
				parser.load_from_data(rules_json);
				var root_node = parser.get_root();
				if (root_node != null){
					if (root_node.get_node_type() == ARRAY) {	
						var rules_array = root_node.get_array();
						foreach (unowned Json.Node item in rules_array.get_elements()) {
							if (item.get_node_type() == OBJECT) {
								var rule = Dragonstone.GtkUi.JsonIntegration.Theming.HyperTextThemeRule.rule_from_json(item.get_object());
								if (rule != null) {
									rules.append(rule);
									counter++;
								}
							}
						}
					}
				}
				settings_provider.submit_client_report(new Dragonstone.Settings.Report(module_name, path, null, null, @"Imported $counter rules"));
			} catch (Error e) {
				settings_provider.submit_client_report(new Dragonstone.Settings.Report(module_name, path, e.message, null, "Error while decoding json"));
				//print("[Dragonstone.GtkUi.SettingsIntegration.SettingsHypertextJsonThemeRuleProvider] Error while parsing json "+e.message+"\n");
			}
		}
	}
	
	  ////////////////////////////////////////////////////////////
	 // Dragonstone.GtkUi.Interface.HyperTextThemeRuleProvider //
	////////////////////////////////////////////////////////////
	
	public void foreach_relevant_rule(string content_type, string uri, Func<Dragonstone.GtkUi.Theming.HyperTextThemeRule> cb){
		rules.foreach(cb);
	}
	
}
