public class Dragonstone.Startup.Bookmarks.Gtk {
	public static void setup_views(Dragonstone.SuperRegistry super_registry){
		var view_registry = (super_registry.retrieve("gtk.views") as Dragonstone.Registry.ViewRegistry);
		var translation = (super_registry.retrieve("localization.translation") as Dragonstone.Registry.TranslationRegistry);
		var bookmark_registry = (super_registry.retrieve("core.bookmarks") as Dragonstone.Registry.BookmarkRegistry);
		if (view_registry != null && bookmark_registry != null){
			print("[startup][bookmarks] setup_views\n");
			view_registry.add_view("dragonstone.bookmarks",() => {
				return new Dragonstone.View.Bookmarks(bookmark_registry,translation);
			});
			view_registry.add_rule(new Dragonstone.Registry.ViewRegistryRule("interactive/bookmarks","dragonstone.bookmarks"));
		}
	}
	
}
