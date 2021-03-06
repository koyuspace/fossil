public class Fossil.GtkUi.JsonIntegration.Theming.HypertextThemeRule {
	
	public static Json.Object rule_to_json(Fossil.GtkUi.Theming.HypertextThemeRule rule){
		var object = new Json.Object();
		object.set_string_member("theme", rule.theme_name);
		if (rule.content_type != null) {
			object.set_string_member("content_type", rule.content_type);
		}
		if (rule.scheme != null) {
			object.set_string_member("scheme", rule.scheme);
		}
		if (rule.host != null) {
			object.set_string_member("host", rule.host);
		}
		if (rule.port != null) {
			object.set_string_member("port", rule.port);
		}
		if (rule.path_prefix != null) {
			object.set_string_member("path_prefix", rule.path_prefix);
		}
		if (rule.path_suffix != null) {
			object.set_string_member("path_suffix", rule.path_suffix);
		}
		return object;
	}
	
	public static Fossil.GtkUi.Theming.HypertextThemeRule? rule_from_json(Json.Object object){
		string member;
		Fossil.GtkUi.Theming.HypertextThemeRule rule;
		member = object.get_string_member("theme");
		if (member != ""){
			rule = new Fossil.GtkUi.Theming.HypertextThemeRule(member);
		} else {
			return null;
		}
		member = object.get_string_member("content_type");
		if (member != ""){
			rule.content_type = member;
		}
		member = object.get_string_member("scheme");
		if (member != ""){
			rule.scheme = member;
		}
		member = object.get_string_member("host");
		if (member != ""){
			rule.host = member;
		}
		member = object.get_string_member("port");
		if (member != ""){
			rule.port = member;
		}
		member = object.get_string_member("path_prefix");
		if (member != ""){
			rule.path_prefix = member;
		}
		member = object.get_string_member("path_suffix");
		if (member != ""){
			rule.path_suffix = member;
		}
		return rule;
	}
	
}
