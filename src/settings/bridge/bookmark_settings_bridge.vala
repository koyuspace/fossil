public class Fossil.Settings.Bridge.Bookmarks : Object {

	public string path;
	private Fossil.Registry.BookmarkRegistry bookmark_registry;
	private Fossil.Interface.Settings.Provider settings_provider;
	
	private bool dirty = false;
	//uri<\t>name
	
	public Bookmarks(Fossil.Interface.Settings.Provider settings_provider, string path, Fossil.Registry.BookmarkRegistry bookmark_registry){
		this.settings_provider = settings_provider;
		this.path = path;
		this.bookmark_registry = bookmark_registry;
		import();
		bookmark_registry.bookmark_added.connect(make_dirty);
		bookmark_registry.bookmark_modified.connect(make_dirty);
		bookmark_registry.bookmark_removed.connect(make_dirty);
	}
	
	~Bookmarks(){
		unhook();
	}
	
	public bool import(){
		string input = settings_provider.read_object(path);
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
	public bool export(){
		dirty = false;
		string output = "";
		bookmark_registry.iterate_over_all_bookmarks((entry) => {
			output = output+@"$(entry.uri)\t$(entry.name)\n";
			return true;
		});
		settings_provider.write_object(this.path, output);
		return true;
	}
	
	public bool is_dirty(){
		return dirty;
	}	
	
	public void make_dirty(){
		lock (dirty) {
			if (!dirty) {
				dirty = true;
				Timeout.add(5000,() => {
					export();
					return false;
				});
			}
		}
	}
	
	public void unhook(){
		bookmark_registry.bookmark_added.disconnect(make_dirty);
		bookmark_registry.bookmark_modified.disconnect(make_dirty);
		bookmark_registry.bookmark_removed.disconnect(make_dirty);
	}
	
}
