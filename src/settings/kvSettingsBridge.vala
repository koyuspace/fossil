public class Dragonstone.Settings.KVSettings : Dragonstone.Settings.Bridge, Object {

	public string id;
	public HashTable<string,string> values = new HashTable<string,string>(str_hash,str_equal);	
	
	public signal void updated_key(string key);
	
	private bool dirty = false;
	
	public KVSettings(string id){
		this.id = id;
		this.updated_key.connect(() => {dirty = true;});
	}
	
	public bool import(Dragonstone.Settings.Provider settings_provider){
		string? input = settings_provider.get_object(id);
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
	public bool export(Dragonstone.Settings.Provider settings_provider){
		string output = "";
		foreach (string key in values.get_keys()){
			string? val = values.get(key);
			if (val != null){
				output = output+@"$key: $val\n";
			}
		}
		dirty = false;
		settings_provider.upload_object(this.id, output);
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
	}

}
