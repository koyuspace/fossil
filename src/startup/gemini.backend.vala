public class Dragonstone.Startup.Gemini.Backend {
	
	public static void setup_mimetypes(Dragonstone.SuperRegistry super_registry){
		var mimeguesser = (super_registry.retrieve("core.mimeguesser") as Dragonstone.Registry.MimetypeGuesser);
		if (mimeguesser != null){
			mimeguesser.add_type(".gmi","text/gemini");
			mimeguesser.add_type(".gemini","text/gemini");
		}
	}
	
	public static void setup_store(Dragonstone.SuperRegistry super_registry){
		var store_registry = (super_registry.retrieve("core.stores") as Dragonstone.Registry.StoreRegistry);
		var cache = (super_registry.retrieve("core.stores.cache") as Dragonstone.Cache);
		print("[startup][gemini][backend] setup_store()\n");
		if (store_registry != null){
			print("[startup][gemini][backend] adding gemini store\n");
			var store = new Dragonstone.Store.Gemini();
			store.set_cache(cache);
			store_registry.add_resource_store("gemini://",store);
		}
	}
	
	public static void setup_uri_autocompletion(Dragonstone.SuperRegistry super_registry){
		var uri_autoprefixer = (super_registry.retrieve("core.uri_autoprefixer") as Dragonstone.Registry.UriAutoprefix);
		if (uri_autoprefixer != null){
			uri_autoprefixer.add("gemini.","gemini://gemini.");
			uri_autoprefixer.add("gemini:","gemini://");
			uri_autoprefixer.add("gemini://","gemini://");
		}
	}
}
