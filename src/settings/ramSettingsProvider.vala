public class Dragonstone.Settings.RamProvider : Dragonstone.Settings.Provider, Object {

	public HashTable<string,string> objects = new HashTable<string,string>(str_hash, str_equal);
	public bool writable = true;
	
	public bool has_object(string id){
		return objects.get(id) == null;
	}
	public string? get_object(string id){
		return objects.get(id);
	}
	
	public bool can_upload_object(string id){
		return writable;
	}
	public bool upload_object(string id, string content){
		if (writable) {
			objects.set(id, content);
		}
		return writable;
	}
}
