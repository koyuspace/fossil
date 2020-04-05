public class Dragonstone.Startup.Cache.Gtk {
	public static void setup_views(Dragonstone.SuperRegistry super_registry){
		var view_registry = (super_registry.retrieve("gtk.views") as Dragonstone.Registry.ViewRegistry);
		var cache = (super_registry.retrieve("core.stores.cache") as Dragonstone.Store.Cache);
		var translation = (super_registry.retrieve("localization.translation") as Dragonstone.Registry.TranslationRegistry);
		if ((view_registry != null) && (cache != null)){
			print("[startup][cache] setup_views");
			view_registry.add_view("interactive/cache",() => {
				return new Dragonstone.View.Cache(cache,translation);
			});
		}
	}
	
}
