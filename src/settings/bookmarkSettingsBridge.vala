public class Dragonstone.SettingsBridge.Bookmarks : Dragonstone.Settings.Bridge, Object {

	public string id;
	Dragonstone.Registry.BookmarkRegistry bookmark_registry;
	
	//uri<\t>name
	
	public Bookmarks(string id, Dragonstone.Registry.BookmarkRegistry bookmark_registry){
		this.id = id;
		this.bookmark_registry = bookmark_registry;
	}
	
	public bool import(Dragonstone.Settings.Provider settings_provider){
		string? input = settings_provider.get_object(id);
		if (input == null){ return false; }
		string[] lines = input.split("\n");
		foreach (string line in lines){
			string[] tokens = line.strip().split("\t",2);
			if (tokens.length == 2){
				bookmark_registry.add_bookmark(tokens[1].strip() ,tokens[0].strip());
			}
		}
		return true;
	}
	
	//very naive, to be improved
	public bool export(Dragonstone.Settings.Provider settings_provider){
		string output = "";
		bookmark_registry.iterate_over_all_bookmarks((entry) => {
			output = output+@"$(entry.uri)\t$(entry.name)\n";
			return true;
		});
		settings_provider.upload_object(this.id, output);
		return true;
	}

}
