public class Fossil.Startup.Cache.Backend {
	public static void setup_store(Fossil.SuperRegistry super_registry){
		print("[startup][cache] setup_store\n");
		super_registry.store("core.stores.cache",(new Fossil.Store.Cache()));
	}
	
	public static void setup_about_page(Fossil.SuperRegistry super_registry){
		print("[startup][cache] setup_about_page\n");
		var about = (super_registry.retrieve("core.stores.about") as Fossil.Store.About);
		if (about != null) {
			about.set_sub_store("cache",new Fossil.Store.AboutStore.FixedStatus("interactive/cache"));
		} else {
			print("[startup][cache] setup_about_page failed! No core.stores.about .\n");
		}
	}
	
}
