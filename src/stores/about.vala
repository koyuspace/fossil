public class Fossil.Store.About : Object, Fossil.Interface.ResourceStore {
	
	private HashTable<string,Fossil.Interface.ResourceStore> substores = new HashTable<string,Fossil.Interface.ResourceStore>(str_hash, str_equal);
	
	construct {
		this.set_sub_store("blank",new Fossil.Store.AboutStore.FixedText(""));
	}
	
	public void request(Fossil.Request request,string? filepath = null, bool upload = false){
		var substore = substores.get(request.uri);
		Fossil.GtkUi.LegacyWidget.TabHead.favicon.set_from_icon_name("text-x-generic", Gtk.IconSize.LARGE_TOOLBAR);
		if (substore != null) {
			substore.request(request,filepath,upload);
		} else {
			request.setStatus("error/resourceUnavaiable");
			request.finish();
		}
	}
	
	public void set_sub_store(string about_what, Fossil.Interface.ResourceStore? substore){
		if(substore != null) {
			print("[about] registred about:"+about_what+"\n");
			substores.set("about:"+about_what,substore);
		} else {
			substores.remove("about:"+about_what);
		}
	}
	
}

public class Fossil.Store.AboutStore.FixedText : Object, Fossil.Interface.ResourceStore {
	
	public string text;
	public string mimetype;
	public string name;
	
	public FixedText(string text, string mimetype = "text/plain", string name = ""){
		this.text = text;
		this.mimetype = mimetype;
		this.name = name;
	}
	
	public void request(Fossil.Request request,string? filepath = null, bool upload = false){
		if (filepath == null){
			request.setStatus("error/internal","Filepath required!");
			request.finish();
			return;
		}
		if (upload){
			request.setStatus("error/noupload","Uploding not supported");
			request.finish();
			return;
		}
		var helper = new Fossil.Util.ResourceFileWriteHelper(request,filepath,0);
		helper.appendString(this.text);
		if (helper.error){return;}
		helper.close();
		var resource = new Fossil.Resource(request.uri,filepath,true);
		resource.add_metadata(this.mimetype,this.name);
		request.setResource(resource,"about");
		request.finish(true);
	}
	
}

public class Fossil.Store.AboutStore.FixedStatus : Object, Fossil.Interface.ResourceStore {
	
	public string status;
	public string substatus;
	
	public FixedStatus(string status, string substatus=""){
		this.status = status;
		this.substatus = substatus;
	}
	
	public void request(Fossil.Request request,string? filepath = null, bool upload = false){
		request.setStatus(this.status,this.substatus);
		request.finish();
	}
	
}
