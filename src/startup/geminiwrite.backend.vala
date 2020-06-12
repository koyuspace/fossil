public class Dragonstone.Startup.GeminiWrite.Backend {
	
	public static void setup_store(Dragonstone.SuperRegistry super_registry){
		var store_registry = (super_registry.retrieve("core.stores") as Dragonstone.Registry.StoreRegistry);
		if (store_registry != null){
			var store = new Dragonstone.Store.GeminiWrite();
			store_registry.add_resource_store("gemini+write://",store);
		}
	}
}
