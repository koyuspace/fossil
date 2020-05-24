//return true to keep going
public delegate bool Dragonstone.Registry.BookmarkRegistryIterator(BookmarkRegistryEntry entry);

public class Dragonstone.Registry.BookmarkRegistry : Object {
	protected List<BookmarkRegistryEntry> entrys = new List<BookmarkRegistryEntry>();
	
	public signal void bookmark_added(BookmarkRegistryEntry bookmark);
	public signal void bookmark_modified(BookmarkRegistryEntry bookmark);
	public signal void bookmark_removed(BookmarkRegistryEntry bookmark);
	
	construct {
		//Add some examplebookmarks
		add_bookmark("examplebookmark 1","test://");
		add_bookmark("examplebookmark 2","gemini://gemini.conman.org");
		add_bookmark("examplebookmark 3","gopher://g.vulpes.one");
		
	}
	
	public BookmarkRegistryEntry? add_bookmark(string name, string uri){
		string uid = GLib.Uuid.string_random();
		while (get_bookmark_by_uid(uid) != null){
			uid = GLib.Uuid.string_random();
		}
		var entry = new BookmarkRegistryEntry(uid, name, uri);
		entrys.append(entry);
		bookmark_added(entry);
		return entry;
	}
	
	public void remove_bookmark(BookmarkRegistryEntry bookmark){
		entrys.remove_all(bookmark);
		bookmark_removed(bookmark);
	}
	
	public void iterate_over_all_bookmarks(Dragonstone.Registry.BookmarkRegistryIterator callback){
		foreach (var entry in entrys){
			if (!callback(entry)){
				break;
			}
		}
	}
	
	public BookmarkRegistryEntry? get_bookmark_by_uid(string uid){
		foreach (var entry in entrys){
			if (entry.uid == uid){
				return entry;
			}
		}
		return null;
	}
	
	public BookmarkRegistryEntry? get_bookmark_with_name(string name, uint skip = 0){
		foreach (var entry in entrys){
			if (entry.name == name){
				if (skip > 0){
					skip--;
					return entry;
				}
			}
		}
		return null;
	}
	
	public BookmarkRegistryEntry? get_bookmark_with_uri(string uri, uint skip = 0){
		foreach (var entry in entrys){
			if (entry.uri == uri){
				if (skip > 0){
					skip--;
					return entry;
				}
			}
		}
		return null;
	}
	
}

public class Dragonstone.Registry.BookmarkRegistryEntry : Object {
	public string name;
	public string uri;
	public string uid;
	
	public BookmarkRegistryEntry(string uid, string name, string uri){
		this.uid = uid;
		this.name = name;
		this.uri = uri;
	}
}
