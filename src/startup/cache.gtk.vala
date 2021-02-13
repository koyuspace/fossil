public class Dragonstone.Startup.Cache.Gtk {
	public static void setup_views(Dragonstone.SuperRegistry super_registry){
		var view_registry = (super_registry.retrieve("gtk.views") as Dragonstone.GtkUi.LegacyViewRegistry);
		var translation = (super_registry.retrieve("localization.translation") as Dragonstone.Registry.TranslationRegistry);
		if (view_registry != null){
			print("[startup][cache] setup_views\n");
			view_registry.add_view("dragonstone.cacheview",() => {
				return new Dragonstone.GtkUi.View.Cache(translation);
			});
			view_registry.add_rule(new Dragonstone.GtkUi.LegacyViewRegistryRule("interactive/cache","dragonstone.cacheview"));
		}
	}
	
}
