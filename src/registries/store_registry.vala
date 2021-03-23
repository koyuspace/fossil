public class Fossil.Registry.StoreRegistry : Object {
	private List<Fossil.Registry.StoreRegistryEntry> stores = new List<Fossil.Registry.StoreRegistryEntry>();
	
	public StoreRegistry.default_configuration(){
		this.add_resource_store("fossil://",new Fossil.Store.Internal());
	}
	
	public void add_resource_store(string prefix,Fossil.Interface.ResourceStore store){
		stores.append(new Fossil.Registry.StoreRegistryEntry(prefix,store));
	}
	
	public Fossil.Interface.ResourceStore? get_closest_match(string uri){
		Fossil.Interface.ResourceStore best_match = null;
		uint closest_match_length = 0;
		foreach(Fossil.Registry.StoreRegistryEntry entry in stores){
			if (uri.has_prefix(entry.prefix) && entry.prefix.length > closest_match_length){
				best_match = entry.store;
				closest_match_length = entry.prefix.length;
			}
		}
		return best_match;
	}
	
}

private class Fossil.Registry.StoreRegistryEntry {
	public string prefix;
	public Fossil.Interface.ResourceStore store;
	
	public StoreRegistryEntry(string prefix,Fossil.Interface.ResourceStore store){
		this.prefix = prefix;
		this.store = store;
	}
}
