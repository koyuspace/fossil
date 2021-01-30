public class Dragonstone.GtkUi.View.Cache : Gtk.Bin, Dragonstone.GtkUi.Interface.View {
	
	private Dragonstone.Request? request = null;
	private Dragonstone.GtkUi.Tab? tab = null;
	private Dragonstone.Registry.TranslationRegistry? translation = null;
	private Dragonstone.GtkUi.Widget.CacheView? cacheview = null;
	
	public Cache(Dragonstone.Registry.TranslationRegistry? translation){
		this.translation = translation;
	}
	
	public bool display_resource(Dragonstone.Request request, Dragonstone.GtkUi.Tab tab, bool as_subview){
		if (!(request.status == "interactive/cache")) {return false;}
		this.request = request;
		this.tab = tab;
		var icache = tab.session.get_cache() as Dragonstone.Store.Cache;
		var cache = tab.session.get_cache();
		
		if (icache != null){
			cacheview = new Dragonstone.GtkUi.Widget.CacheView(icache,tab,translation);
			add(cacheview);
			cacheview.show();
			show();
		} else if (cache != null){
			add(new Gtk.Label("This session has a cache, but this view currently has no way to show its content"));
			show_all();
		} else {
			add(new Gtk.Label("It seems like, this session does not have a cache.\nSession name: "+tab.session.get_name()));
			show_all();
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
		if (cacheview != null){
			cacheview.cleanup();
		}
	}
	
	
}
