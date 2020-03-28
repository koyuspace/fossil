public class Dragonstone.View.Cache : Gtk.Bin, Dragonstone.IView {
	
	private Dragonstone.Request request = null;
	private Dragonstone.Store.Cache cache;
	private Gtk.ListStore liststore = new Gtk.ListStore(4,typeof(string),typeof(string),typeof(string),typeof(string));
	private HashTable<string,Gtk.TreeIter?> displayed_uris = new HashTable<string,Gtk.TreeIter?>(str_hash, str_equal);
	private bool still_alive = true;
	
	/*
		Colums:
		0: uri
		1: filename
		2: TTL as text
	*/
	
	public Cache(Dragonstone.Store.Cache cache){
		this.cache = cache;
		refresh_cache_items();
		Timeout.add(1000,() => {
			//print(@"[cache.gtk] refresh [$still_alive]\n");
			refresh_cache_items();
			return still_alive;
		});
	}
	
	construct {
		var box = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		var actionbar = new Gtk.ActionBar();
		var treeview = new Gtk.TreeView();
		treeview.set_model(liststore);
		treeview.insert_column_with_attributes(-1,"Uri", new Gtk.CellRendererText (), "text", 0);
		treeview.insert_column_with_attributes(-1,"Filename", new Gtk.CellRendererText (), "text", 1);
		treeview.insert_column_with_attributes(-1,"TTL", new Gtk.CellRendererText (), "text", 2);
		//box.pack_start(actionbar);
		box.pack_end(treeview);
		add(box);
		show_all();
	}
	
	private void refresh_cache_items(){
		//update existing
		foreach (string uri in this.displayed_uris.get_keys()){
			var resource = this.cache.cached_resources.get(uri);
			var iter = this.displayed_uris.get(uri);
			if (resource != null) {
				//update
				liststore.set_value(iter,2,format_time_to_live(resource.valid_until));
			} else {
				//remove
				liststore.remove(ref iter);
				this.displayed_uris.remove(uri);
			}
		}
		//add new
		Gtk.TreeIter iter;
		foreach (string uri in this.cache.cached_resources.get_keys()){
			if (!displayed_uris.contains(uri)){
				var resource = this.cache.cached_resources.get(uri);
				if (resource != null){
					liststore.append (out iter);
					string ttl = format_time_to_live(resource.valid_until);
					//print(@"[cache.gtk] $(resource.uri) | $(resource.filepath) | $ttl\n");
					liststore.set (iter, 0, resource.uri, 1, resource.filepath, 2, ttl);
					displayed_uris.set(uri,iter);
				}
			}
		}
		show_all();
	}
	
	private string format_time_to_live(int64 valid_until){
		if (valid_until == int64.MAX){
			return "forever"; //TOTRANSLATE
		} else {
			string sign;
			int64 seconds = ((valid_until - (GLib.get_real_time()/1000))/1000);
			if (seconds < 0) {
				sign = "-";
				seconds = -seconds;
			} else {
				sign = "+";
			}
			int64 minutes = seconds/60;
			int64 hours = minutes/60;
			if (hours > 8760){
				return "over a year"; //TOTRANSLATE
			}
			return sign+("%02d:%02d:%02d".printf((int) hours, (int) (minutes%60), (int) (seconds%60)));
		}
	}	
	
	public bool displayResource(Dragonstone.Request request,Dragonstone.Tab tab){
		if (!(request.status == "interactive/cache")) {return false;}
		this.request = request;
		//nameLabel.label = request.name;
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
		still_alive = false;
	}
	
	
}
