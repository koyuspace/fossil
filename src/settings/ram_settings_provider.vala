public class Dragonstone.Settings.RamProvider : Dragonstone.Interface.Settings.Provider, Object {

	public HashTable<string,Dragonstone.Interface.Settings.RomProvider> objects = new HashTable<string,Dragonstone.Interface.Settings.RomProvider>(str_hash, str_equal);
	public bool writable = true;
	
	public bool has_object(string id){
		return objects.get(id) == null;
	}
	public Dragonstone.Interface.Settings.Rom? get_object(string id){
		var rom_provider = objects.get(id);
		if (rom_provider == null){ return null; }
		return new Dragonstone.Interface.Settings.Rom(rom_provider);
	}
	
	public bool can_upload_object(string id){
		return writable;
	}
	public bool upload_object(string id, string content){
		if (writable) {
			var rom_provider = objects.get(id);
			if (rom_provider == null){
				rom_provider = new Dragonstone.Interface.Settings.RomProvider(content);
			} else {
				rom_provider.content = content;
			}
		}
		return writable;
	}
}
