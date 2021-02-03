public interface Dragonstone.GtkUi.Interface.Theming.HyperTextViewTheme : Object {
	
	public abstract string? get_prefix(string name);
	public abstract Dragonstone.GtkUi.Theming.TextTagTheme? get_text_tag_theme(string name);
	
	public abstract string get_best_matching_text_tag_theme_name(string[] classes);
	
	public abstract bool is_monospaced_by_default();
	
	public signal void theme_updated();
	
}
