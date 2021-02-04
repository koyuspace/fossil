public class Dragonstone.Startup.Hypertext.Gtk {
	
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
			print("[startup][hypertext][gtk] Error while parsing theme json: "+e.message+"\n");
		}
		return null;
	}
	
	public static Dragonstone.GtkUi.Theming.HyperTextViewTheme get_default_theme(Dragonstone.Registry.SettingsRegistry? settings_registry){
		string temporary_style_json = """
{
	"prefixes":{
		"link":"{{{link_icon}}}",
		"link :inline":" ",
		"list_item":"▶ ",
		"parser_error":"[PARSER_ERROR] ",
		"link_without_uri":"[PARSER MISTAKE] Link without uri: ",
		"search_without_uri":"[PARSER MISTAKE] Search without uri: ",
		"exception":"[INTERNAL ERROR]"
	},
	"tag_themes":{
		"link":{
			"scale":1.1,
			"font":"italic"
		},
		"link :hover":{
			"underline":"single",
			"scale":1.15
		},
		"link :prefix":{
			"scale":1.15
		},
		"link_icon":{
			"scale":1.5
		},
		"title +0":{
			"scale":1.7
		},
		"title +1":{
			"scale":1.5
		},
		"title":{
			"scale":1.2
		},
		"quote":{
			"font":"oblique"
		},
		"description":{
			"scale":0.9,
			"font":"italic",
			"indent":10
		},
		"paragraph :preformatted":{
			"wrap_mode":"none",
			"indent":10
		},
		"error":{
			"foreground":"#FB3934"
		},
		"parser_error":{
			"foreground":"#FB3934",
			"font":"italic"
		},
		"exception":{
			"foreground":"#FB3934",
			"font":"italic"
		},
		"*:preformatted":{
			"font":"monospace"
		},
		"*":{
			"wrap_mode":"word_char"
		}
	}
}
		""";
		Dragonstone.GtkUi.Theming.HyperTextViewTheme? default_theme = null;
		if (settings_registry != null){
			var theme_rom = settings_registry.get_object("settings.theme.json");
			if (theme_rom != null) {
				default_theme = load_theme(theme_rom.content);
			}
		}
		if (default_theme == null) { //fall back to the theme above
			default_theme = load_theme(temporary_style_json);
		}
		if(default_theme == null) { //fall back to an empty theme
			default_theme = new Dragonstone.GtkUi.Theming.HyperTextViewTheme();
		}
		return default_theme;
	}
	
	public static void setup_views(Dragonstone.SuperRegistry super_registry){
		print("[startup][hypertext][gtk] setup_views()\n");
		
		var view_registry = (super_registry.retrieve("gtk.views") as Dragonstone.GtkUi.ViewRegistry);
		if (view_registry != null){
			var settings_registry = super_registry.retrieve("core.settings") as Dragonstone.Registry.SettingsRegistry;
			// Get get all the theming stuff set up
			Dragonstone.GtkUi.Theming.HyperTextViewTheme? default_theme = get_default_theme(settings_registry);
			var theme_provider = new Dragonstone.GtkUi.Theming.DefaultHyperTextViewThemeProvider(default_theme);
			var theme_loader = new Dragonstone.GtkUi.SettingsIntegration.SettingsHypertextJsonThemeLoader(settings_registry, "settings.themes.");
			var theme_rule_provider = new Dragonstone.GtkUi.SettingsIntegration.SettingsHypertextJsonThemeRuleProvider(settings_registry, "settings.theme_rules.json");
			theme_provider.set_theme_loader(theme_loader);
			theme_provider.set_rule_provider(theme_rule_provider);
			// Get a gophertype registry gfot the gopher token parser in the DefaultTokenParserFactory
			var gopher_type_registry = (super_registry.retrieve("gopher.types") as Dragonstone.Registry.GopherTypeRegistry);
			if (gopher_type_registry == null) {
				gopher_type_registry = new Dragonstone.Registry.GopherTypeRegistry.default_configuration();
			}
			var parser_factory = new Dragonstone.Document.DefaultTokenParserFactory(gopher_type_registry);
			//register the hypertext view
			view_registry.add_view("hypertext",() => {	
				return new Dragonstone.GtkUi.View.Hypertext(parser_factory, theme_provider);
			});
			view_registry.add_rule(new Dragonstone.GtkUi.ViewRegistryRule.resource_view("text/gemini","hypertext"));
			view_registry.add_rule(new Dragonstone.GtkUi.ViewRegistryRule.resource_view("text/gopher","hypertext"));
		}
	}

}
