public class Fossil.Startup.GeminiUpload.Backend {
	
	public static void setup_store(Fossil.SuperRegistry super_registry){
		var store_registry = (super_registry.retrieve("core.stores") as Fossil.Registry.StoreRegistry);
		if (store_registry != null){
			var store = new Fossil.Store.GeminiUpload();
			store_registry.add_resource_store("gemini+upload://",store);
		}
	}
}
