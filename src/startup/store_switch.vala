public class Fossil.Startup.StoreSwitch {

	public static void setup_store(Fossil.SuperRegistry super_registry){
		var store_registry = (super_registry.retrieve("core.stores") as Fossil.Registry.StoreRegistry);
		var cache = (super_registry.retrieve("core.stores.cache") as Fossil.Interface.Cache);
		if (store_registry != null){
			string cachedir = GLib.Environment.get_user_cache_dir();
			super_registry.store("core.stores.main",new Fossil.Store.Switch(cachedir+"/fossil",store_registry,cache));
		}
	}
	
}
