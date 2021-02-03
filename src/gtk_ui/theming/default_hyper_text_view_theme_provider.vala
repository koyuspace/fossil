public class Dragonstone.GtkUi.Theming.DefaultHyperTextViewThemeProvider : Dragonstone.GtkUi.Interface.Theming.HyperTextViewThemeProvider, Object {
	
	Dragonstone.GtkUi.Interface.Theming.HyperTextViewTheme default_theme;
	
	public DefaultHyperTextViewThemeProvider(Dragonstone.GtkUi.Interface.Theming.HyperTextViewTheme default_theme){
		this.default_theme = default_theme;
	}
	  ////////////////////////////////////////////////////////////////////
	 // Dragonstone.GtkUi.Interface.Theming.HyperTextViewThemeProvider //
	////////////////////////////////////////////////////////////////////
	
	public Dragonstone.GtkUi.Interface.Theming.HyperTextViewTheme? get_theme(string content_type, string uri){
		return null;
	}
	
	public Dragonstone.GtkUi.Interface.Theming.HyperTextViewTheme get_default_theme(){
		return default_theme;
	}
	
}
