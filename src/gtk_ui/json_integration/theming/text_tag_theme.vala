public class Fossil.GtkUi.JsonIntegration.Theming.TextTagTheme {
	
	public static string gtk_wrap_mode_to_string(Gtk.WrapMode wrap_mode){
		switch (wrap_mode) {
			case NONE:
				return "none";
			case CHAR:
				return "char";
			case WORD:
				return "word";
			case WORD_CHAR:
				return "word_char";
			default:
				return "unknown";
		}
	}
	
	public static Gtk.WrapMode? gtk_wrap_mode_from_string(string wrap_mode){
		switch (wrap_mode) {
			case "none":
				return Gtk.WrapMode.NONE;
			case "char":
				return Gtk.WrapMode.CHAR;
			case "word":
				return Gtk.WrapMode.WORD;
			case "word_char":
				return Gtk.WrapMode.WORD_CHAR;
			default:
				return null;
		}
	}
	
	public static string pango_underline_to_string(Pango.Underline underline){
		switch(underline) {
			case NONE:
				return "none";
			case DOUBLE:
				return "double";
			case ERROR:
				return "error";
			case LOW:
				return "low";
			case SINGLE:
				return "single";
			default:
				return "unknown";
		}
	}
	
	public static Pango.Underline? pango_underline_from_string(string underline){
		switch (underline) {
			case "none":
				return Pango.Underline.NONE;
			case "double":
				return Pango.Underline.DOUBLE;
			case "double_line":
				return Pango.Underline.DOUBLE;
			case "error":
				return Pango.Underline.ERROR;
			case "error_line":
				return Pango.Underline.ERROR;
			case "low":
				return Pango.Underline.LOW;
			case "single":
				return Pango.Underline.SINGLE;
			case "single_line":
				return Pango.Underline.SINGLE;
			default:
				return null;
		}
	}
	
	public static Gdk.RGBA? gdk_rgba_from_string(string color){
		var rgba = Gdk.RGBA();
		if (rgba.parse(color)) {
			return rgba;
		} else {
			return null;
		}
	}
	
	public static Json.Object text_tag_theme_to_json(Fossil.GtkUi.Theming.TextTagTheme tag_theme){
		var object = new Json.Object();
		if (tag_theme.foreground_color != null) {
			object.set_string_member("foreground", tag_theme.foreground_color.to_string());
		}
		if (tag_theme.background_color != null) {
			object.set_string_member("background", tag_theme.background_color.to_string());
		}
		if (tag_theme.paragraph_background_color != null) {
			object.set_string_member("paragraph_background", tag_theme.paragraph_background_color.to_string());
		}
		if (tag_theme.underline_color != null) {
			object.set_string_member("underline_color", tag_theme.underline_color.to_string());
		}
		if (tag_theme.scale != null) {
			object.set_double_member("scale", tag_theme.scale);
		}
		if (tag_theme.indent != null) {
			object.set_int_member("indent", tag_theme.indent);
		}
		if (tag_theme.left_margin != null) {
			object.set_int_member("left_margin", tag_theme.left_margin);
		}
		if (tag_theme.right_margin != null) {
			object.set_int_member("right_margin", tag_theme.right_margin);
		}
		if (tag_theme.invisible != null) {
			object.set_boolean_member("invisible", tag_theme.invisible);
		}
		if (tag_theme.font_description != null) {
			object.set_string_member("font", tag_theme.font_description.to_string());
		}
		if (tag_theme.wrap_mode != null) {
			object.set_string_member("wrap_mode", gtk_wrap_mode_to_string(tag_theme.wrap_mode));
		}
		if (tag_theme.underline != null) {
			object.set_string_member("underline", pango_underline_to_string(tag_theme.underline));
		}
		return object;
	}
	
	public static Fossil.GtkUi.Theming.TextTagTheme text_tag_theme_from_json(Json.Object object){
		string member;
		var tag_theme = new Fossil.GtkUi.Theming.TextTagTheme();
		member = object.get_string_member("foreground");
		if (member != ""){
			tag_theme.foreground_color = gdk_rgba_from_string(member);
		}
		member = object.get_string_member("background");
		if (member != ""){
			tag_theme.background_color = gdk_rgba_from_string(member);
		}
		member = object.get_string_member("paragraph_background");
		if (member != ""){
			tag_theme.paragraph_background_color = gdk_rgba_from_string(member);
		}
		member = object.get_string_member("underline_color");
		if (member != ""){
			tag_theme.underline_color = gdk_rgba_from_string(member);
		}
		
		double scale = object.get_double_member("scale");
		if (scale > 1) {
			tag_theme.scale = scale;
		}
		int int_member = (int) object.get_int_member("indent");
		if (int_member > -1000) {
			tag_theme.indent = int_member;
		}
		int_member = (int) object.get_int_member("left_margin");
		if (int_member > -1000) {
			tag_theme.left_margin = int_member;
		}
		int_member = (int) object.get_int_member("right_margin");
		if (int_member > -1000) {
			tag_theme.right_margin = int_member;
		}
		tag_theme.invisible = object.get_boolean_member("invisible");
		member = object.get_string_member("font");
		if (member != ""){
			tag_theme.font_description = Pango.FontDescription.from_string(member);
		}
		member = object.get_string_member("wrap_mode");
		if (member != ""){
			tag_theme.wrap_mode = gtk_wrap_mode_from_string(member);
		}
		member = object.get_string_member("underline");
		if (member != ""){
			tag_theme.underline = pango_underline_from_string(member);
		}
		return tag_theme;
	}
	
}
