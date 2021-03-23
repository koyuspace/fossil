public interface Fossil.GtkUi.Interface.Theming.HypertextViewThemeProvider : Object {
	
	public abstract Fossil.GtkUi.Interface.Theming.HypertextViewTheme? get_theme(string content_type, string uri);
	public abstract Fossil.GtkUi.Interface.Theming.HypertextViewTheme get_default_theme();
	
}
