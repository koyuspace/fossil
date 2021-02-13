public class Dragonstone.GtkUi.LegacyWidget.CacheView : Gtk.Box {
	
	private Dragonstone.GtkUi.LegacyWidget.Tab tab;
	private Dragonstone.Store.Cache cache;
	private Gtk.ListStore liststore = new Gtk.ListStore(4,typeof(string),typeof(string),typeof(string),typeof(string));
	private HashTable<string,Gtk.TreeIter?> displayed_uris = new HashTable<string,Gtk.TreeIter?>(str_hash, str_equal);
	private Gtk.TreeModelFilter filterstore;
	private Gtk.Entry search_entry;
	private Gtk.Box controls = new Gtk.Box(Gtk.Orientation.HORIZONTAL,1);
	private Gtk.Button pinbutton;
	private Gtk.TreeView treeview;
	private Gtk.ToggleButton search_toggle;
	private string? selected_uri = null;
	private bool still_alive = true;
	private bool search_dirty = true;
	private string translation_forever = "forever";
	private string translation_over_a_year = "over a year";
	
	/*
		Colums:
		0: uri
		1: filename
		2: TTL as text
		3: # of users as string
	*/
	
	public CacheView(Dragonstone.Store.Cache cache, Dragonstone.GtkUi.LegacyWidget.Tab tab, Dragonstone.Registry.TranslationRegistry? itranslation){
		var translation = itranslation;
		if(translation == null) {
			var language = new Dragonstone.Registry.TranslationLanguageRegistry();
			language.set_text("view.interactive/cache.erase_cache","Erase cache");
			language.set_text("view.interactive/cache.search.placeholder","Search for uri ...");
			language.set_text("view.interactive/cache.remove.tooltip","Remove resource from cache");
			language.set_text("view.interactive/cache.open_in_new_tab.tooltip","Open resource in new tab");
			language.set_text("view.interactive/cache.pin.tooltip","Stop resource from expireing");
			language.set_text("view.interactive/cache.column.uri.head","Uri");
			language.set_text("view.interactive/cache.colum.time_to_live.head","TTL");
			language.set_text("view.interactive/cache.colum.users.head","Users");
			language.set_text("view.interactive/cache.duration.infinite","forever");
			language.set_text("view.interactive/cache.duration.over_a_year","over a year");
			translation = language;
		}
		this.translation_forever = translation.localize("view.interactive/cache.duration.infinite");
		this.translation_over_a_year = translation.localize("view.interactive/cache.duration.over_a_year");
		this.cache = cache;
		this.tab = tab;
		//init gui
		expand = true;
		orientation = Gtk.Orientation.VERTICAL;
		var actionbar = new Gtk.ActionBar();
		actionbar.expand = false;
		//erasebutton
		var erasebutton = new Gtk.Button.with_label(translation.localize("view.interactive/cache.erase_cache"));
		erasebutton.get_style_context().add_class("destructive-action");
		actionbar.pack_end(erasebutton);
		erasebutton.clicked.connect(() => {
			if (cache != null){
				cache.erase();
			}
		});
		//search_toggle
		search_toggle = new Gtk.ToggleButton();
		var searchicon = new Gtk.Image.from_icon_name("system-search-symbolic",Gtk.IconSize.SMALL_TOOLBAR);
		search_toggle.add(searchicon);
		search_toggle.toggled.connect(() => {
			erasebutton.visible = !search_toggle.active;
			search_entry.visible = search_toggle.active;
			if (search_entry.visible){
				search_entry.grab_focus_without_selecting();
			}
		});
		actionbar.pack_start(search_toggle);
		//search_entry
		search_entry = new Gtk.Entry();
		search_entry.placeholder_text = translation.localize("view.interactive/cache.search.placeholder");
		//search_entry.width_chars = 35;
		search_entry.expand = true;
		search_entry.buffer.deleted_text.connect(() => {this.search_dirty = true;});
		search_entry.buffer.inserted_text.connect(() => {this.search_dirty = true;});
		actionbar.pack_start(search_entry);
		//populate controls box
		controls.pack_start(new Gtk.Separator(Gtk.Orientation.VERTICAL));
		//removebutton
		var removebutton = new Gtk.Button.from_icon_name("list-remove-symbolic");
		removebutton.get_style_context().add_class("destructive-action");
		removebutton.set_tooltip_text(translation.localize("view.interactive/cache.remove.tooltip"));
		controls.pack_start(removebutton);
		removebutton.clicked.connect(remove_selected);
		//gotobutton
		var gotobutton = new Gtk.Button.from_icon_name("go-jump-symbolic");
		gotobutton.set_tooltip_text(translation.localize("view.interactive/cache.open_in_new_tab.tooltip"));
		controls.pack_start(gotobutton);
		gotobutton.clicked.connect(open_selected_in_new_tab);
		//pinbutton
		pinbutton = new Gtk.Button.from_icon_name("view-pin-symbolic");
		pinbutton.set_tooltip_text(translation.localize("view.interactive/cache.pin.tooltip"));
		controls.pack_start(pinbutton);
		pinbutton.clicked.connect(pin_selected);
		controls.pack_start(new Gtk.Separator(Gtk.Orientation.VERTICAL));
		//add controls to actionbar
		//controls.visible = false;
		actionbar.pack_start(controls);
		//stores
		filterstore = new Gtk.TreeModelFilter((Gtk.TreeModel) liststore,null);
		filterstore.set_visible_func(filter_visible_function);
		//treeview
		treeview = new Gtk.TreeView();
		treeview.get_selection().set_mode(Gtk.SelectionMode.SINGLE);
		treeview.set_model(filterstore);
		treeview.insert_column_with_attributes(-1,translation.localize("view.interactive/cache.column.users.head"), new Gtk.CellRendererText (), "text", 3);
		treeview.insert_column_with_attributes(-1,translation.localize("view.interactive/cache.column.time_to_live.head"), new Gtk.CellRendererText (), "text", 2);
		treeview.insert_column_with_attributes(-1,translation.localize("view.interactive/cache.column.uri.head"), new Gtk.CellRendererText (), "text", 0);
		//treeview.insert_column_with_attributes(-1,"Filename", new Gtk.CellRendererText (), "text", 1);
		treeview.row_activated.connect(treeview_row_activated);
		treeview.cursor_changed.connect(update_selected_uri);
		//scrolled window
		var scrolled_window = new Gtk.ScrolledWindow(null,null);
		scrolled_window.add(treeview);
		scrolled_window.expand = true;
		//pack to root window
		pack_start(actionbar);
		pack_start(scrolled_window);
		set_child_packing(actionbar,false,true,0,Gtk.PackType.START);
		set_child_packing(scrolled_window,true,true,0,Gtk.PackType.START);
		//show all
		show_all();
		controls.visible = false;
		search_entry.visible = false;
		refresh_cache_items();
		Timeout.add(1000,() => {
			//print(@"[cache.gtk] refresh [$still_alive]\n");
			if (still_alive){
				refresh_cache_items();
			}
			return still_alive;
		});
	}
	
	private void refresh_cache_items(){
		//update existing
		foreach (string uri in this.displayed_uris.get_keys()){
			var resource = this.cache.cached_resources.get(uri);
			var iter = this.displayed_uris.get(uri);
			if (resource != null) {
				//update
				liststore.set_value(iter,2,format_time_to_live(resource.valid_until));
				liststore.set_value(iter,3,resource.users.to_string());
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
					liststore.set (iter, 0, resource.uri, 1, resource.filepath, 2, ttl, 3, resource.users.to_string());
					displayed_uris.set(uri,iter);
				}
				search_dirty = true;
			}
		}
		if (search_dirty){
			search_dirty = false;
			filterstore.refilter();
		}
		//show_all();
		update_selected_uri();
	}
	
	private bool filter_visible_function(Gtk.TreeModel model, Gtk.TreeIter iter){
		string uri = get_uri_from_model(model,iter);
		if (uri != null){
			return uri.contains(this.search_entry.buffer.text);
		} else {
			return false;
		}
	}
	
	private string format_time_to_live(int64 valid_until){
		if (valid_until == int64.MAX){
			return translation_forever;
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
				return translation_over_a_year;
			}
			return sign+("%02d:%02d:%02d".printf((int) hours, (int) (minutes%60), (int) (seconds%60)));
		}
	}
	
	private void treeview_row_activated(Gtk.TreePath path, Gtk.TreeViewColumn column){
		Gtk.TreeIter iter;
		if(!filterstore.get_iter(out iter,path)){
			return;
		}
		string uri = get_uri_from_model(filterstore,iter);
		if (uri != null && tab != null){
			tab.go_to_uri(uri);
		}
	}
	
	private void update_controls(){
		controls.visible = selected_uri != null;
		if (selected_uri != null){
			var resource = cache.cached_resources.get(selected_uri);
			if (resource != null){
				pinbutton.sensitive = resource.valid_until != int64.MAX;
			}
		}
	}
	
	private void remove_selected(){
		if (selected_uri != null){
			cache.invalidate_for_uri(selected_uri);
			refresh_cache_items();
		}
	}
	
	private void open_selected_in_new_tab(){
		if (selected_uri != null){
			tab.open_uri_in_new_tab(selected_uri);
		}
	}
	
	private void pin_selected(){
		if (selected_uri != null){
			var resource = cache.cached_resources.get(selected_uri);
			if (resource != null){
				resource.valid_until = int64.MAX;
				pinbutton.sensitive = false;
			}
		}
	}
	
	private void update_selected_uri(){
		var selection = treeview.get_selection();
		Gtk.TreeModel model;
		Gtk.TreeIter iter;
		if (selection.get_selected(out model, out iter)) {
			selected_uri = get_uri_from_model(model,iter);
		} else {
			selected_uri = null;
		}
		this.update_controls();
	}
	
	private string? get_uri_from_model(Gtk.TreeModel model, Gtk.TreeIter iter){
		Value urival;
		model.get_value(iter,0,out urival);
		return urival.get_string();
	}
	
	public void cleanup(){
		print("[cacheview.gtk] cleanup function called!\n");
		still_alive = false;
	}
	
	
}
