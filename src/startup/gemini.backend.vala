public class Fossil.Startup.Gemini.Backend {
	
	public static void setup_mimetypes(Fossil.SuperRegistry super_registry){
		var mimeguesser = (super_registry.retrieve("core.mimeguesser") as Fossil.Registry.MimetypeGuesser);
		if (mimeguesser != null){
			mimeguesser.add_type(".gmi","text/gemini");
			mimeguesser.add_type(".gemini","text/gemini");
		}
	}
	
	public static void setup_store(Fossil.SuperRegistry super_registry){
		var store_registry = (super_registry.retrieve("core.stores") as Fossil.Registry.StoreRegistry);
		print("[startup][gemini][backend] setup_store()\n");
		if (store_registry != null){
			print("[startup][gemini][backend] adding gemini store\n");
			var store = new Fossil.Store.Gemini();
			store_registry.add_resource_store("gemini://",store);
		}
	}
	
	public static void setup_uri_autocompletion(Fossil.SuperRegistry super_registry){
		var uri_autoprefixer = (super_registry.retrieve("core.uri_autoprefixer") as Fossil.Registry.UriAutoprefix);
		if (uri_autoprefixer != null){
			uri_autoprefixer.add("gemini.","gemini://gemini.");
			uri_autoprefixer.add("gemini:","gemini://");
			uri_autoprefixer.add("gemini://","gemini://");
		}
	}
}
