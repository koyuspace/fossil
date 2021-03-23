public class Fossil.Startup.Utilfossil.Backend {
	public static void setup_about_page(Fossil.SuperRegistry super_registry){
		print("[startup][utilfossil] setup_about_page()\n");
		var about = (super_registry.retrieve("core.stores.about") as Fossil.Store.About);
		if (about != null) {
			about.set_sub_store("ruri",new Fossil.Store.AboutStore.FixedStatus("interactive/uri_merge_fossil"));
		} else {
			print("[startup][utilfossil] setup_about_page failed! No core.stores.about .\n");
		}
	}
}
