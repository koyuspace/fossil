public class Fossil.Startup.GeminiWrite.Backend {
	
	public static void setup_store(Fossil.SuperRegistry super_registry){
		var store_registry = (super_registry.retrieve("core.stores") as Fossil.Registry.StoreRegistry);
		if (store_registry != null){
			var store = new Fossil.Store.GeminiWrite();
			store_registry.add_resource_store("gemini+write://",store);
		}
	}
}
