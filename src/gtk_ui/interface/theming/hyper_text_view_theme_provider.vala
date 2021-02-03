public interface Dragonstone.GtkUi.Interface.Theming.HyperTextViewThemeProvider : Object {
	
	public abstract Dragonstone.GtkUi.Interface.Theming.HyperTextViewTheme? get_theme(string content_type, string uri);
	public abstract Dragonstone.GtkUi.Interface.Theming.HyperTextViewTheme get_default_theme();
	
}
