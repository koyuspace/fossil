public class Dragonstone.SuperRegistry : Object {

	private HashTable<string,Object> objects = new HashTable<string,Object>(str_hash, str_equal);
	
	public void store(string key,Object val){
		objects.set(key,val);
	}
	
	public Object retrieve(string key){
		return objects.get(key);
	}
}

errordomain Dragonstone.SuperRegistryError {
    MISSING_ENTRY
}
