public class Dragonstone.Registry.StoreRegistry : Object {
	private List<Dragonstone.Registry.StoreRegistryEntry> stores = new List<Dragonstone.Registry.StoreRegistryEntry>();
	
	public StoreRegistry.default_configuration(){
		this.add_resource_store("test://",new Dragonstone.Store.Test());
		this.add_resource_store("gopher://",new Dragonstone.Store.Gopher());
		this.add_resource_store("gemini://",new Dragonstone.Store.Gemini());
		this.add_resource_store("about:",new Dragonstone.Store.About());
		this.add_resource_store("file://",new Dragonstone.Store.File());
	}
	
	public void add_resource_store(string prefix,Dragonstone.ResourceStore store){
		stores.append(new Dragonstone.Registry.StoreRegistryEntry(prefix,store));
	}
	
	public Dragonstone.ResourceStore? get_closest_match(string uri){
		Dragonstone.ResourceStore best_match = null;
		uint closest_match_length = 0;
		foreach(Dragonstone.Registry.StoreRegistryEntry entry in stores){
			if (uri.has_prefix(entry.prefix) && entry.prefix.length > closest_match_length){
				best_match = entry.store;
				closest_match_length = entry.prefix.length;
			}
		}
		return best_match;
	}
	
}

private class Dragonstone.Registry.StoreRegistryEntry {
	public string prefix;
	public Dragonstone.ResourceStore store;
	
	public StoreRegistryEntry(string prefix,Dragonstone.ResourceStore store){
		this.prefix = prefix;
		this.store = store;
	}
}
