public class Dragonstone.Startup.File.Gtk {
	public static void setup_views(Dragonstone.SuperRegistry super_registry){
		var view_registry = (super_registry.retrieve("gtk.views") as Dragonstone.Registry.ViewRegistry);
		var translation = (super_registry.retrieve("localization.translation") as Dragonstone.Registry.TranslationRegistry);
		if (view_registry != null){
			view_registry.add_view("dragonstone.directory",() => { return new Dragonstone.View.Directory(translation); });
			view_registry.add_rule(new Dragonstone.Registry.ViewRegistryRule.resource_view("text/dragonstone-directory","dragonstone.directory"));
		}
	}
}
