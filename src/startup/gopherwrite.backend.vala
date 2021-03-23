public class Fossil.Startup.GopherWrite.Backend {
	
	public static void setup_gophertypes(Fossil.SuperRegistry super_registry){
		var gopher_type_registry = (super_registry.retrieve("gopher.types") as Fossil.Registry.GopherTypeRegistry);
		if (gopher_type_registry == null){
			gopher_type_registry = new Fossil.Registry.GopherTypeRegistry.default_configuration();
			super_registry.store("gopher.types",gopher_type_registry);
		}
		gopher_type_registry.add(new Fossil.Registry.GopherTypeRegistryEntry('w',null,"gopher+writet://{host}:{port}/{selector}"));
	}
	
	public static void setup_store(Fossil.SuperRegistry super_registry){
		var store_registry = (super_registry.retrieve("core.stores") as Fossil.Registry.StoreRegistry);
		if (store_registry != null){
			var store = new Fossil.Store.GopherWrite();
			store_registry.add_resource_store("gopher+writet://",store);
			store_registry.add_resource_store("gopher+writef://",store);
		}
	}
}
