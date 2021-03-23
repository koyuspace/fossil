public class Fossil.Startup.Gopher.Backend {
	
	public static void setup_gophertypes(Fossil.SuperRegistry super_registry){
		var gopher_type_registry = (super_registry.retrieve("gopher.types") as Fossil.Registry.GopherTypeRegistry);
		if (gopher_type_registry == null){
			super_registry.store("gopher.types",new Fossil.Registry.GopherTypeRegistry.default_configuration());
		}
	}
	
	public static void setup_mimetypes(Fossil.SuperRegistry super_registry){
		var mimeguesser = (super_registry.retrieve("core.mimeguesser") as Fossil.Registry.MimetypeGuesser);
		if (mimeguesser != null){
			mimeguesser.add_type(".gopher","text/gopher");
			mimeguesser.add_type(".gph","text/gopher");
		}
	}
	
	public static void setup_store(Fossil.SuperRegistry super_registry){
		var store_registry = (super_registry.retrieve("core.stores") as Fossil.Registry.StoreRegistry);
		if (store_registry != null){
			var mimeguesser = (super_registry.retrieve("core.mimeguesser") as Fossil.Registry.MimetypeGuesser);
			var gopher_type_registry = (super_registry.retrieve("gopher.types") as Fossil.Registry.GopherTypeRegistry);
			Fossil.Store.Gopher store; 
			if (mimeguesser == null){
				store = new Fossil.Store.Gopher();
			} else {
				store = new Fossil.Store.Gopher.with_mimeguesser(mimeguesser,gopher_type_registry);
			}
			store_registry.add_resource_store("gopher://",store);
		}
	}
	
	public static void setup_uri_autocompletion(Fossil.SuperRegistry super_registry){
		var uri_autoprefixer = (super_registry.retrieve("core.uri_autoprefixer") as Fossil.Registry.UriAutoprefix);
		if (uri_autoprefixer != null){
			uri_autoprefixer.add("gopher.","gopher://gopher.");
			uri_autoprefixer.add("gopher:","gopher://");
			uri_autoprefixer.add("gopher://","gopher://");
		}
	}
}
