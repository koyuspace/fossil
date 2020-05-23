public class Dragonstone.Startup.Bookmarks.Backend {
	public static void setup_about_page(Dragonstone.SuperRegistry super_registry){
		print("[startup][bookmarks] setup_about_page\n");
		var about = (super_registry.retrieve("core.stores.about") as Dragonstone.Store.About);
		if (about != null) {
			about.set_sub_store("bookmarks",new Dragonstone.Store.AboutStore.FixedStatus("interactive/bookmarks"));
		} else {
			print("[startup][bookmarks] setup_about_page failed! No core.stores.about .\n");
		}
	}
}
