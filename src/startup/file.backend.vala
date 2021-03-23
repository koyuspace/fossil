public class Fossil.Startup.File.Backend {
	
	public static void setup_store(Fossil.SuperRegistry super_registry){
		var store_registry = (super_registry.retrieve("core.stores") as Fossil.Registry.StoreRegistry);
		var mimeguesser = (super_registry.retrieve("core.mimeguesser") as Fossil.Registry.MimetypeGuesser);
		if (store_registry != null){
			store_registry.add_resource_store("file://",new Fossil.Store.File.with_mimeguesser(mimeguesser));
		}
	}
	
	public static void setup_uri_autocompletion(Fossil.SuperRegistry super_registry){
		var uri_autoprefixer = (super_registry.retrieve("core.uri_autoprefixer") as Fossil.Registry.UriAutoprefix);
		if (uri_autoprefixer != null){
			uri_autoprefixer.add("file:","file://");
			uri_autoprefixer.add("file://","file://");
			uri_autoprefixer.add("/","file:///");
			uri_autoprefixer.add("~/","file://"+GLib.Environment.get_home_dir()+"/");
		}
	}
	
}
