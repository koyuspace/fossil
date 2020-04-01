public class Dragonstone.Startup.Finger.Backend {
	
	public static void setup_store(Dragonstone.SuperRegistry super_registry){
		var store_registry = (super_registry.retrieve("core.stores") as Dragonstone.Registry.StoreRegistry);
		var cache = (super_registry.retrieve("core.stores.cache") as Dragonstone.Cache);
		print("[startup][finger][backend] setup_store()\n");
		if (store_registry != null){
			print("[startup][finger][backend] adding finger store\n");
			var store = new Dragonstone.Store.Finger();
			store.set_cache(cache);
			store_registry.add_resource_store("finger://",store);
		}
	}
	
	public static void setup_uri_autocompletion(Dragonstone.SuperRegistry super_registry){
		var uri_autoprefixer = (super_registry.retrieve("core.uri_autoprefixer") as Dragonstone.Registry.UriAutoprefix);
		if (uri_autoprefixer != null){
			uri_autoprefixer.add("finger:","finger://");
			uri_autoprefixer.add("finger://","finger://");
		}
	}
	
}
