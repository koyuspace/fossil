public class Dragonstone.Startup.Gopher.Backend {
	
	public static void setup_gophertypes(Dragonstone.SuperRegistry super_registry){
		var gopher_type_registry = (super_registry.retrieve("gopher.types") as Dragonstone.Registry.GopherTypeRegistry);
		if (gopher_type_registry == null){
			super_registry.store("gopher.types",new Dragonstone.Registry.GopherTypeRegistry.default_configuration());
		}
	}
	
	public static void setup_mimetypes(Dragonstone.SuperRegistry super_registry){
		var mimeguesser = (super_registry.retrieve("core.mimeguesser") as Dragonstone.Registry.MimetypeGuesser);
		if (mimeguesser != null){
			mimeguesser.add_type(".gopher","text/gopher");
			mimeguesser.add_type(".gph","text/gopher");
		}
	}
	
	public static void setup_store(Dragonstone.SuperRegistry super_registry){
		var store_registry = (super_registry.retrieve("core.stores") as Dragonstone.Registry.StoreRegistry);
		if (store_registry != null){
			var mimeguesser = (super_registry.retrieve("core.mimeguesser") as Dragonstone.Registry.MimetypeGuesser);
			var gopher_type_registry = (super_registry.retrieve("gopher.types") as Dragonstone.Registry.GopherTypeRegistry);
			Dragonstone.Store.Gopher store; 
			if (mimeguesser == null){
				store = new Dragonstone.Store.Gopher();
			} else {
				store = new Dragonstone.Store.Gopher.with_mimeguesser(mimeguesser,gopher_type_registry);
			}
			store_registry.add_resource_store("gopher://",store);
		}
	}
	
	public static void setup_uri_autocompletion(Dragonstone.SuperRegistry super_registry){
		var uri_autoprefixer = (super_registry.retrieve("core.uri_autoprefixer") as Dragonstone.Registry.UriAutoprefix);
		if (uri_autoprefixer != null){
			uri_autoprefixer.add("gopher.","gopher://gopher.");
			uri_autoprefixer.add("gopher:","gopher://");
			uri_autoprefixer.add("gopher://","gopher://");
		}
	}
}
