public class Fossil.Startup.File.Gtk {
	public static void setup_views(Fossil.SuperRegistry super_registry){
		var view_registry = (super_registry.retrieve("gtk.views") as Fossil.GtkUi.LegacyViewRegistry);
		var translation = (super_registry.retrieve("localization.translation") as Fossil.Registry.TranslationRegistry);
		if (view_registry != null){
			view_registry.add_view("fossil.directory",() => { return new Fossil.GtkUi.View.Directory(translation); });
			view_registry.add_rule(new Fossil.GtkUi.LegacyViewRegistryRule.resource_view("text/fossil-directory","fossil.directory"));
		}
	}
}
