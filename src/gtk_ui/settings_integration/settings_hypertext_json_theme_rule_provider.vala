public class Fossil.GtkUi.SettingsIntegration.SettingsHypertextJsonThemeRuleProvider : Fossil.GtkUi.Interface.HypertextThemeRuleProvider, Object {
	
	private List<Fossil.GtkUi.Theming.HypertextThemeRule> rules = new List<Fossil.GtkUi.Theming.HypertextThemeRule>();
	private Fossil.Interface.Settings.Provider settings_provider;
	private string path;
	public string module_name = "Fossil.GtkUi.SettingsIntegration.SettingsHypertextJsonThemeRuleProvider";
	
	public SettingsHypertextJsonThemeRuleProvider(Fossil.Interface.Settings.Provider settings_provider, string path){
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
				rules = new List<Fossil.GtkUi.Theming.HypertextThemeRule>();
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
								var rule = Fossil.GtkUi.JsonIntegration.Theming.HypertextThemeRule.rule_from_json(item.get_object());
								if (rule != null) {
									rules.append(rule);
									counter++;
								}
							}
						}
					}
				}
				settings_provider.submit_client_report(new Fossil.Settings.Report(module_name, path, null, null, @"Imported $counter rules"));
			} catch (Error e) {
				settings_provider.submit_client_report(new Fossil.Settings.Report(module_name, path, e.message, null, "Error while decoding json"));
				//print("[Fossil.GtkUi.SettingsIntegration.SettingsHypertextJsonThemeRuleProvider] Error while parsing json "+e.message+"\n");
			}
		}
	}
	
	  ////////////////////////////////////////////////////////////
	 // Fossil.GtkUi.Interface.HypertextThemeRuleProvider //
	////////////////////////////////////////////////////////////
	
	public void foreach_relevant_rule(string content_type, string uri, Func<Fossil.GtkUi.Theming.HypertextThemeRule> cb){
		rules.foreach(cb);
	}
	
}
