public class Dragonstone.View.Cache : Gtk.Bin, Dragonstone.IView {
	
	private Dragonstone.Request? request = null;
	private Dragonstone.Tab? tab = null;
	Dragonstone.Registry.TranslationRegistry? translation = null;
	
	/*
		Colums:
		0: uri
		1: filename
		2: TTL as text
		3: # of users as string
	*/
	
	public Cache(Dragonstone.Registry.TranslationRegistry? translation){
		this.translation = translation;
	}
	
	public bool displayResource(Dragonstone.Request request,Dragonstone.Tab tab){
		if (!(request.status == "interactive/cache")) {return false;}
		this.request = request;
		this.tab = tab;
		var icache = tab.session.get_cache() as Dragonstone.Store.Cache;
		var cache = tab.session.get_cache();
		
		if (icache != null){
			add(new Dragonstone.Widget.CacheView(icache,tab,translation));
		} else if (cache != null){
			add(new Gtk.Label("This session has a cache, but this view currently has no way to show its content"));
		} else {
			add(new Gtk.Label("It seems like, this session does not have a cache."));
		}		
		return true;
	}
	
	public bool canHandleCurrentResource(){
		if (request == null){
			return false;
		}else{
			return request.status == "interactive/cache";
		}
	}
	
	public void cleanup(){
		print("[cache.gtk] cleanup function called!\n");
	}
	
	
}
