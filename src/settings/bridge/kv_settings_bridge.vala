public class Dragonstone.Settings.Bridge.KV : Object {

	public string path;
	public HashTable<string,string> values = new HashTable<string,string>(str_hash,str_equal);	
	
	public signal void updated_key(string key);
	
	private bool dirty = false;
	private Dragonstone.Interface.Settings.Provider settings_provider;
	
	public KV(Dragonstone.Interface.Settings.Provider settings_provider, string path){
		this.settings_provider = settings_provider;
		this.path = path;
		import();
	}
	
	public bool import(){
		string? input = settings_provider.read_object(path);
		if (input == null){ return false; }
		string[] lines = input.split("\n");
		foreach (string line in lines){
			string[] tokens = line.strip().split(":",2);
			if (tokens.length == 2){
				values.set(tokens[0].strip(),tokens[1].strip());
			}
		}
		dirty = false;
		return true;
	}
	
	//very naive, to be improved
	public bool export(){
		dirty = false;
		string output = "";
		foreach (string key in values.get_keys()){
			string? val = values.get(key);
			if (val != null){
				output = output+@"$key: $val\n";
			}
		}
		dirty = false;
		settings_provider.write_object(this.path, output);
		return true;
	}
	
	public bool is_dirty(){
		return dirty;
	}	
	
	public bool set_if_null(string key, string val){
		if (values.get(key) == null){
			values.set(key,val);
			updated_key(key);
			return true;
		}
		return false;
	}
	
	public void set_value(string key, string val){
		values.set(key,val);
		updated_key(key);
		make_dirty();
	}
	
	private void make_dirty(){
		lock (dirty) {
			if (!dirty) {
				dirty = true;
				Timeout.add(5000,() => {
					export();
					return false;
				});
			}
		}
	}

}
