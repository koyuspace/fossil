public class Dragonstone.Startup.Hypertext.Settings {
	
		
	public static void register_default_settings(Dragonstone.Interface.Settings.Provider settings_provider){
		string default_style_json = """
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
		settings_provider.write_object("themes.default.json", default_style_json);
	}
}
