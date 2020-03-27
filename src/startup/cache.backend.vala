public class Dragonstone.Startup.Cache.Backend {
	public static void setup_store(Dragonstone.SuperRegistry super_registry){
		print("[startup][cache] setup_store\n");
		super_registry.store("core.stores.cache",(new Dragonstone.Store.Cache() as Dragonstone.Cache));
	}
}
