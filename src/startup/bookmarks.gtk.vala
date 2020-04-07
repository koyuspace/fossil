public class Dragonstone.Startup.Bookmarks.Gtk {
	public static void setup_views(Dragonstone.SuperRegistry super_registry){
		var view_registry = (super_registry.retrieve("gtk.views") as Dragonstone.Registry.ViewRegistry);
		var folder_registry = (super_registry.retrieve("core.bookmarks") as Dragonstone.Registry.Bookmark.FolderRegistry);
		var translation = (super_registry.retrieve("localization.translation") as Dragonstone.Registry.TranslationRegistry);
		if ((view_registry != null) && (folder_registry != null)){
			print("[startup][bookmarks] setup_views");
			view_registry.add_view("interactive/bookmark_folders",() => {
				return new Dragonstone.View.BookmarkFolders(folder_registry);
			});
			view_registry.add_view("interactive/bookmarks",() => {
				return new Dragonstone.View.Bookmarks(folder_registry);
			});
		}
	}
	
}
