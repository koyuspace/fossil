public class Dragonstone.SuperRegistry : Object, Dragonstone.Asm.ObjectProvider {

	private HashTable<string,Object> objects = new HashTable<string,Object>(str_hash, str_equal);
	
	public void store(string key,Object val){
		objects.set(key,val);
	}
	
	public Object retrieve(string key){
		return objects.get(key);
	}
	
	public void @foreach(HFunc<string,Object> cb){
		objects.@foreach(cb);
	}
	
	public void foreach_asm_object(HFunc<string,Dragonstone.Asm.AsmObject> cb){
		objects.@foreach((k,v) => {
			if (v is Dragonstone.Asm.AsmObject){
				cb(k,(Dragonstone.Asm.AsmObject) v);
			}
		});
	} // iterates over all object names in this object store
	
	public Dragonstone.Asm.AsmObject? get_asm_object(string name){
		return (Dragonstone.Asm.AsmObject) objects.get(name);
	}
}

errordomain Dragonstone.SuperRegistryError {
    MISSING_ENTRY
}
