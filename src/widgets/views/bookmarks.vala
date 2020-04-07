public class Dragonstone.View.Bookmarks : Gtk.ScrolledWindow, Dragonstone.IView {
	
	private Dragonstone.Request request = null;
	private Dragonstone.Tab tab = null;
	private Gtk.ListBox list_box = new Gtk.ListBox();
	private Dragonstone.Registry.Bookmark.FolderRegistry folders;
	
	public Bookmarks(Dragonstone.Registry.Bookmark.FolderRegistry folders){
		this.folders = folders;
	}
	
	public bool displayResource(Dragonstone.Request request,Dragonstone.Tab tab){
		if (!(request.status == "interactive/bookmarks")) {return false;}
		this.request = request;
		add(new Gtk.Label(request.substatus));
		this.tab = tab;
		return true;
	}
	
	public bool canHandleCurrentResource(){
		if (request == null){
			return false;
		}else{
			return request.status == "interactive/bookmarks";
		}
	}	
	
}
