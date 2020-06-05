public class Dragonstone.Startup.Cache.Gtk {
	public static void setup_views(Dragonstone.SuperRegistry super_registry){
		var view_registry = (super_registry.retrieve("gtk.views") as Dragonstone.Registry.ViewRegistry);
		var translation = (super_registry.retrieve("localization.translation") as Dragonstone.Registry.TranslationRegistry);
		if (view_registry != null){
			print("[startup][cache] setup_views\n");
			view_registry.add_view("dragonstone.cacheview",() => {
				return new Dragonstone.View.Cache(translation);
			});
			view_registry.add_rule(new Dragonstone.Registry.ViewRegistryRule("interactive/cache","dragonstone.cacheview"));
		}
	}
	
}
