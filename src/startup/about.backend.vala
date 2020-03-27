public class Dragonstone.Startup.About.Backend {
	public static void setup_store(Dragonstone.SuperRegistry super_registry){
		print("[startup][about] setup_store\n");
		var store = new Dragonstone.Store.About();
		super_registry.store("core.stores.about",store);
		var store_registry = (super_registry.retrieve("core.stores") as Dragonstone.Registry.StoreRegistry);
		if (store_registry != null){
			store_registry.add_resource_store("about:",store);
		}
	}
}
