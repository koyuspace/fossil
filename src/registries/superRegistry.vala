public class Dragonstone.Registry.SuperRegistry : Object {

	private Gee.HashMap<string,Object> objects = new Gee.HashMap<string,Object>();
	
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
