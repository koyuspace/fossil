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
	private Gtk.Window parentWindow;
	private bool locked = false;
	//a label widget for adding to tabs in a notebook
	public string title = "New Tab";
	public bool loading = false; //changeing this counts as a title change
	public signal void on_cleanup();
	public signal void on_title_change();
	
	public Tab(Dragonstone.ResourceStore store, string uri, Gtk.Window parentWindow){
		Object(
			store: store
		);
		this.parentWindow = parentWindow;
		loadUri(uri);
	}
	
	public void goToUri(string uri){
		if(locked){ return; }
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
		if(locked){ return; }
		var joined_uri = Dragonstone.Util.Uri.join(_uri,uri);
		if (joined_uri == null){joined_uri = uri;}
		loadUri(joined_uri);
	}
	
	private void loadUri(string uri,bool reload = false){
		if(locked){ return; }
		_uri = uri;
		if (request != null){
			if (request.resource != null){
				request.resource.decrement_users();
			}
			request.notify["status"].disconnect(checkViewTimeoutHack);
		}
		setTitle("🔵 "+uri,true);
		request = new Dragonstone.Request(uri,"",reload);
		var rquri = this.uri;
		var startoffragment = rquri.index_of_char('#');
		if(startoffragment > 0){
			rquri = rquri.substring(0,startoffragment);
		}
		store.request(request);
		if (request != null){
			if (request.resource != null){
				request.resource.increment_users();
			}
			request.notify["status"].connect(checkViewTimeoutHack);
		}
		updateView();
		uriChanged(this.uri);
	}
	
	private void checkViewTimeoutHack(){
		if(locked){ return; }
		Timeout.add(0,() => {
			checkView();
			return false;
		},Priority.HIGH);
	}
	
	//check if the current view is still appropriate, and if not change it
	public void checkView(){
		if(locked){ return; }
		if (!view.canHandleCurrentResource()) {
			updateView();
		}
	}
	
	//update the view either beacause of a new Resource or beacause of a change of the current reource
	public void updateView(){ //TODO
		if(locked){ return; }
		print("UPDATING view!\n");
		//remove the old view
		if (view != null){
			view.cleanup();
			remove(view);
		}
		view = null;
		//choose a new one
		if (request.status == "success"){
			print(@"STATIC/DYNAMIC $(request.resource.mimetype)\n");
			setTitle(uri);
			if (request.resource.mimetype.has_prefix("text/gopher")){
				view = new Dragonstone.View.Gophertext();
			} else if (request.resource.mimetype.has_prefix("text/gemini")){
				view = new Dragonstone.View.Geminitext();
			} else if (request.resource.mimetype == "gemini/input"){
				view = new Dragonstone.View.GeminiInput();
			} else if (request.resource.mimetype.has_prefix("text/")){ //TODO: Mimetype view registry
				view = new Dragonstone.View.Plaintext();
			}	else if (request.resource.mimetype.has_prefix("image/")){
				view = new Dragonstone.View.Image();
			}	else {
				//show download view
			}
		}else if(request.status == "loading" || request.status == "connecting"){
			setTitle("🔵 "+uri,true);
			view = new Dragonstone.View.Loading();
		}else if(request.status.has_prefix("redirect")){
			setTitle(uri);
			bool autoredirect = false;
			if (autoredirect){
				redirect(request.substatus);
			} else {
				view = new Dragonstone.View.Redirect();
			}
		}else if(request.status == "error/internal"){
			view = new Dragonstone.View.InternalError();
		}else if(request.status == "error/gibberish"){
			view = new Dragonstone.View.Gibberish();
		}else if(request.status == "error/connectionRefused"){
			view = new Dragonstone.View.ConnectionRefused();
		}else if(request.status == "error/noHost"){
			view = new Dragonstone.View.HostUnreachable();
		}else if(request.status == "error/resourceUnavaiable"){
			view = new Dragonstone.View.Unavaiable();
		//}else if(request.status.has_prefix("error/uri")){
		//	view = new Dragonstone.View.UriError.Generic();
		}else if(request.status.has_prefix("error")){
			view = new Dragonstone.View.Error.Generic();
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
	
	public void close(){
		cleanup();
		if (parentWindow is Dragonstone.Window){
			(parentWindow as Dragonstone.Window).close_tab(this);
		}
	}
	
	public void cleanup(){
		if(locked){ return; }
		locked = true;
		if (view != null){
			view.cleanup();
			remove(view);
			view = null;
		}
		view = null;
		if (request != null){
			if (request.resource != null){
				request.resource.decrement_users();
			}
			request.notify["status"].disconnect(checkViewTimeoutHack);
		}
		on_cleanup();
	}

	//backbutton handler
	public void goBack(){
		if(locked){ return; }
		if(!canGoBack()) return;
		var uri = history.pop();
		if (uri == null) { return; }
		forward.push(_uri);
		loadUri(uri);
	}
	
	//forwardbuttonhandler
	public void goForward(){
		if(locked){ return; }
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
		if(locked){ return; }
		string urix = uri; //setting a variable to itself the complicatd way
		print("reloading!\n");
		print("URI: '"+urix+"'\n");
		loadUri(urix);
	}
	
	public void download(){
		if(locked){ return; }
		if (this.request.resource == null){
			print("Can't download an non existant resource!");
			return;
		}
		var filechooser = new Gtk.FileChooserNative(@"Download - $uri",parentWindow,Gtk.FileChooserAction.SAVE,"Download","_Cancel"); //TOTRANSLATE
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
