public class Fossil.Settings.RamProvider : Fossil.Interface.Settings.Provider, Object {

	public HashTable<string,string> objects = new HashTable<string,string>(str_hash, str_equal);
	public bool writable = true;
	
	  /////////////////////////////////////////////
	 // Fossil.Interface.Settings.Provider //
	/////////////////////////////////////////////
	
	public void request_index(string path_prefix, Func<string> cb){
		objects.foreach((k,_) => {
			cb(k);
		});
	}
	
	public bool has_object(string path){
		return objects.get(path) != null;
	}

	public string? read_object(string path){
		return objects.get(path);
	}
	
	public bool can_write_object(string path){
		return writable;
	}
	
	public bool write_object(string path, string? content){
		if (writable) {
			if (content == null){
				objects.remove(path);
			} else {
				objects.set(path, content);
			}
			settings_updated(path);
		}
		return writable;
	}
}
