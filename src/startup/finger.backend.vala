public class Fossil.Startup.Finger.Backend {
	
	public static void setup_store(Fossil.SuperRegistry super_registry){
		var store_registry = (super_registry.retrieve("core.stores") as Fossil.Registry.StoreRegistry);
		print("[startup][finger][backend] setup_store()\n");
		if (store_registry != null){
			print("[startup][finger][backend] adding finger store\n");
			var store = new Fossil.Store.Finger();
			store_registry.add_resource_store("finger://",store);
		}
	}
	
	public static void setup_uri_autocompletion(Fossil.SuperRegistry super_registry){
		var uri_autoprefixer = (super_registry.retrieve("core.uri_autoprefixer") as Fossil.Registry.UriAutoprefix);
		if (uri_autoprefixer != null){
			uri_autoprefixer.add("finger:","finger://");
			uri_autoprefixer.add("finger://","finger://");
		}
	}
	
}
