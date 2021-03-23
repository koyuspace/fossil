public class Fossil.Startup.Hypertext.Gtk {
	
	public static void setup_views(Fossil.SuperRegistry super_registry, Fossil.Interface.Settings.Provider? settings_provider){
		print("[startup][hypertext][gtk] setup_views()\n");
		var view_registry = (super_registry.retrieve("gtk.views") as Fossil.GtkUi.LegacyViewRegistry);
		if (view_registry != null){
			// Get get all the theming stuff set up
			var theme_loader = new Fossil.GtkUi.SettingsIntegration.SettingsHypertextJsonThemeLoader(settings_provider, "themes.");
			Fossil.GtkUi.Interface.Theming.HypertextViewTheme? default_theme = theme_loader.get_theme_by_name("default");
			if(default_theme == null) { //fall back to an empty theme
				default_theme = new Fossil.GtkUi.Theming.HypertextViewTheme();
			}
			var theme_provider = new Fossil.GtkUi.Theming.DefaultHypertextViewThemeProvider(default_theme);
			//setup the theme rule provider
			var theme_rule_provider = new Fossil.GtkUi.SettingsIntegration.SettingsHypertextJsonThemeRuleProvider(settings_provider, "settings.theme_rules.json");
			theme_provider.set_theme_loader(theme_loader);
			theme_provider.set_rule_provider(theme_rule_provider);
			// Get a gophertype registry gfot the gopher token parser in the DefaultTokenParserFactory
			var gopher_type_registry = (super_registry.retrieve("gopher.types") as Fossil.Registry.GopherTypeRegistry);
			if (gopher_type_registry == null) {
				gopher_type_registry = new Fossil.Registry.GopherTypeRegistry.default_configuration();
			}
			var parser_factory = new Fossil.Document.DefaultTokenParserFactory(gopher_type_registry);
			//register the hypertext view
			view_registry.add_view("hypertext",() => {	
				return new Fossil.GtkUi.View.Hypertext(parser_factory, theme_provider);
			});
			view_registry.add_rule(new Fossil.GtkUi.LegacyViewRegistryRule.resource_view("text/gemini","hypertext"));
			view_registry.add_rule(new Fossil.GtkUi.LegacyViewRegistryRule.resource_view("text/gopher","hypertext"));
			view_registry.add_rule(new Fossil.GtkUi.LegacyViewRegistryRule.resource_view("text/", "hypertext"));
			view_registry.add_rule(new Fossil.GtkUi.LegacyViewRegistryRule.resource_view("application/xml", "hypertext"));
			view_registry.add_rule(new Fossil.GtkUi.LegacyViewRegistryRule.resource_view("application/json", "hypertext"));
		}
	}

}
