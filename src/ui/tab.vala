public class Dragontone.Ui.Tab : Object {
	
	private string _uri = "";
	private string _title = "";
	private Fossil.Ui.TabDisplayState _display_state = Fossil.Ui.TabDisplayState.BLANK;
	
	private bool redirecting = false;
	private uint64 redirectcounter = 0;
	private int locked = 0;
	
	private string resource_user_id = "tab_"+GLib.Uuid.string_random();
	
	private Fossil.Interface.Session session;
	//deprecated, will be changed to private as soon as all views support alternative apis
	public Fossil.Request? request;
	
	public signal void uri_changed(string uri);
	public signal void on_title_change(string title, Fossil.Ui.TabDisplayState state);
	
	
	public Tab(Fossil.Interface.Session session, string uri){
		this.session = session;
		this._uri = uri;
	}
	
	public string get_current_uri(){
		return _uri;
	}
	
	public string get_title(){
		return _title;
	}
	
	public Fossil.Ui.TabDisplayState get_display_state(){
		return _display_state;
	}
	
	public void set_title(string title, Fossil.Ui.TabDisplayState state = Fossil.Ui.TabDisplayState.CONTENT){
		_title = title;
		_display_state = state;
		on_title_change(_title,_display_state);
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
					print(@"[ui.tab] Error while reading file $(resource.filepath): $(e.message)");
				}
			}
		}
		return null;
	}
	
	public void go_to_uri(string uri, bool is_absolute = false){
		if(locked>0) { return; }
		print(@"[ui.tab] raw uri: $uri absolute: $is_absolute\n");
		if (uri == null) {
			print("[ui.tab] Potential ERROR: tab.go_to_uri called with a null uri!\n");
			return;
		}
		string uritogo = null;
		if (!is_absolute) {
			uritogo = Fossil.Util.Uri.join(_uri,uri);
		}
		if (uritogo == null) { uritogo = uri; }
		print(@"[ui.tab] Going to uri: $uritogo\n");
		//load new uri
		load_uri(uritogo);
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
	
	private void load_uri(string uri, bool reload = false){
		if(locked>0){ return; }
		_uri = uri;
		if (redirecting){
			redirecting = false;
			redirectcounter++;
		} else {
			redirectcounter = 0;
		}
		set_title(uri,Fossil.Ui.TabDisplayState.LOADING);
		var rquri = this._uri;
		var startoffragment = rquri.index_of_char('#');
		if(startoffragment > 0){
			rquri = rquri.substring(0,startoffragment);
		}
		var request = session.make_download_request(rquri,reload);
		set_request(request);
		uri_changed(this._uri);
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
	}
	
	private void on_status_update(Fossil.Request rq){
		print(@"[ui.tab] on status udate $(rq.status) | $(request.status) {$redirectcounter}\n");
		if(locked>0){ return; }
		if (request.resource != null){
			//only increments, if not already added
			request.resource.increment_users(resource_user_id);
		}
		if (request.status.has_prefix("redirect")){ //autoredirect on small changes
			if (request.substatus == this._uri+"/" || request.substatus == this._uri+"//" || request.substatus+"/" == this._uri){
				if(redirectcounter < 4){
					Timeout.add(0,() => {
						redirect(request.substatus);
						return false;
					},Priority.HIGH);
				}
			}
		}
	}
	
}
