public class Dragonstone.Startup.Gemini.Gtk {
	public static void setup_views(Dragonstone.SuperRegistry super_registry){
		var view_registry = (super_registry.retrieve("gtk.views") as Dragonstone.Registry.ViewRegistry);
		if (view_registry != null){
			view_registry.add_resource_view("text/gemini",() => { return new Dragonstone.View.Geminitext(); });
			view_registry.add_resource_view("gemini/input",() => { return new Dragonstone.View.GeminiInput(); });
		}
	}
}
