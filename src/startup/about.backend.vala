public class Fossil.Startup.About.Backend {
	public static void setup_store(Fossil.SuperRegistry super_registry){
		print("[startup][about] setup_store\n");
		var store = new Fossil.Store.About();
		super_registry.store("core.stores.about",store);
		var store_registry = (super_registry.retrieve("core.stores") as Fossil.Registry.StoreRegistry);
		if (store_registry != null){
			store_registry.add_resource_store("about:",store);
		}
	}
}
