public class Dragonstone.Registry.Bookmark.FolderRegistry : Object {
	public List<Folder> folders = new List<Folder>();
	
	public void add_folder(Folder folder){
		folders.append(folder);
	}
	
	public void remove_foler(Folder folder){
		folders.remove(folder);
	}
	
	public Folder? get_folder_by_name(string name, uint skip = 0){
		foreach(Folder folder in folders){
			if (folder.name == name){
				if (skip == 0){
					return folder;
				} else {
					skip--;
				}
			}
		}
		return null;
	}
	
	public Folder? get_folder_by_backend(string backend, uint skip = 0){
		foreach(Folder folder in folders){
			if (folder.backend == backend){
				if (skip == 0){
					return folder;
				} else {
					skip--;
				}
			}
		}
		return null;
	}
	
}

public class Dragonstone.Registry.Bookmark.Folder : Object {
	public List<Entry> entrys = new List<Entry>();
	public string name;
	public string description;
	public string backend;
	public string? source;
	
	public Folder(string name, string description, string backend="temp", string? source = null){
		this.name = name;
		this.description = description;
		this.backend = backend;
		this.source = source;
	}
		
	public void add_bookmark(Entry bookmark){
		entrys.append(bookmark);
	}
	
	public void remove_bookmark(Entry bookmark){
		entrys.remove(bookmark);
	}
	
	public Entry? get_bookmark_by_name(string name, uint skip = 0){
		foreach(Entry entry in entrys){
			if (entry.name == name){
				if (skip == 0){
					return entry;
				} else {
					skip--;
				}
			}
		}
		return null;
	}
	
	public Entry? get_bookmark_by_uri(string uri, uint skip = 0){
		foreach(Entry entry in entrys){
			if (entry.uri == uri){
				if (skip == 0){
					return entry;
				} else {
					skip--;
				}
			}
		}
		return null;
	}
	
	public Entry? get_bookmark_by_tag(string tag, uint skip = 0){
		foreach(Entry entry in entrys){
			if (entry.has_tag(tag)){
				if (skip == 0){
					return entry;
				} else {
					skip--;
				}
			}
		}
		return null;
	}
	
}

public class Dragonstone.Registry.Bookmark.Entry : Object {

	public string name;
	public string uri;
	public List<string> tags = new List<string>();
	
	public Entry(string name, string uri){
		this.name = name;
		this.uri = uri;
	}
	
	public void add_tag(string tag){
		if (!has_tag(tag)) {
			tags.append(tag);
		}
	}
	
	public void remove_tag(string tag){
		tags.remove(tag);
	}
	
	public bool has_tag(string tag){
		unowned var entry = tags.find(tag);
		return entry != null;
	}
	
}
