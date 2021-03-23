public class Fossil.Startup.Gemini.Gtk {
	public static void setup_views(Fossil.SuperRegistry super_registry){
		var view_registry = (super_registry.retrieve("gtk.views") as Fossil.GtkUi.LegacyViewRegistry);
		if (view_registry != null){
			view_registry.add_view("gemini.input",() => { return new Fossil.GtkUi.View.GeminiInput(); });
			view_registry.add_rule(new Fossil.GtkUi.LegacyViewRegistryRule.resource_view("gemini/input","gemini.input"));
		}
	}
}
