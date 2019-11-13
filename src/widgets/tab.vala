public class Dragonstone.Tab : Gtk.Bin {
	private string _uri = "";
	public string uri {
		get { return _uri; }
		set { 
			goToUri(value);
		}}
	public Dragonstone.IView view;
	public Dragonstone.Resource resource;
	public Dragonstone.ResourceStore store { get; set; }
	private Dragonstone.SessionInformation? session = null;
	public signal void uriChanged(string uri);
	public Dragonstone.Util.Stack<string> history = new Dragonstone.Util.Stack<string>();
	public Dragonstone.Util.Stack<string> forward = new Dragonstone.Util.Stack<string>();
	private Gtk.Window parentWindow;
	
	public Tab(Dragonstone.ResourceStore store, string uri, Gtk.Window parentWindow){
		Object(
			store: store
		);
		this.parentWindow = parentWindow;
		loadUri(uri);
	}
	
	public void goToUri(string uri){
		print(@"raw uri: $uri\n");
		if (uri == null){
			print("Potential ERROR: tab.goToUri called with a null uri!\n");
			return;
		}
		var uritogo = Dragonstone.Util.Uri.join(_uri,uri);
		if (uritogo == null){uritogo = uri;}
		print(@"Going to uri: $uritogo\n");
		//add to history
		history.push(_uri);
		forward.clear();
		loadUri(uritogo);
		print(@"$uri\n");
	}
	
	//this will overwrite the last uri in the tab history
	//handle with care!
	public void redirect(string uri){
		var joined_uri = Dragonstone.Util.Uri.join(_uri,uri);
		if (joined_uri == null){joined_uri = uri;}
		loadUri(joined_uri);
	}
	
	private void loadUri(string uri){
		_uri = uri;
		if (resource != null){ resource.notify["resourcetype"].disconnect(checkViewTimeoutHack); }
		var rquri = this.uri;
		var startoffragment = rquri.index_of_char('#');
		if(startoffragment > 0){
			rquri = rquri.substring(0,startoffragment);
		}
		resource = store.request(rquri,session);
		if (resource != null){ resource.notify["resourcetype"].connect(checkViewTimeoutHack); }
		updateView();
		uriChanged(this.uri);
	}
	
	private void checkViewTimeoutHack(){
		Timeout.add(0,() => {
			checkView();
			return false;
		},Priority.HIGH);
	}
	
	//check if the current view is still appropriate, and if not change it
	public void checkView(){
		if (!view.canHandleCurrentResource()) {
			updateView();
		}
	}	
	
	//update the view either beacause of a new Resource or beacause of a change of the current reource
	public void updateView(){ //TODO
		print("UPDATING view!\n");
		//remove the old view
		if (view != null){
			remove(view);
		}
		view = null;
		//choose a new one
		if (resource.resourcetype == Dragonstone.ResourceType.STATIC ||
			resource.resourcetype == Dragonstone.ResourceType.DYNAMIC){
			print(@"STATIC/DYNAMIC $(resource.subtype)\n");
			if (resource.subtype.has_prefix("text/gopher")){
				view = new Dragonstone.View.Gophertext();
			} else if (resource.subtype.has_prefix("text/gemini")){
				view = new Dragonstone.View.Geminitext();
			} else if (resource.subtype == "gemini/input"){
				view = new Dragonstone.View.GeminiInput();
			} else if (resource.subtype.has_prefix("text/")){ //TODO: Mimetype view registry
				view = new Dragonstone.View.Plaintext();
			}	else if (resource.subtype.has_prefix("image/")){
				view = new Dragonstone.View.Image();
			}	else {
				//show download view
			}
		}else if(resource.resourcetype == Dragonstone.ResourceType.LOADING){
			view = new Dragonstone.View.Loading();
		}else if(resource.resourcetype == Dragonstone.ResourceType.INTERACTIVE){
			
		}else if(resource.resourcetype == Dragonstone.ResourceType.REDIRECT){
			bool autoredirect = false;
			if (autoredirect){
				redirect(resource.subtype);
			} else {
				view = new Dragonstone.View.Redirect();
			}
		}else if(resource.resourcetype == Dragonstone.ResourceType.ERROR){
			//generic error ppage +registry for specific errors (indexed by subtype)
			//known subtypes: gopher
			view = new Dragonstone.View.Error.Generic();
		}else if(resource.resourcetype == Dragonstone.ResourceType.ERROR_INTERNAL){
			view = new Dragonstone.View.InternalError();
		}else if(resource.resourcetype == Dragonstone.ResourceType.ERROR_GIBBERISH){
			view = new Dragonstone.View.Gibberish();
		}else if(resource.resourcetype == Dragonstone.ResourceType.ERROR_CONNECTION_REFUSED){
			view = new Dragonstone.View.ConnectionRefused();
		}else if(resource.resourcetype == Dragonstone.ResourceType.ERROR_NO_HOST){
			view = new Dragonstone.View.HostUnreachable();
		}else if(resource.resourcetype == Dragonstone.ResourceType.ERROR_TEMPORARILY_UNAVAIABLE){
			view = new Dragonstone.View.Unavaiable();
		}else if(resource.resourcetype == Dragonstone.ResourceType.ERROR_UNAVAIABLE){
			view = new Dragonstone.View.Unavaiable();
		}else if(resource.resourcetype == Dragonstone.ResourceType.ERROR_OFFLINE){
			view = new Dragonstone.View.Offline();
		}else if(resource.resourcetype == Dragonstone.ResourceType.ERROR_URI_SCHEME_NOT_SUPPORTED){
			view = new Dragonstone.View.UriError.Generic();
		}
		if (view != null){
			if(view.displayResource(resource,this)){
				add(view);
			} else {
				view = new Dragonstone.View.Label("I think i chose the wrong view ...\nPlease report this to the developer!"); //TOTRANSLATE
				add(view);
			}
		} else {
			view = new Dragonstone.View.Label(@"I'm sorry, but I don't know how to show that to you\nPlease report this to the developer if this is a release version (or you think this really shouldn't have happened)!\n$(resource.name)\n$(resource.subtype)"); //TOTRANSLATE
			add(view);
		}
		show_all();
	}


	//backbutton handler
	public void goBack(){
		if(!canGoBack()) return;
		var uri = history.pop();
		if (uri == null) { return; }
		forward.push(_uri);
		loadUri(uri);
	}
	
	//forwardbuttonhandler
	public void goForward(){
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
		print("reloading!\n");
		store.reload(uri,session);
		print("URI:"+uri+"\n");
		loadUri(uri);
	}
	
	public void download(){
		var filechooser = new Gtk.FileChooserNative(@"Download - $uri",parentWindow,Gtk.FileChooserAction.SAVE,"Download","_Cancel"); //TOTRANSLATE
		filechooser.set_select_multiple(false);
		filechooser.run();
		if (filechooser.get_filename() != null) {
			var filepath = filechooser.get_filename();
			print(@"Download: $uri -> $filepath\n");
			Dragonstone.Downloader.save_resource.begin(this.resource,filepath,(obj, res) => {;});
		}
	}
	
}
