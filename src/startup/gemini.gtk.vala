public class Dragonstone.Startup.Gemini.Gtk {
	public static void setup_views(Dragonstone.SuperRegistry super_registry){
		var view_registry = (super_registry.retrieve("gtk.views") as Dragonstone.GtkUi.LegacyViewRegistry);
		if (view_registry != null){
			view_registry.add_view("gemini.input",() => { return new Dragonstone.GtkUi.View.GeminiInput(); });
			view_registry.add_rule(new Dragonstone.GtkUi.LegacyViewRegistryRule.resource_view("gemini/input","gemini.input"));
		}
	}
}
