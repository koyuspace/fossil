public class Fossil.Startup.Bookmarks.Gtk {
	public static void setup_views(Fossil.SuperRegistry super_registry){
		var view_registry = (super_registry.retrieve("gtk.views") as Fossil.GtkUi.LegacyViewRegistry);
		var translation = (super_registry.retrieve("localization.translation") as Fossil.Registry.TranslationRegistry);
		var bookmark_registry = (super_registry.retrieve("core.bookmarks") as Fossil.Registry.BookmarkRegistry);
		if (view_registry != null && bookmark_registry != null){
			print("[startup][bookmarks] setup_views\n");
			view_registry.add_view("fossil.bookmarks",() => {
				return new Fossil.GtkUi.View.Bookmarks(bookmark_registry,translation);
			});
			view_registry.add_rule(new Fossil.GtkUi.LegacyViewRegistryRule("interactive/bookmarks","fossil.bookmarks"));
		}
	}
	
}
