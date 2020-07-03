public class Dragonstone.Store.About : Object, Dragonstone.ResourceStore {
	
	private HashTable<string,Dragonstone.ResourceStore> substores = new HashTable<string,Dragonstone.ResourceStore>(str_hash, str_equal);
	
	construct {
		this.set_sub_store("blank",new Dragonstone.Store.AboutStore.FixedText(""));
	}
	
	public void request(Dragonstone.Request request,string? filepath = null, bool upload = false){
		var substore = substores.get(request.uri);
		if (substore != null) {
			substore.request(request,filepath,upload);
		} else {
			request.setStatus("error/resourceUnavaiable");
			request.finish();
		}
	}
	
	public void set_sub_store(string about_what, Dragonstone.ResourceStore? substore){
		if(substore != null) {
			print("[about] registred about:"+about_what+"\n");
			substores.set("about:"+about_what,substore);
		} else {
			substores.remove("about:"+about_what);
		}
	}
	
}

public class Dragonstone.Store.AboutStore.FixedText : Object, Dragonstone.ResourceStore {
	
	public string text;
	public string mimetype;
	public string name;
	
	public FixedText(string text, string mimetype = "text/plain", string name = ""){
		this.text = text;
		this.mimetype = mimetype;
		this.name = name;
	}
	
	public void request(Dragonstone.Request request,string? filepath = null, bool upload = false){
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
		var helper = new Dragonstone.Util.ResourceFileWriteHelper(request,filepath,0);
		helper.appendString(this.text);
		if (helper.error){return;}
		helper.close();
		var resource = new Dragonstone.Resource(request.uri,filepath,true);
		resource.add_metadata(this.mimetype,this.name);
		request.setResource(resource,"about");
		request.finish(true);
	}
	
}

public class Dragonstone.Store.AboutStore.FixedStatus : Object, Dragonstone.ResourceStore {
	
	public string status;
	public string substatus;
	
	public FixedStatus(string status, string substatus=""){
		this.status = status;
		this.substatus = substatus;
	}
	
	public void request(Dragonstone.Request request,string? filepath = null, bool upload = false){
		request.setStatus(this.status,this.substatus);
		request.finish();
	}
	
}
