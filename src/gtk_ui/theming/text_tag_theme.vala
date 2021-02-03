public class Dragonstone.GtkUi.Theming.TextTagTheme : Object {
	
	public Gdk.RGBA? foreground_color = null;
	public Gdk.RGBA? background_color = null;
	public Gdk.RGBA? paragraph_background_color = null;
	public Gdk.RGBA? underline_color = null;
	
	public double? scale = null;
	public Pango.FontDescription? font_description = null;
	public Gtk.WrapMode? wrap_mode = null;
	public Pango.Underline? underline = null;
	
	public void apply_theme(Gtk.TextTag text_tag){
		if (foreground_color != null) { text_tag.foreground_rgba = foreground_color; }
		if (background_color != null) { text_tag.background_rgba = background_color; }
		if (paragraph_background_color != null) { text_tag.paragraph_background_rgba = paragraph_background_color; }
		if (underline_color != null) { text_tag.underline_rgba = underline_color; }
		
		if (scale != null) { text_tag.scale = scale; }
		if (font_description != null) { text_tag.font_desc = font_description; }
		if (wrap_mode != null) { text_tag.wrap_mode = wrap_mode; }
		if (underline != null) { text_tag.underline = underline; }
	}
	
	public static void untheme(Gtk.TextTag text_tag){
		text_tag.foreground_set = false;
		text_tag.background_set = false;
		text_tag.paragraph_background_set = false;
		text_tag.underline_set = false;
		text_tag.scale_set = false;
		text_tag.wrap_mode_set = false;
		
		text_tag.family_set = false;
		text_tag.font_features_set = false;
		text_tag.style_set = false;
		text_tag.variant_set = false;
		text_tag.weight_set = false;
		text_tag.size_set = false;
		text_tag.stretch_set = false;
	}
	
}
