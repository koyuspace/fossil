public delegate Dragonstone.IView Dragonstone.Registry.ViewConstructor();

public class Dragonstone.Registry.ViewRegistry : Object {
	private List<Dragonstone.Registry.ViewRegistryEntry> entrys = new List<Dragonstone.Registry.ViewRegistryEntry>();
	
	public ViewRegistry.default_configuration(){
		add_view("loading", () => { return new Dragonstone.View.Loading(); });
		add_view("connecting", () => { return new Dragonstone.View.Loading(); });
		add_view("routing", () => { return new Dragonstone.View.Loading(); });
		add_view("redirect", () => { return new Dragonstone.View.Redirect();});
		add_view("error/internal", () => { return new Dragonstone.View.InternalError(); });
		add_view("error/gibberish", () => { return new Dragonstone.View.Gibberish(); });
		add_view("error/connectionRefused", () => { return new Dragonstone.View.ConnectionRefused(); });
		add_view("error/noHost", () => { return new Dragonstone.View.HostUnreachable(); });
		add_view("error/resourceUnavaiable", () => { return new Dragonstone.View.Unavaiable(); });
		add_view("error",() => { return new Dragonstone.View.Error.Generic(); });
		add_resource_view("text/",() => { return new Dragonstone.View.Plaintext(); });
		add_resource_view("image/",() => { return new Dragonstone.View.Image(); });
		add_resource_view("",() => { return new Dragonstone.View.Download(); });
	}
	
	public ViewRegistry.source_view_configuration(){
		add_resource_view("text/",() => { return new Dragonstone.View.Plaintext(); });
	}
	
	public void add_resource_view(string mimetype, owned Dragonstone.Registry.ViewConstructor constructor, string status = "success"){
		entrys.append(new Dragonstone.Registry.ViewRegistryEntry(status, mimetype, (owned) constructor));
	}
	
	public void add_view(string status,owned Dragonstone.Registry.ViewConstructor constructor,string? mimetype = null){
		entrys.append(new Dragonstone.Registry.ViewRegistryEntry(status, mimetype, (owned) constructor));
	}
	
	//TODO: public void remove_view(string status,string? mimetype){}
	
	public Dragonstone.IView? get_view(string status,string? mimetype = null){
		Dragonstone.Registry.ViewRegistryEntry best_match = null;
		uint closest_match_length = 0;
		foreach(Dragonstone.Registry.ViewRegistryEntry entry in entrys){
			if (entry.mimetype != null && mimetype != null){
				if (status.has_prefix(entry.status) && mimetype.has_prefix(entry.mimetype) && entry.status.length+entry.mimetype.length > closest_match_length){
					best_match = entry;
					closest_match_length = entry.status.length+entry.mimetype.length;
				}
			} else if (entry.mimetype == null && mimetype == null){
				if (status.has_prefix(entry.status) && entry.status.length > closest_match_length){
					best_match = entry;
					closest_match_length = entry.status.length;
				}
			}
		}
		if (best_match == null){ return null; }
		return best_match.view_vonstructor();
	}
	
}

private class Dragonstone.Registry.ViewRegistryEntry {
	public string status;
	public string? mimetype;
	public Dragonstone.Registry.ViewConstructor view_vonstructor;
	
	public ViewRegistryEntry(string status,string? mimetype,owned Dragonstone.Registry.ViewConstructor view_vonstructor){
		this.status = status;
		this.mimetype = mimetype;
		this.view_vonstructor = (owned) view_vonstructor;
	}
}
