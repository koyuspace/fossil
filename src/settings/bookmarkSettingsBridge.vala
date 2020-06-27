public class Dragonstone.SettingsBridge.Bookmarks : Dragonstone.Settings.Bridge, Object {

	public string id;
	Dragonstone.Registry.BookmarkRegistry bookmark_registry;
	
	private bool dirty = false;
	//uri<\t>name
	
	public Bookmarks(string id, Dragonstone.Registry.BookmarkRegistry bookmark_registry){
		this.id = id;
		this.bookmark_registry = bookmark_registry;
		bookmark_registry.bookmark_added.connect(make_dirty);
		bookmark_registry.bookmark_modified.connect(make_dirty);
		bookmark_registry.bookmark_removed.connect(make_dirty);
	}
	
	public bool import(Dragonstone.Settings.Provider settings_provider){
		Dragonstone.Settings.Rom? rom = settings_provider.get_object(id);
		if (rom == null){ return false; }
		string input = rom.content;
		if (input == null){ return false; }
		string[] lines = input.split("\n");
		foreach (string line in lines){
			string[] tokens = line.strip().split("\t",2);
			if (tokens.length == 2){
				bookmark_registry.add_bookmark(tokens[1].strip() ,tokens[0].strip());
			}
		}
		dirty = false;
		return true;
	}
	
	//very naive, to be improved
	public bool export(Dragonstone.Settings.Provider settings_provider){
		dirty = false;
		string output = "";
		bookmark_registry.iterate_over_all_bookmarks((entry) => {
			output = output+@"$(entry.uri)\t$(entry.name)\n";
			return true;
		});
		settings_provider.upload_object(this.id, output);
		return true;
	}
	
	public bool is_dirty(){
		return dirty;
	}	
	
	public void make_dirty(){
		dirty = true;
	}
	
	public void unhook(){
		bookmark_registry.bookmark_added.disconnect(make_dirty);
		bookmark_registry.bookmark_modified.disconnect(make_dirty);
		bookmark_registry.bookmark_removed.disconnect(make_dirty);
	}
	
}
