class Dragonstone.Store.Switch : Object, Dragonstone.ResourceStore {

	private List<Dragonstone.Store.SwitchEntry> stores = new List<Dragonstone.Store.SwitchEntry>();
	public Dragonstone.Resource default_resource;
	
	public Switch(Dragonstone.Resource default_resource){
		this.default_resource = default_resource;
	}
	
	public Switch.default_configuration(){
		this.default_resource = new Dragonstone.ResourceUriSchemeError("");
		this.add_resource_store("test://",new Dragonstone.Store.Test());
		this.add_resource_store("gopher://",new Dragonstone.Store.Gopher());
		this.add_resource_store("gemini://",new Dragonstone.Store.Gemini());
	}
	
	public void add_resource_store(string prefix,Dragonstone.ResourceStore store){
		stores.append(new Dragonstone.Store.SwitchEntry(prefix,store));
	}
	
	public Dragonstone.ResourceStore? get_closest_match(string uri){
		Dragonstone.ResourceStore bestMatch = null;
		uint closest_match_length = 0;
		foreach(Dragonstone.Store.SwitchEntry entry in stores){
			if (uri.has_prefix(entry.prefix) && entry.prefix.length > closest_match_length){
				bestMatch = entry.store;
				closest_match_length = entry.prefix.length;
			}
		}
		return bestMatch;
	}
	
	public void preload(string uri,Dragonstone.SessionInformation? session = null) {
		var store = get_closest_match(uri);
		if (store != null){store.preload(uri);}
	}
	
	public void reload(string uri,Dragonstone.SessionInformation? session = null){
		var store = get_closest_match(uri);
		if (store != null){store.reload(uri);}
	}
	
	public Dragonstone.Resource request(string uri,Dragonstone.SessionInformation? session = null){
		var store = get_closest_match(uri);
		if (store != null){return store.request(uri);}
		else {return default_resource;}
	}
}

private class Dragonstone.Store.SwitchEntry {
	public string prefix;
	public Dragonstone.ResourceStore store;
	
	public SwitchEntry(string prefix,Dragonstone.ResourceStore store){
		this.prefix = prefix;
		this.store = store;
	}
}
