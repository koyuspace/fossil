public class Fossil.Page.Service.Metadata : Object, Fossil.Interface.Page.Service.Metadata {
	
	private HashTable<string,string> metadata = new HashTable<string,string>(str_hash, str_equal);
	
	  /////////////////////////////////////////////////
	 // Fossil.Interface.Page.Service.Metadata //
	/////////////////////////////////////////////////
	
	public void set_page_metadata(string key, string? val, string module_name){
		if (val == null){
			metadata.remove(key);
		} else {
			metadata.set(key, val);
		}
		on_page_metadata_change(key, val);
	}
	
	public string? get_page_metadata(string key, string module_name){
		return metadata.get(key);
	}
	
	public void foreach_page_metadata_key(Func<string> cb, string module_name){
		metadata.foreach((k,_) => {
			cb(k);
		});
	}
	
}
