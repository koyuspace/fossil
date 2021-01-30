public class Dragonstone.Registry.StoreRegistry : Object {
	private List<Dragonstone.Registry.StoreRegistryEntry> stores = new List<Dragonstone.Registry.StoreRegistryEntry>();
	
	public StoreRegistry.default_configuration(){
		this.add_resource_store("test://",new Dragonstone.Store.Test());
	}
	
	public void add_resource_store(string prefix,Dragonstone.Interface.ResourceStore store){
		stores.append(new Dragonstone.Registry.StoreRegistryEntry(prefix,store));
	}
	
	public Dragonstone.Interface.ResourceStore? get_closest_match(string uri){
		Dragonstone.Interface.ResourceStore best_match = null;
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
	public Dragonstone.Interface.ResourceStore store;
	
	public StoreRegistryEntry(string prefix,Dragonstone.Interface.ResourceStore store){
		this.prefix = prefix;
		this.store = store;
	}
}
