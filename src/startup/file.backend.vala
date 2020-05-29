public class Dragonstone.Startup.File.Backend {
	
	public static void setup_store(Dragonstone.SuperRegistry super_registry){
		var store_registry = (super_registry.retrieve("core.stores") as Dragonstone.Registry.StoreRegistry);
		var mimeguesser = (super_registry.retrieve("core.mimeguesser") as Dragonstone.Registry.MimetypeGuesser);
		if (store_registry != null){
			store_registry.add_resource_store("file://",new Dragonstone.Store.File.with_mimeguesser(mimeguesser));
		}
	}
	
	public static void setup_uri_autocompletion(Dragonstone.SuperRegistry super_registry){
		var uri_autoprefixer = (super_registry.retrieve("core.uri_autoprefixer") as Dragonstone.Registry.UriAutoprefix);
		if (uri_autoprefixer != null){
			uri_autoprefixer.add("file:","file://");
			uri_autoprefixer.add("file://","file://");
			uri_autoprefixer.add("/","file:///");
			uri_autoprefixer.add("~/","file://"+GLib.Environment.get_home_dir()+"/");
		}
	}
	
}
