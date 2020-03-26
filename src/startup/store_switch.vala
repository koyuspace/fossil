public class Dragonstone.Startup.StoreSwitch {

	public static void setup_store(Dragonstone.SuperRegistry super_registry){
		var store_registry = (super_registry.retrieve("core.stores") as Dragonstone.Registry.StoreRegistry);
		if (store_registry != null){
			string cachedir = GLib.Environment.get_user_cache_dir();
			super_registry.store("core.stores.main",new Dragonstone.Store.Switch(cachedir+"/dragonstone",store_registry));
		}
	}
	
}
