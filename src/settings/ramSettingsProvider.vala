public class Dragonstone.Settings.RamProvider : Dragonstone.Settings.Provider, Object {

	public HashTable<string,Dragonstone.Settings.RomProvider> objects = new HashTable<string,Dragonstone.Settings.RomProvider>(str_hash, str_equal);
	public bool writable = true;
	
	public bool has_object(string id){
		return objects.get(id) == null;
	}
	public Dragonstone.Settings.Rom? get_object(string id){
		var rom_provider = objects.get(id);
		if (rom_provider == null){ return null; }
		return new Dragonstone.Settings.Rom(rom_provider);
	}
	
	public bool can_upload_object(string id){
		return writable;
	}
	public bool upload_object(string id, string content){
		if (writable) {
			var rom_provider = objects.get(id);
			if (rom_provider == null){
				rom_provider = new Dragonstone.Settings.RomProvider(content);
			} else {
				rom_provider.content = content;
			}
		}
		return writable;
	}
}
