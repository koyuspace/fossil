public interface Dragonstone.GtkUi.Interface.Theming.HypertextViewThemeProvider : Object {
	
	public abstract Dragonstone.GtkUi.Interface.Theming.HypertextViewTheme? get_theme(string content_type, string uri);
	public abstract Dragonstone.GtkUi.Interface.Theming.HypertextViewTheme get_default_theme();
	
}
