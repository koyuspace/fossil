public class Dragonstone.Registry.SettingsRegistry : Dragonstone.Settings.Provider, Object {
	public List<Dragonstone.Settings.Provider> providers = new List<Dragonstone.Settings.Provider>();
	
	public void add_provider(Dragonstone.Settings.Provider provider){
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
	public string? get_object(string id){
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
	
	public HashTable<string,Dragonstone.Settings.Bridge> bridges = new HashTable<string,Dragonstone.Settings.Bridge>(str_hash, str_equal);
	
	public void add_bridge(string name, Dragonstone.Settings.Bridge bridge){
		bridges.set(name,bridge);
	}
	
	public Dragonstone.Settings.Bridge? get_bridge(string name){
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
				bridge.export(this);
			}
		}
	}
	
}
