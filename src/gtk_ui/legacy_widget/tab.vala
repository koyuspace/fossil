public class Fossil.GtkUi.LegacyWidget.Tab : Gtk.Bin, Fossil.Interface.Page.Service.LinearHistory {
	private string _uri = "";
	public string uri {
		get { return _uri; }
		set { 
			go_to_uri(value);
		}}
	public Fossil.GtkUi.Interface.LegacyView view;
	public Fossil.Request request;
	public Fossil.Registry.SessionRegistry session_registry { get; set; }
	public Fossil.Interface.Session session { get; protected set; }
	public string current_session_id { get; protected set; }
	public signal void on_session_change();	
	public signal void uri_changed(string uri);
	public Fossil.Util.Stack<TabHistoryEntry> history = new Fossil.Util.Stack<TabHistoryEntry>();
	public Fossil.Util.Stack<TabHistoryEntry> forward = new Fossil.Util.Stack<TabHistoryEntry>();
	public Fossil.GtkUi.LegacyWidget.TabHistoryEntry currently_displayed_page = new Fossil.GtkUi.LegacyWidget.TabHistoryEntry();
	public Fossil.SuperRegistry super_registry { get; construct; }
	public Fossil.Registry.TranslationRegistry translation;
	public Gtk.Window parent_window; //only for use with dialog windows
	private int locked = 0;
	public string title = "New Tab";
	public Fossil.Ui.TabDisplayState display_state = Fossil.Ui.TabDisplayState.BLANK;
	public Fossil.Util.Flaglist view_flags = new Fossil.Util.Flaglist();
	public Fossil.GtkUi.LegacyViewRegistryViewChooser view_chooser;
	public signal void on_cleanup();
	public signal void on_title_change(string title, Fossil.Ui.TabDisplayState state);
	public string current_view_id { get; protected set; }
	public signal void on_view_change();
	
	private bool redirecting = false;
	public uint redirectcounter = 0;
	
	private string resource_user_id = "tab_"+GLib.Uuid.string_random();
	
	private Fossil.GtkUi.LegacyViewRegistry view_registry;
	
	public Tab(string session_id, string uri, Gtk.Window parent_window, Fossil.SuperRegistry super_registry){
		Object(
			//store: store,
			super_registry: super_registry
		);
		this.current_view_id = "";
		this.current_session_id = session_id;
		this.session_registry = (super_registry.retrieve("core.sessions") as Fossil.Registry.SessionRegistry);
		if (this.session_registry == null){
			print("[tab][error]No sessionregistry found in spplyed superregistry, falling back to an empty one\n");
			this.session_registry = new Fossil.Registry.SessionRegistry();
		}
		this.session = this.session_registry.get_session_by_id(session_id);
		if (this.session == null){
			print("[tab][error]Session not found in session registry, falling back to dummy session");
			this.session = new Fossil.Session.Dummy();
		}
		this.view_registry = (super_registry.retrieve("gtk.views") as Fossil.GtkUi.LegacyViewRegistry);
		if (this.view_registry == null){
			print("[tab] No view registry in super registry, falling back to default configuration!\n");
			this.view_registry = new Fossil.GtkUi.LegacyViewRegistry.default_configuration();
		}
		view_chooser = new Fossil.GtkUi.LegacyViewRegistryViewChooser(view_registry);
		this.translation = (super_registry.retrieve("localization.translation") as Fossil.Registry.TranslationRegistry);
		if (this.translation == null){
			print("[tab] No translation resgistry found, falling back to an empty one!\n");
			this.translation = new Fossil.Registry.TranslationLanguageRegistry();
		}
		this.parent_window = parent_window;
		load_uri(uri);
	}
	
	public FileInputStream? get_file_content_stream(){
		var request = this.request;
		if (request != null) {
			var resource = request.resource;
			if (resource != null) {
				var file = File.new_for_path(resource.filepath);
				try {
				return file.read();
				} catch (Error e){
					print(@"[gtk_ui.tab] Error while reading file $(resource.filepath): $(e.message)");
				}
			}
		}
		return null;
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
			uritogo = Fossil.Util.Uri.join(_uri,uri);
		}
		if (uritogo == null){uritogo = uri;}
		print(@"Going to uri: $uritogo\n");
		//add old page to history
		push_history();
		//load new uri
		load_uri(uritogo);
	}
	
	public string? upload_to_uri(string uri,Fossil.Resource upload_resource){
		if(locked>0){ return null; }
		//add to history
		push_history();
		_uri = uri;
		currently_displayed_page.upload = true;
		currently_displayed_page.uploaded_to = uri;
		string upload_urn;
		var request = session.make_upload_request(uri, upload_resource, out upload_urn);
		set_request(request);
		currently_displayed_page.uri = upload_urn;
		_uri = upload_urn;
		uri_changed(this.uri);
		update_view(null,"upload_to_uri",true);
		return upload_urn;
	}
	
	//this will overwrite the last uri in the tab history
	//handle with care!
	public void redirect(string uri){
		if(locked>0){ return; }
		var joined_uri = Fossil.Util.Uri.join(_uri,uri);
		if (joined_uri == null){joined_uri = uri;}
		redirecting = true;
		load_uri(joined_uri);
	}
	
	private void load_uri(string uri, bool reload = false, string? preferred_view = null){
		if(locked>0){ return; }
		_uri = uri;
		currently_displayed_page.uri = uri;
		if (redirecting){
			redirecting = false;
			redirectcounter++;
		} else {
			redirectcounter = 0;
		}
		set_title(uri ,Fossil.Ui.TabDisplayState.LOADING);
		var rquri = this.uri;
		var startoffragment = rquri.index_of_char('#');
		if(startoffragment > 0){
			rquri = rquri.substring(0,startoffragment);
		}
		var request = session.make_download_request(rquri,reload);
		set_request(request);
		update_view(preferred_view,"load_uri",true);
		uri_changed(this.uri);
	}
	
	private void set_request(Fossil.Request? rq){
		if (request != null){
			if (request.resource != null){
				request.resource.decrement_users(resource_user_id);
			}
			request.status_changed.disconnect(on_status_update);
			if (!request.done){
				request.finished.disconnect(on_request_finished);
				request.cancel();
			}
		}
		request = rq;
		if (request != null){
			request.status_changed.connect(on_status_update);
			request.finished.connect(on_request_finished);
		}
	}
	
	private void on_request_finished(Fossil.Request request){
		Timeout.add(0,() => {
			print("[tab][debug] on_request_finished()\n");
			check_view(true);
			return false;
		},Priority.HIGH);
	}
	
	private void on_status_update(Fossil.Request rq){
		print(@"[tab] on status udate $(rq.status) | $(request.status) {$redirectcounter}\n");
		if(locked>0){ return; }
		if (request.resource != null){
			//only increments, if not already added
			request.resource.increment_users(resource_user_id);
		}
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
			check_view(false);
			return false;
		},Priority.HIGH);
	}
	
	//check if the current view is still appropriate, and if not change it
	public void check_view(bool finished){
		if(locked>0){ return; }
		print(@"[tab] check view -- $(request.status) -- $(request.substatus) -- f: $finished\n");
		if (finished){
			//test for errors and warnings
			bool has_warnings = false;
			bool has_errors = false;
			if (request.done){
				foreach (string key in request.arguments.get_keys()){
					has_warnings = has_warnings || key.has_prefix("warning");
					has_errors = has_errors || key.has_prefix("error");
				}
			}
			if (has_errors){
				print("[tab] open error dialog\n");
				open_subview("dragonstone.error");
				return;
			}
		}
		if (!view.canHandleCurrentResource() ) {
			update_view(null,"check_view");
		}
	}
	
	public void export_view_data(){
		if (view != null){
			currently_displayed_page.persistance_values.set(this.current_view_id,view.export());
			print(@"exported view data to $current_view_id\n");
		}
	}
	
	private void push_history(){
		export_view_data();
		history.push(currently_displayed_page);
		currently_displayed_page = new Fossil.GtkUi.LegacyWidget.TabHistoryEntry();
		forward.clear();
	}
	
	//update the view either beacause of a new Resource or beacause of a change of the current reource
	//or update the view with a chosen one
	public void update_view(string? view_id = null, string reason = "", bool update_view_chooser = false, bool as_subview = false){
		if(locked>1){ return; }
		update_view_chooser = update_view_chooser || (view_id == null);
		lock(current_view_id){
			bool currently_displayed_is_subview = currently_displayed_page.currently_displayed_subview != null;
			bool do_update_view = currently_displayed_is_subview == as_subview;
			print(@"[tab] UPDATING view! [$(request.status)] ($reason)\n");
			Fossil.GtkUi.Interface.LegacyView view;
			if (update_view_chooser){
				string? mimetype = null;
				if(request.resource != null){
					mimetype = request.resource.mimetype;
				}
				view_chooser.choose(request.status,mimetype,uri,view_flags.flags);
			}
			if (!as_subview){
				currently_displayed_page.view = view_id; //null if automatic view determination
			}
			
			//do some status specific things
			Fossil.Ui.TabDisplayState new_state = Fossil.Ui.TabDisplayState.LOADING;
			if (request.done) {
				new_state = Fossil.Ui.TabDisplayState.CONTENT;
			}
			if (uri == "about:blank") {
				new_state = Fossil.Ui.TabDisplayState.BLANK;
			}
			if (request.status.has_prefix("error")) {
				new_state = Fossil.Ui.TabDisplayState.ERROR;
			}
			set_title(uri,new_state);
			if (do_update_view) {
				if (view_id == null) {
					//view = view_registry.get_view(view_chooser.best_match);
					current_view_id = view_chooser.best_match;
				} else {
					current_view_id = view_id;
				}
					view = view_registry.get_view(current_view_id);
				if (view != null){
					if(view.display_resource(request, this, as_subview)) {
						print(@"Trying to import view data $current_view_id\n");
						string? data = currently_displayed_page.persistance_values.get(current_view_id);
						if (data != null){
							view.import(data);
						} else {
						
						}
						use_view(view);
					} else {
						if (view_id != null) {
							print(@"[tab] manually chosen view '$current_view_id' cannot handle the resource!\n");
							update_view(null,"view_did_not_work");
							return;
						} else {
							set_title(uri,Fossil.Ui.TabDisplayState.ERROR);
							var error_message_localized = translation.get_localized_string("tab.error.wrong_view.message");
							view = new Fossil.GtkUi.View.Message("-", error_message_localized, @"$(request.status)\n$(request.substatus)");
							use_view(view);
						}
					}
				} else {
					set_title(uri,Fossil.Ui.TabDisplayState.ERROR);
					var error_message_localized = translation.get_localized_string("tab.error.no_view.message");
					view = new Fossil.GtkUi.View.Message("-", error_message_localized, @"$(request.status)\n$(request.substatus)");
					use_view(view);
				}
				show();
				this.on_view_change();
			}
		}
	}
	
	private void use_view(owned Fossil.GtkUi.Interface.LegacyView new_view){
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
	
	public void open_subview(string view_id){
		if (currently_displayed_page.currently_displayed_subview != null){
			if(currently_displayed_page.currently_displayed_subview.view == view_id){
				return;
			}
			currently_displayed_page.subview_history.push(currently_displayed_page.currently_displayed_subview);
		}	
		currently_displayed_page.currently_displayed_subview = new TabSubviewHistoryEntry();
		currently_displayed_page.currently_displayed_subview.view = view_id;
		update_view(view_id,"open_subview",false,true);
	}
	
	public void go_back_subview(){
		currently_displayed_page.currently_displayed_subview = currently_displayed_page.subview_history.pop();
		apply_tab_history_entry(null);
	}
	
	public void set_tab_parent_window(Fossil.Window window){
		parent_window = window;
	}
	
	public bool set_tab_session(string session_id){
		if(locked>0){ return false; }
		var session = session_registry.get_session_by_id(session_id);
		if (session == null) { return false; }
		print(@"[tab] using session $session_id\n");
		this.current_session_id = session_id;
		this.session = session;
		//reload from cache
		string urix = uri;
		load_uri(urix);
		return true;
	}
	
	public void close(){
		cleanup();
		var window = (parent_window as Fossil.Window);
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
		var entry = history.pop();
		if (entry == null) { return; }
		export_view_data();
		forward.push(currently_displayed_page);
		apply_tab_history_entry(entry);
	}
	
	//forwardbuttonhandler
	public void go_forward(){
		if(locked>0){ return; }
		if(!can_go_forward()) return;
		var entry = forward.pop();
		if (entry == null) { return; }
		export_view_data();
		history.push(currently_displayed_page);
		apply_tab_history_entry(entry);
	}
	
	public void apply_tab_history_entry(Fossil.GtkUi.LegacyWidget.TabHistoryEntry? entry){
		if (entry != null){
			currently_displayed_page = entry;
			load_uri(currently_displayed_page.uri,false,entry.view);
			if (currently_displayed_page.currently_displayed_subview != null){
				update_view(currently_displayed_page.currently_displayed_subview.view,"apply_tab_history_entry_subview",false,true);
			}
		} else {
			if (currently_displayed_page.currently_displayed_subview != null){
				update_view(currently_displayed_page.currently_displayed_subview.view,"apply_tab_history_entry_subview",false,true);
			} else {
				update_view(currently_displayed_page.view,"apply_tab_history_entry",false,false);
			}
		}
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
		export_view_data();
		load_uri(urix,true);
	}
	
	public void open_uri_in_new_tab(string uri, bool is_absolute = false){
		var window = (parent_window as Fossil.Window);
		if (window != null){
			string uritogo = uri;
			if (!is_absolute) {
				uritogo = Fossil.Util.Uri.join(_uri,uri);
			}
			window.add_tab(uritogo,this.current_session_id);
		}
	}
	
	public void open_uri_externally(string? uri = null){
		if(uri == null){
			Fossil.External.open_uri(this.uri);
		} else {
			Fossil.External.open_uri(uri);
		}
	}
	
	public void open_resource_externally(){
		if (this.request != null){
			if (this.request.resource != null){
				if (this.request.resource.filepath != null){
					Fossil.External.open_uri(this.request.resource.filepath);
				}
			}
		}
	}
	
	public void download(){
		if(locked>0){ return; }
		if (this.request.resource == null){
			print("[tab][error] Can't download an non existant resource!");
			return;
		}
		var download_localized = translation.get_localized_string("action.download");
		var filechooser = new Gtk.FileChooserNative(@"$download_localized - $uri",parent_window,Gtk.FileChooserAction.SAVE,download_localized,translation.get_localized_string("action.cancel"));
		filechooser.set_current_name(Fossil.Util.Uri.get_filename(uri));
		filechooser.set_current_folder(Environment.get_user_special_dir(UserDirectory.DOWNLOAD));
		filechooser.set_select_multiple(false);
		filechooser.run();
		if (filechooser.get_filename() != null) {
			var filepath = filechooser.get_filename();
			print(@"[tab] Download: $uri ($(request.resource.filepath)) -> $filepath\n");
			Fossil.Downloader.save_resource.begin(this.request.resource,filepath,(obj, res) => {;});
		}
	}
	
	public void set_title(string title, Fossil.Ui.TabDisplayState state = Fossil.Ui.TabDisplayState.CONTENT){
		this.title = title;
		this.display_state = state;
		on_title_change(title,display_state);
	}
	
}

public class Fossil.GtkUi.LegacyWidget.TabHistoryEntry : Object {
	public string uri = "";
	public string? view = null;
	//subview history
	public Fossil.Util.Stack<TabSubviewHistoryEntry> subview_history = new Fossil.Util.Stack<TabSubviewHistoryEntry>();
	public TabSubviewHistoryEntry? currently_displayed_subview = null;
	//upload_information
	public bool upload = false;
	public string? uploaded_to = null;
	//persistance data
	public HashTable<string,string> persistance_values;
	
	construct {
		this.persistance_values = new HashTable<string,string>(str_hash,str_equal);
	}
}

public class Fossil.GtkUi.LegacyWidget.TabSubviewHistoryEntry : Object {
	public string view;
}
