public class Dragonstone.Tab : Gtk.Bin {
	private string _uri = "";
	public string uri {
		get { return _uri; }
		set { 
			go_to_uri(value);
		}}
	public Dragonstone.IView view;
	public Dragonstone.Request request;
	public Dragonstone.Registry.SessionRegistry session_registry { get; set; }
	public Dragonstone.ISession session { get; protected set; }
	public string current_session_id { get; protected set; }
	public signal void on_session_change();	
	public signal void uriChanged(string uri);
	public Dragonstone.Util.Stack<string> history = new Dragonstone.Util.Stack<string>();
	public Dragonstone.Util.Stack<string> forward = new Dragonstone.Util.Stack<string>();
	public Dragonstone.SuperRegistry super_registry { get; construct; }
	public Dragonstone.Registry.TranslationRegistry translation;
	private Gtk.Window parent_window;
	private int locked = 0;
	public string title = "New Tab";
	public bool loading = false; //changing this counts as a title change
	public Dragonstone.Util.Flaglist view_flags = new Dragonstone.Util.Flaglist();
	public Dragonstone.Registry.ViewRegistryViewChooser view_chooser;
	public signal void on_cleanup();
	public signal void on_title_change();
	public string current_view_id { get; protected set; }
	public signal void on_view_change();
	
	private bool redirecting = false;
	private uint64 redirectcounter = 0;
	
	private string resource_user_id = "tab_"+GLib.Uuid.string_random();
	
	private Dragonstone.Registry.ViewRegistry view_registry;
	
	public Tab(string session_id, string uri, Gtk.Window parent_window, Dragonstone.SuperRegistry super_registry){
		Object(
			//store: store,
			super_registry: super_registry
		);
		this.current_view_id = "";
		this.current_session_id = session_id;
		this.session_registry = (super_registry.retrieve("core.sessions") as Dragonstone.Registry.SessionRegistry);
		if (this.session_registry == null){
			print("[tab][error]No sessionregistry found in spplyed superregistry, falling back to an empty one\n");
			this.session_registry = new Dragonstone.Registry.SessionRegistry();
		}
		this.session = this.session_registry.get_session_by_id(session_id);
		if (this.session == null){
			print("[tab][error]Session not found in session registry, falling back to dummy session");
			this.session = new Dragonstone.Session.Dummy();
		}
		this.view_registry = (super_registry.retrieve("gtk.views") as Dragonstone.Registry.ViewRegistry);
		if (this.view_registry == null){
			print("[tab] No view registry in super registry, falling back to default configuration!\n");
			this.view_registry = new Dragonstone.Registry.ViewRegistry.default_configuration();
		}
		view_chooser = new Dragonstone.Registry.ViewRegistryViewChooser(view_registry);
		this.translation = (super_registry.retrieve("localization.translation") as Dragonstone.Registry.TranslationRegistry);
		if (this.translation == null){
			print("[tab] No translation resgistry found, falling back to an empty one!\n");
			this.translation = new Dragonstone.Registry.TranslationLanguageRegistry();
		}
		this.parent_window = parent_window;
		load_uri(uri);
	}
	
	public void go_to_uri(string uri, bool is_absolute = false){
		if(locked>0){ return; }
		print(@"raw uri: $uri absolute: $is_absolute\n");
		if (uri == null){
			print("Potential ERROR: tab.go_to_uri called with a null uri!\n");
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
		load_uri(uritogo);
	}
	
	//this will overwrite the last uri in the tab history
	//handle with care!
	public void redirect(string uri){
		if(locked>0){ return; }
		var joined_uri = Dragonstone.Util.Uri.join(_uri,uri);
		if (joined_uri == null){joined_uri = uri;}
		redirecting = true;
		load_uri(joined_uri);
	}
	
	private void load_uri(string uri,bool reload = false){
		if(locked>0){ return; }
		_uri = uri;
		if (request != null){
			if (request.resource != null){
				request.resource.decrement_users(resource_user_id);
			}
			request.status_changed.disconnect(on_status_update);
		}
		if (redirecting){
			redirecting = false;
			redirectcounter++;
		} else {
			redirectcounter = 0;
		}
		setTitle(uri,true);
		var rquri = this.uri;
		var startoffragment = rquri.index_of_char('#');
		if(startoffragment > 0){
			rquri = rquri.substring(0,startoffragment);
		}
		request = session.make_request(rquri,reload);
		if (request != null){
			request.status_changed.connect(on_status_update);
		}
		update_view(null,"load_uri");
		uriChanged(this.uri);
	}
	
	private void on_status_update(Dragonstone.Request rq){
		print(@"[tab] on status udate $(rq.status) | $(request.status) {$redirectcounter}\n");
		if(locked>0){ return; }
		if (request.status.has_prefix("redirect")){ //autoredirect on small changes
			if (request.substatus == this.uri+"/" || request.substatus == this.uri+"//" || request.substatus+"/" == this.uri){
				if(redirectcounter < 4){
					Timeout.add(0,() => {
						redirect(request.substatus);
						return false;
					},Priority.HIGH);
				}
			}
		}
		Timeout.add(0,() => {
			check_view();
			return false;
		},Priority.HIGH);
	}
	
	//check if the current view is still appropriate, and if not change it
	public void check_view(){
		if(locked>0){ return; }
		print(@"check view -- $(request.status) -- $(request.substatus) --\n");
		if (!view.canHandleCurrentResource() ) {
			update_view(null,"check_view");
		}
	}
	
	//update the view either beacause of a new Resource or beacause of a change of the current reource
	//or update the view with a chosen one
	public void update_view(string? view_id = null,string reason = ""){
		if(locked>1){ return; }
		lock(current_view_id){
			print(@"[tab] UPDATING view! [$(request.status)] ($reason)\n");
			Dragonstone.IView view;
			if (view_id == null) {
				string? mimetype = null;
				if(request.resource != null){
					mimetype = request.resource.mimetype;
				}
				view_chooser.choose(request.status,mimetype,uri,view_flags.flags);
				view = view_registry.get_view(view_chooser.best_match);
				current_view_id = view_chooser.best_match;
			} else {
				view = view_registry.get_view(view_id);
				current_view_id = view_id;
			}
			//choose a new one
			if (request.status == "success"){
				request.resource.increment_users(resource_user_id); //TODO: move somewhere else
				setTitle(uri);
			}else if(request.status == "loading" || request.status == "connecting" || request.status == "routing"){
				setTitle(uri,true);
			}else if(request.status.has_prefix("redirect")){
				setTitle(uri);
				bool autoredirect = false;
				if (autoredirect){
					Timeout.add(0,() => {
						redirect(request.substatus);
						return false;
					},Priority.HIGH);
				}
			} else {
				setTitle(uri);
			}
			if(request.status.has_prefix("error")){
				setTitle("🔴 "+uri);
			}
			if (view != null){
				if(view.displayResource(request,this)){
					use_view(view);
				} else {
					setTitle("🔴 "+uri);
					var error_message_localized = translation.get_localized_string("tab.error.wrong_view.message");
					view = new Dragonstone.View.Label(@"$error_message_localized\n$(request.status)\n$(request.substatus)");
					use_view(view);
				}
			} else {
				setTitle("🔴 "+uri);
				var error_message_localized = translation.get_localized_string("tab.error.no_view.message");
				view = new Dragonstone.View.Label(@"$error_message_localized\n$(request.status)\n$(request.substatus)");
				use_view(view);
			}
			show();
			this.on_view_change();
		}
	}
	
	private void use_view(owned Dragonstone.IView new_view){
		lock(this.view){
			//remove the old view
			if (this.view is Gtk.Widget){
				print("[tab] cleaning up old view\n");
				this.view.cleanup();
				remove(this.view);
			}
			this.view = (owned) new_view;
			add(this.view);
		}
	}
	
	public void set_tab_parent_window(Dragonstone.Window window){
		parent_window = window;
	}
	
	public bool set_tab_session(string session_id){
		var session = session_registry.get_session_by_id(session_id);
		if (session == null) { return false; }
		print(@"[tab] using session $session_id\n");
		this.current_session_id = session_id;
		this.session = session;
		reload();
		return true;
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
			print("[tab] cleaning up old view - cleanup()\n");
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
			request.status_changed.disconnect(on_status_update);
		}
		on_cleanup();
	}

	//backbutton handler
	public void go_back(){
		if(locked>0){ return; }
		if(!can_go_back()) return;
		var uri = history.pop();
		if (uri == null) { return; }
		forward.push(_uri);
		load_uri(uri);
	}
	
	//forwardbuttonhandler
	public void go_forward(){
		if(locked>0){ return; }
		if(!can_go_forward()) return;
		var uri = forward.pop();
		if (uri == null) { return; }
		history.push(_uri);
		load_uri(uri);
	}
	
	public bool can_go_back(){
		return history.size()>0;
	}
	
	public bool can_go_forward(){
		return forward.size()>0;
	}
	
	//reloads the resource
	public void reload(){
		if(locked>0){ return; }
		string urix = uri; //setting a variable to itself the complicatd way
		print("reloading!\n");
		print("URI: '"+urix+"'\n");
		load_uri(urix,true);
	}
	
	public void open_uri_in_new_tab(string uri, bool is_absolute = false){
		var window = (parent_window as Dragonstone.Window);
		if (window != null){
			string uritogo = uri;
			if (!is_absolute) {
				uritogo = Dragonstone.Util.Uri.join(_uri,uri);
			}
			window.add_tab(uritogo,this.current_session_id);
		}
	}
	
	public void open_uri_externally(string? uri = null){
		if(uri == null){
			Dragonstone.External.open_uri(this.uri);
		} else {
			Dragonstone.External.open_uri(uri);
		}
	}
	
	public void open_resource_externally(){
		if (this.request != null){
			if (this.request.resource != null){
				if (this.request.resource.filepath != null){
					Dragonstone.External.open_uri(this.request.resource.filepath);
				}
			}
		}
	}
	
	public void download(){
		if(locked>0){ return; }
		if (this.request.resource == null){
			print("Can't download an non existant resource!");
			return;
		}
		var download_localized = translation.get_localized_string("action.download");
		var filechooser = new Gtk.FileChooserNative(@"$download_localized - $uri",parent_window,Gtk.FileChooserAction.SAVE,download_localized,translation.get_localized_string("action.cancel")); //TOTRANSLATE
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
