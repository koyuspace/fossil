public class Dragonstone.GtkUi.Theming.DefaultHyperTextViewThemeProvider : Dragonstone.GtkUi.Interface.Theming.HyperTextViewThemeProvider, Object {
	
	private Dragonstone.GtkUi.Interface.Theming.HyperTextThemeLoader? theme_loader = null;
	private Dragonstone.GtkUi.Interface.HyperTextThemeRuleProvider? rule_provider = null;
	private Dragonstone.GtkUi.Interface.Theming.HyperTextViewTheme default_theme;
	
	public DefaultHyperTextViewThemeProvider(Dragonstone.GtkUi.Interface.Theming.HyperTextViewTheme default_theme){
		this.default_theme = default_theme;
	}
	
	public void set_theme_loader(Dragonstone.GtkUi.Interface.Theming.HyperTextThemeLoader theme_loader){
		this.theme_loader = theme_loader;
	}
	
	public void set_rule_provider(Dragonstone.GtkUi.Interface.HyperTextThemeRuleProvider rule_provider){
		this.rule_provider = rule_provider;
	}
	
	  ////////////////////////////////////////////////////////////////////
	 // Dragonstone.GtkUi.Interface.Theming.HyperTextViewThemeProvider //
	////////////////////////////////////////////////////////////////////
	
	public Dragonstone.GtkUi.Interface.Theming.HyperTextViewTheme? get_theme(string content_type, string uri){
		print(@"[Dragonstone.GtkUi.Theming.DefaultHyperTextViewThemeProvider] Looking up theme for $uri $content_type\n");
		if (theme_loader == null && rule_provider == null){
			return null;
		}
		var parsed_uri = new Dragonstone.Util.ParsedUri(uri);
		Dragonstone.GtkUi.Interface.Theming.HyperTextViewTheme? best_theme = null;
		int best_score = 0;
		int score = 0;
		rule_provider.foreach_relevant_rule(content_type, uri, (rule) => {
			score = rule.calculate_score(content_type, parsed_uri.scheme, parsed_uri.host, parsed_uri.port, parsed_uri.path);
			if (score > best_score){
				print(@"\t$(rule.theme_name) @ $score\n");
				//load the theme to make sure it can be loaded
				var theme = theme_loader.get_theme_by_name(rule.theme_name);
				if (theme != null) {
					print("\t\tloaded successfully!\n");
					best_score = score;
					best_theme = theme;
				}
			}
		});
		return best_theme;
	}
	
	public Dragonstone.GtkUi.Interface.Theming.HyperTextViewTheme get_default_theme(){
		return default_theme;
	}
	
}
