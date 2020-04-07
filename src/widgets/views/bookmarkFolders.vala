public class Dragonstone.View.BookmarkFolders : Gtk.ScrolledWindow, Dragonstone.IView {
	
	private Dragonstone.Request request = null;
	private Dragonstone.Tab tab = null;
	private Gtk.ListBox list_box = new Gtk.ListBox();
	private Dragonstone.Registry.Bookmark.FolderRegistry folders;
	
	public BookmarkFolders(Dragonstone.Registry.Bookmark.FolderRegistry folders){
		this.folders = folders;
		foreach(Dragonstone.Registry.Bookmark.Folder folder in folders.folders){
			list_box.insert(new Gtk.Label(folder.name),-1);
		}
		add(list_box);
	}
	
	public bool displayResource(Dragonstone.Request request,Dragonstone.Tab tab){
		if (!(request.status == "interactive/bookmark_folders")) {return false;}
		this.request = request;
		this.tab = tab;
		return true;
	}
	
	public bool canHandleCurrentResource(){
		if (request == null){
			return false;
		}else{
			return request.status == "interactive/bookmark_folders";
		}
	}	
	
}
