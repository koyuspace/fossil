public class Dragonstone.Startup.Gemini.Gtk {
	public static void setup_views(Dragonstone.SuperRegistry super_registry){
		var view_registry = (super_registry.retrieve("gtk.views") as Dragonstone.Registry.ViewRegistry);
		if (view_registry != null){
			view_registry.add_view("gemini.map",() => { return new Dragonstone.View.Geminitext(); });
			view_registry.add_view("gemini.input",() => { return new Dragonstone.View.GeminiInput(); });
			view_registry.add_rule(new Dragonstone.Registry.ViewRegistryRule.resource_view("text/gemini","gemini.map"));
			view_registry.add_rule(new Dragonstone.Registry.ViewRegistryRule.resource_view("gemini/input","gemini.input"));
		}
	}
}
