public class Dragonstone.GtkUi.JsonIntegration.Theming.HypertextViewTheme {
	
	public static Json.Object hyper_text_view_theme_to_json(Dragonstone.GtkUi.Theming.HypertextViewTheme theme){
		var theme_object = new Json.Object();
		theme_object.set_boolean_member("monospaced", theme.is_monospaced_by_default());
		var prefix_object = new Json.Object();
		theme.foreach_prefix((name,prefix) => {
			prefix_object.set_string_member(name,prefix);
		});
		var tag_theme_object = new Json.Object();
		theme.foreach_text_tag_theme((name,tag_theme) => {
			prefix_object.set_object_member(name, Dragonstone.GtkUi.JsonIntegration.Theming.TextTagTheme.text_tag_theme_to_json(tag_theme));
		});
		theme_object.set_object_member("prefixes", prefix_object);
		theme_object.set_object_member("tag_themes", tag_theme_object);
		return theme_object;
	}
	
	public static Dragonstone.GtkUi.Theming.HypertextViewTheme hyper_text_view_theme_from_json(Json.Object theme_object){
		var theme = new Dragonstone.GtkUi.Theming.HypertextViewTheme();
		theme.monospaced_by_default = theme_object.get_boolean_member_with_default("monospaced", true);
		var prefix_node = theme_object.get_member("prefixes");
		if (prefix_node != null){
			if (prefix_node.get_node_type() == OBJECT){
				var prefix_object = prefix_node.get_object();
				prefix_object.foreach_member((_, name, node) => {
					if (node.get_node_type() == VALUE) {
						string? prefix = node.dup_string();
						if (prefix != null) {
							theme.set_prefix(name, prefix);
						}
					}
				});
			}
		}
		var tag_theme_node = theme_object.get_member("tag_themes");
		if (tag_theme_node != null){
			if (tag_theme_node.get_node_type() == OBJECT){
				var tag_theme_object = tag_theme_node.get_object();
				tag_theme_object.foreach_member((_, name, node) => {
					if (node.get_node_type() == OBJECT) {
						theme.set_text_tag_theme(name, Dragonstone.GtkUi.JsonIntegration.Theming.TextTagTheme.text_tag_theme_from_json(node.get_object()));
					}
				});
			}
		}
		return theme;
	}
	
}
