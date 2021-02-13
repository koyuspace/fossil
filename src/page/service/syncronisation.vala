public class Dragonstone.Page.Service.Syncronisation : Object, Dragonstone.Interface.Page.Service.Syncronisation {
	
	private HashTable<string,string> objects = new HashTable<string,string>(str_hash, str_equal);
	
	  ///////////////////////////////////////////////////////
	 // Dragonstone.Interface.Page.Service.Syncronisation //
	///////////////////////////////////////////////////////
	
	public void syncronisation_write(string key, string? val, string module_name){
		if (val == null){
			objects.remove(key);
		} else {
			objects.set(key, val);
		}
		on_syncronisation_update(key, val);
	}
	
	public string? syncronisation_read(string key, string module_name){
		return objects.get(key);
	}
	
	public void foreach_syncronisation_key(Func<string> cb, string module_name){
		objects.foreach((k,_) => {
			cb(k);
		});
	}
}
