public class Dragonstone.GtkUi.SettingsIntegration.SettingsHypertextJsonThemeRuleProvider : Dragonstone.GtkUi.Interface.HyperTextThemeRuleProvider, Object {
	
	private List<Dragonstone.GtkUi.Theming.HyperTextThemeRule> rules = new List<Dragonstone.GtkUi.Theming.HyperTextThemeRule>();
	private Dragonstone.Registry.SettingsRegistry settings_registry;
	private string path;
	
	public SettingsHypertextJsonThemeRuleProvider(Dragonstone.Registry.SettingsRegistry settings_registry, string path){
		this.settings_registry = settings_registry;
		this.path = path;
		reload();
	}
	
	public void reload(){
		if (rules.length()>0){
			rules = new List<Dragonstone.GtkUi.Theming.HyperTextThemeRule>();
		}
		var rules_rom = settings_registry.get_object(path);
		if (rules_rom == null) {
			return;
		}
		try {
			Json.Parser parser = new Json.Parser();
			parser.load_from_data(rules_rom.content);
			var root_node = parser.get_root();
			if (root_node != null){
				if (root_node.get_node_type() == ARRAY) {	
					var rules_array = root_node.get_array();
					foreach (unowned Json.Node item in rules_array.get_elements()) {
						if (item.get_node_type() == OBJECT) {
							var rule = Dragonstone.GtkUi.JsonIntegration.Theming.HyperTextThemeRule.rule_from_json(item.get_object());
							if (rule != null) {
								rules.append(rule);
							}
						}
					}
				}
			}
		} catch (Error e) {
			print("[Dragonstone.GtkUi.SettingsIntegration.SettingsHypertextJsonThemeRuleProvider] Error while parsing json "+e.message+"\n");
		}
	}
	
	  ////////////////////////////////////////////////////////////
	 // Dragonstone.GtkUi.Interface.HyperTextThemeRuleProvider //
	////////////////////////////////////////////////////////////
	
	public void foreach_relevant_rule(string content_type, string uri, Func<Dragonstone.GtkUi.Theming.HyperTextThemeRule> cb){
		rules.foreach(cb);
	}
	
}
