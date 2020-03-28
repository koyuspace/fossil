public class Dragonstone.Startup.Cache.Backend {
	public static void setup_store(Dragonstone.SuperRegistry super_registry){
		print("[startup][cache] setup_store\n");
		super_registry.store("core.stores.cache",(new Dragonstone.Store.Cache()));
	}
	
	public static void setup_about_page(Dragonstone.SuperRegistry super_registry){
		print("[startup][cache] setup_about_page\n");
		var about = (super_registry.retrieve("core.stores.about") as Dragonstone.Store.About);
		if (about != null) {
			about.set_sub_store("cache",new Dragonstone.Store.AboutStore.FixedStatus("interactive/cache"));
		} else {
			print("[startup][cache] setup_about_page failed! No core.stores.about .\n");
		}
	}
	
}
