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
	
	public Tab(Dragonstone.ResourceStore store, string uri){
		Object(
			store: store
		);
		loadUri(uri);
	}
	
	public void goToUri(string uri){
		print(@"Going to uri: $uri\n");
		//add to history
		history.push(_uri);
		forward.clear();
		loadUri(uri);
	}
	
	private void loadUri(string uri){
		_uri = uri;
		if (resource != null){ resource.notify["resourcetype"].disconnect(checkViewTimeoutHack); }
		resource = store.request(this.uri,session);
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
			//TODO: interactive view registry
			if(resource.subtype == "gopher.search"){
				print("INTERACTIVE: gopher.search // TODO\n");
			} 
			
		}else if(resource.resourcetype == Dragonstone.ResourceType.REDIRECT){
		
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
}
