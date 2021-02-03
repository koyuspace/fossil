public class Dragonstone.Startup.Hypertext.Gtk {
	
	public static void setup_views(Dragonstone.SuperRegistry super_registry){
		print("[startup][hypertext][gtk] setup_views()\n");
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
		var view_registry = (super_registry.retrieve("gtk.views") as Dragonstone.GtkUi.ViewRegistry);
		if (view_registry != null){
			Dragonstone.GtkUi.Theming.HyperTextViewTheme? theme = null;
			try {
				Json.Parser parser = new Json.Parser();
				parser.load_from_data(temporary_style_json);
				var root_node = parser.get_root();
				if (root_node != null){
					if (root_node.get_node_type() == OBJECT) {
						var theme_object = root_node.get_object();
						theme = Dragonstone.GtkUi.JsonIntegration.Theming.HyperTextViewTheme.hyper_text_view_theme_from_json(theme_object);
					}
				}
			} catch (Error e) {
				print("[startup][hypertext][gtk] Error while parsing theme json: "+e.message+"\n");
			}
			if(theme == null){ //fall back to an empty theme
				theme = new Dragonstone.GtkUi.Theming.HyperTextViewTheme();
			}
			var theme_provider = new Dragonstone.GtkUi.Theming.DefaultHyperTextViewThemeProvider(theme);
			var gopher_type_registry = (super_registry.retrieve("gopher.types") as Dragonstone.Registry.GopherTypeRegistry);
			if (gopher_type_registry == null) {
				gopher_type_registry = new Dragonstone.Registry.GopherTypeRegistry.default_configuration();
			}
			var parser_factory = new Dragonstone.Document.DefaultTokenParserFactory(gopher_type_registry);
			view_registry.add_view("hypertext",() => {	
				return new Dragonstone.GtkUi.View.Hypertext(parser_factory, theme_provider);
			});
			view_registry.add_rule(new Dragonstone.GtkUi.ViewRegistryRule.resource_view("text/gemini","hypertext"));
			view_registry.add_rule(new Dragonstone.GtkUi.ViewRegistryRule.resource_view("text/gopher","hypertext"));
		}
	}

}
