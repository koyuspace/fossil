public class Dragonstone.Startup.Utiltest.Backend {
	public static void setup_about_page(Dragonstone.SuperRegistry super_registry){
		print("[startup][utiltest] setup_about_page()\n");
		var about = (super_registry.retrieve("core.stores.about") as Dragonstone.Store.About);
		if (about != null) {
			about.set_sub_store("ruri",new Dragonstone.Store.AboutStore.FixedStatus("interactive/uri_merge_test"));
		} else {
			print("[startup][utiltest] setup_about_page failed! No core.stores.about .\n");
		}
	}
}
