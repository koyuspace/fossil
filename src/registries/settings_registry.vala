public class Dragonstone.Registry.SettingsRegistry : Dragonstone.Interface.Settings.Provider, Object {
	public List<Dragonstone.Interface.Settings.Provider> providers = new List<Dragonstone.Interface.Settings.Provider>();
	
	public void add_provider(Dragonstone.Interface.Settings.Provider provider){
		providers.prepend(provider);
	}
	
	public bool has_object(string id){
		foreach (var provider in providers){
			if (provider.has_object(id)){
				return true;
			}
		}
		return false;
	}
	
	public Dragonstone.Interface.Settings.Rom? get_object(string id){
		foreach (var provider in providers){
			var object = provider.get_object(id);
			if (object != null){
				return object;
			}
		}
		return null;
	}
	
	public bool can_upload_object(string id){
		foreach (var provider in providers){
			if (provider.can_upload_object(id)){
				return true;
			}
		}
		return false;
	}
	public bool upload_object(string id, string content){
		foreach (var provider in providers){
			//only update topmost writable level to no destroy system configuration or sane defaults
			if (provider.upload_object(id,content)){
				return true;
			}
		}
		return false;
	}
	
	public HashTable<string,Dragonstone.Interface.Settings.Bridge> bridges = new HashTable<string,Dragonstone.Interface.Settings.Bridge>(str_hash, str_equal);
	
	public void add_bridge(string name, Dragonstone.Interface.Settings.Bridge bridge){
		bridges.set(name,bridge);
	}
	
	public Dragonstone.Interface.Settings.Bridge? get_bridge(string name){
		return bridges.get(name);
	}
	
	public void import_all(){
		foreach(string name in bridges.get_keys()){
			var bridge = bridges.get(name);
			if (bridge != null){
				bridge.import(this);
			}
		}
	}
	
	public void export_all(){
		foreach(string name in bridges.get_keys()){
			var bridge = bridges.get(name);
			if (bridge != null){
				if (bridge.is_dirty()){
					bridge.export(this);
				}
			}
		}
	}
	
}
