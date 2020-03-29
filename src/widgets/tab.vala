public class Dragonstone.Tab : Gtk.Bin {
	private string _uri = "";
	public string uri {
		get { return _uri; }
		set { 
			goToUri(value);
		}}
	public Dragonstone.IView view;
	public Dragonstone.Request request;
	public Dragonstone.ResourceStore store { get; set; }
	public signal void uriChanged(string uri);
	public Dragonstone.Util.Stack<string> history = new Dragonstone.Util.Stack<string>();
	public Dragonstone.Util.Stack<string> forward = new Dragonstone.Util.Stack<string>();
	public Dragonstone.SuperRegistry super_registry { get; construct; }
	private Gtk.Window parent_window;
	private int locked = 0;
	//a label widget for adding to tabs in a notebook
	public string title = "New Tab";
	public bool loading = false; //changeing this counts as a title change
	public bool prefer_source_view = false;
	public signal void on_cleanup();
	public signal void on_title_change();
	
	private string resource_user_id = "tab_"+GLib.Uuid.string_random();
	
	private Dragonstone.Registry.ViewRegistry view_registry;
	private Dragonstone.Registry.ViewRegistry source_view_registry;
	
	public Tab(Dragonstone.ResourceStore store, string uri, Gtk.Window parent_window, Dragonstone.SuperRegistry super_registry){
		Object(
			store: store,
			super_registry: super_registry
		);
		this.view_registry = (super_registry.retrieve("gtk.views") as Dragonstone.Registry.ViewRegistry);
		this.source_view_registry = (super_registry.retrieve("gtk.source_views") as Dragonstone.Registry.ViewRegistry);
		if (this.view_registry == null){
			print("[tab] No view registry in super registry, falling back to default configuration!\n");
			this.view_registry = new Dragonstone.Registry.ViewRegistry.default_configuration();
		}
		this.parent_window = parent_window;
		loadUri(uri);
	}
	
	public void goToUri(string uri, bool is_absolute = false){
		if(locked>0){ return; }
		print(@"raw uri: $uri absolute: $is_absolute\n");
		if (uri == null){
			print("Potential ERROR: tab.goToUri called with a null uri!\n");
			return;
		}
		string uritogo = null;
		if (!is_absolute) {
			uritogo = Dragonstone.Util.Uri.join(_uri,uri);
		}
		if (uritogo == null){uritogo = uri;}
		print(@"Going to uri: $uritogo\n");
		//add to history
		history.push(_uri);
		forward.clear();
		loadUri(uritogo);
	}
	
	//this will overwrite the last uri in the tab history
	//handle with care!
	public void redirect(string uri){
		if(locked>0){ return; }
		var joined_uri = Dragonstone.Util.Uri.join(_uri,uri);
		if (joined_uri == null){joined_uri = uri;}
		loadUri(joined_uri);
	}
	
	private void loadUri(string uri,bool reload = false){
		if(locked>0){ return; }
		_uri = uri;
		if (request != null){
			if (request.resource != null){
				request.resource.decrement_users(resource_user_id);
			}
			request.notify["status"].disconnect(on_status_update);
		}
		setTitle(uri,true);
		request = new Dragonstone.Request(uri,"",reload);
		var rquri = this.uri;
		var startoffragment = rquri.index_of_char('#');
		if(startoffragment > 0){
			rquri = rquri.substring(0,startoffragment);
		}
		store.request(request);
		if (request != null){
			request.notify["status"].connect(on_status_update);
		}
		updateView();
		uriChanged(this.uri);
	}
	
	private void on_status_update(){
		if(locked>0){ return; }
		Timeout.add(0,() => {
			checkView();
			return false;
		},Priority.HIGH);
	}
	
	//check if the current view is still appropriate, and if not change it
	public void checkView(){
		if(locked>0){ return; }
		//print(@"check view -- $(request.status) -- $(request.substatus) --\n");
		if (!view.canHandleCurrentResource() ) {
			updateView();
		}
	}
	
	//update the view either beacause of a new Resource or beacause of a change of the current reource
	public void updateView(){
		if(locked>0){ return; }
		print(@"[tab] UPDATING view! [$(request.status)]\n");
		//remove the old view
		if (view != null){
			print("[tab] cleaning up old view\n");
			view.cleanup();
			remove(view);
		}
		view = view_registry.get_view(request.status);
		//choose a new one
		if (request.status == "success"){
			request.resource.increment_users(resource_user_id); //TODO: move somewhere else
			print(@"STATIC/DYNAMIC $(request.resource.mimetype)\n");
			setTitle(uri);
			if (prefer_source_view && source_view_registry != null){
				view = source_view_registry.get_view(request.status,request.resource.mimetype);
			}
			if (view == null){
				view = view_registry.get_view(request.status,request.resource.mimetype);
			}
		}else if(request.status == "loading" || request.status == "connecting" || request.status == "routing"){
			setTitle(uri,true);
			//view = new Dragonstone.View.Loading();
		}else if(request.status.has_prefix("redirect")){
			setTitle(uri);
			bool autoredirect = false;
			if (autoredirect){
				redirect(request.substatus);
			}
		} else {
			setTitle(uri);
		}
		if(request.status.has_prefix("error")){
			setTitle("🔴 "+uri);
		}
		if (view != null){
			if(view.displayResource(request,this)){
				add(view);
			} else {
				setTitle("🔴 "+uri);
				view = new Dragonstone.View.Label("I think i chose the wrong view ...\nPlease report this to the developer!"); //TOTRANSLATE
				add(view);
			}
		} else {
			setTitle("🔴 "+uri);
			view = new Dragonstone.View.Label(@"I'm sorry, but I don't know how to show that to you\nPlease report this to the developer if this is a release version (or you think this really shouldn't have happened)!\n$(request.status)\n$(request.substatus)"); //TOTRANSLATE
			add(view);
		}
		show_all();
	}
	
	public void set_tab_parent_window(Dragonstone.Window window){
		parent_window = window;
	}
	
	public void close(){
		cleanup();
		var window = (parent_window as Dragonstone.Window);
		if (window != null){
			window.close_tab(this);
		}
	}
	
	public void cleanup(){
		if(locked>0){ return; }
		locked++;
		if (view != null){
			print("[tab] cleaning up old view\n");
			view.cleanup();
			remove(view);
			view = null;
		}
		view = null;
		if (request != null){
			request.cancel();
			if (request.resource != null){
				request.resource.decrement_users(resource_user_id);
			}
			request.notify["status"].disconnect(on_status_update);
		}
		on_cleanup();
	}

	//backbutton handler
	public void goBack(){
		if(locked>0){ return; }
		if(!canGoBack()) return;
		var uri = history.pop();
		if (uri == null) { return; }
		forward.push(_uri);
		loadUri(uri);
	}
	
	//forwardbuttonhandler
	public void goForward(){
		if(locked>0){ return; }
		if(!canGoForward()) return;
		var uri = forward.pop();
		if (uri == null) { return; }
		history.push(_uri);
		loadUri(uri);
	}
	
	public bool canGoBack(){
		return history.size()>0;
	}
	
	public bool canGoForward(){
		return forward.size()>0;
	}
	
	//reloads the resource
	public void reload(){
		if(locked>0){ return; }
		string urix = uri; //setting a variable to itself the complicatd way
		print("reloading!\n");
		print("URI: '"+urix+"'\n");
		loadUri(urix,true);
	}
	
	public void open_uri_in_new_tab(string uri){
		var window = (parent_window as Dragonstone.Window);
		if (window != null){
			window.add_tab(uri);
		}
	}
	
	public void download(){
		if(locked>0){ return; }
		if (this.request.resource == null){
			print("Can't download an non existant resource!");
			return;
		}
		var filechooser = new Gtk.FileChooserNative(@"Download - $uri",parent_window,Gtk.FileChooserAction.SAVE,"Download","_Cancel"); //TOTRANSLATE
		filechooser.set_current_name(Dragonstone.Util.Uri.get_filename(uri));
		filechooser.set_current_folder(Environment.get_user_special_dir(UserDirectory.DOWNLOAD));
		filechooser.set_select_multiple(false);
		filechooser.run();
		if (filechooser.get_filename() != null) {
			var filepath = filechooser.get_filename();
			print(@"Download: $uri -> $filepath [Currently disabled]\n");
			Dragonstone.Downloader.save_resource.begin(this.request.resource,filepath,(obj, res) => {;});
		}
	}
	
	public void setTitle(string title,bool loading = false){
		this.title = title;
		this.loading = loading;
		this.on_title_change();
	}
	
}
