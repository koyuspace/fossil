public class Dragonstone.Startup.Gopher.Gtk {
	public static void setup_views(Dragonstone.SuperRegistry super_registry){
		var view_registry = (super_registry.retrieve("gtk.views") as Dragonstone.Registry.ViewRegistry);
		if (view_registry != null){
			var cache = (super_registry.retrieve("core.stores.cache") as Dragonstone.Cache);
			view_registry.add_resource_view("text/gopher",() => {
				var view = new Dragonstone.View.Gophertext();
				view.set_cache(cache);
				return view;
			});
		}
	}
}
