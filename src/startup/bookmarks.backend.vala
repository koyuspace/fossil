public class Dragonstone.Startup.Bookmarks.Backend {

	public static void setup_registry(Dragonstone.SuperRegistry super_registry){
		super_registry.store("core.bookmarks",new Dragonstone.Registry.Bookmark.FolderRegistry());
	}
	
	public static void setup_default_folders(Dragonstone.SuperRegistry super_registry){
		var folder_registry = (super_registry.retrieve("core.bookmarks") as Dragonstone.Registry.Bookmark.FolderRegistry);
		if (folder_registry != null){
			var default_folder = new Dragonstone.Registry.Bookmark.Folder("Main Bookmarks","Your bookmarks go here, feel free to change the name or the description.\n(WARNING: Bookmarks are currently not persistent)","config:defualt");
			folder_registry.add_folder(default_folder);
			var temp_folder = new Dragonstone.Registry.Bookmark.Folder("Temporary","Use this folder for temporary bookmarks, that will last until you close all dragonstone windows.");
			folder_registry.add_folder(temp_folder);
			var cache_entry = new Dragonstone.Registry.Bookmark.Entry("Cache","about:cache");
			cache_entry.add_tag("/menu/");
			var home_entry = new Dragonstone.Registry.Bookmark.Entry("Home","test://");
			home_entry.add_tag("/menu/");
			home_entry.add_tag("/homepage/");
			var test1_entry = new Dragonstone.Registry.Bookmark.Entry("Khzae","gopher://khzae.net");
			test1_entry.add_tag("/home/");
			test1_entry.add_tag("imageboard");
			var test2_entry = new Dragonstone.Registry.Bookmark.Entry("Floodgap","gopher://floodgap.com");
			test2_entry.add_tag("/home/");
			test2_entry.add_tag("search");
			default_folder.add_bookmark(cache_entry);
			default_folder.add_bookmark(home_entry);
			default_folder.add_bookmark(test1_entry);
			default_folder.add_bookmark(test2_entry);
		}
	}
	
	public static void setup_about_page(Dragonstone.SuperRegistry super_registry){
		print("[startup][bookmarks] setup_about_page\n");
		var about = (super_registry.retrieve("core.stores.about") as Dragonstone.Store.About);
		if (about != null) {
			about.set_sub_store("bookmarks",new Dragonstone.Store.AboutStore.FixedStatus("interactive/bookmark_folders"));
		} else {
			print("[startup][bookmarks] setup_about_page failed! No core.stores.about\n");
		}
	}
	
	public static void setup_store(Dragonstone.SuperRegistry super_registry){
		print("[startup][bookmarks] setup_store\n");
		var store_registry = (super_registry.retrieve("core.stores") as Dragonstone.Registry.StoreRegistry);
		if (store_registry != null){
			var store = new Dragonstone.Store.Bookmarks();
			store_registry.add_resource_store("about:bookmarks/",store);
		} else {
			print("[startup][bookmarks] setup_store failed! No core.stores\n");
		}
	}
	
	
	
}
