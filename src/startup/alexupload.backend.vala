public class Dragonstone.Startup.AlexUpload.Backend {
	
	public static void setup_gophertypes(Dragonstone.SuperRegistry super_registry){
		var gopher_type_registry = (super_registry.retrieve("gopher.types") as Dragonstone.Registry.GopherTypeRegistry);
		if (gopher_type_registry == null){
			gopher_type_registry = new Dragonstone.Registry.GopherTypeRegistry.default_configuration();
			super_registry.store("gopher.types",gopher_type_registry);
		}
		gopher_type_registry.add(new Dragonstone.Registry.GopherTypeRegistryEntry('w',null,"gopher+alexuploadt://{host}:{port}/{selector}"));
	}
	
	public static void setup_store(Dragonstone.SuperRegistry super_registry){
		var store_registry = (super_registry.retrieve("core.stores") as Dragonstone.Registry.StoreRegistry);
		if (store_registry != null){
			var store = new Dragonstone.Store.AlexUploadGopher();
			store_registry.add_resource_store("gopher+alexuploadt://",store);
			store_registry.add_resource_store("gopher+alexuploadf://",store);
		}
	}
}
