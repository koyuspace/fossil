public class Fossil.GtkUi.View.Cache : Gtk.Bin, Fossil.GtkUi.Interface.LegacyView {
	
	private Fossil.Request? request = null;
	private Fossil.GtkUi.LegacyWidget.Tab? tab = null;
	private Fossil.Registry.TranslationRegistry? translation = null;
	private Fossil.GtkUi.LegacyWidget.CacheView? cacheview = null;
	
	public Cache(Fossil.Registry.TranslationRegistry? translation){
		this.translation = translation;
	}
	
	public bool display_resource(Fossil.Request request, Fossil.GtkUi.LegacyWidget.Tab tab, bool as_subview){
		if (!(request.status == "interactive/cache")) {return false;}
		this.request = request;
		this.tab = tab;
		var icache = tab.session.get_cache() as Fossil.Store.Cache;
		var cache = tab.session.get_cache();
		
		if (icache != null){
			cacheview = new Fossil.GtkUi.LegacyWidget.CacheView(icache,tab,translation);
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
