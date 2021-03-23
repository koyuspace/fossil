public class Fossil.Startup.Cache.Gtk {
	public static void setup_views(Fossil.SuperRegistry super_registry){
		var view_registry = (super_registry.retrieve("gtk.views") as Fossil.GtkUi.LegacyViewRegistry);
		var translation = (super_registry.retrieve("localization.translation") as Fossil.Registry.TranslationRegistry);
		if (view_registry != null){
			print("[startup][cache] setup_views\n");
			view_registry.add_view("fossil.cacheview",() => {
				return new Fossil.GtkUi.View.Cache(translation);
			});
			view_registry.add_rule(new Fossil.GtkUi.LegacyViewRegistryRule("interactive/cache","fossil.cacheview"));
		}
	}
	
}
