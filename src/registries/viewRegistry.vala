public delegate Dragonstone.IView Dragonstone.Registry.ViewConstructor();

public class Dragonstone.Registry.ViewRegistry : Object {
	private List<Dragonstone.Registry.ViewRegistryEntry> entrys = new List<Dragonstone.Registry.ViewRegistryEntry>();
	
	public ViewRegistry.default_configuration(Dragonstone.Registry.TranslationRegistry? translatori = null){
		var translator = translatori;
		print("[view_registry] initalizung with default configuration\n");
		if (translator == null){
			print("tranlator not found\n");
			var language = new Dragonstone.Registry.TranslationLanguageRegistry();
			language.set_text("view.error/internal.label","Hell just broke loose");
			language.set_text("view.error/internal.sublabel","or maybe it was just a tiny bug?\nPlease report to the developer!");
			language.set_text("view.error/gibberish.label","Gibberish!");
			language.set_text("view.error/gibberish.sublabel","That not what the server said,\n that's what it looks like!");
			language.set_text("view.error/connectionRefused.label","Connection refused");
			language.set_text("view.error/connectionRefused.sublabel","so rude ...");
			language.set_text("view.error/noHost.label","Host not found!");
			language.set_text("view.error/noHost.sublabel","How about a game of hide and seek?");
			language.set_text("view.error/resourceUnavaiable.label","Resource not found");
			language.set_text("view.error/resourceUnavaiable.sublabel","No idea if there ever was or will be something ...");
			language.set_text("view.error/resourceUnavaiable/temporary.label","Reource not found");
			language.set_text("view.error/resourceUnavaiable/temporary.sublabel","Should be back soon™️");
			language.set_text("view.error/uri/unknownScheme.label","Unknown uri scheme");
			language.set_text("view.error/uri/unknownScheme.sublabel","No I don't support cat:// uris!");
			language.set_text("view.error/uri/unknownScheme/cat.label","Meow!");
			language.set_text("view.error/uri/unknownScheme/cat.sublabel","");
			translator = (owned) language;
		}
		print(@"$(translator != null)\n");
		add_view("loading", () => { return new Dragonstone.View.Loading(); });
		add_view("connecting", () => { return new Dragonstone.View.Loading(); });
		add_view("routing", () => { return new Dragonstone.View.Loading(); });
		add_view("redirect", () => { return new Dragonstone.View.Redirect();});
		var interal_error_view_factory = new Dragonstone.Util.MessageViewFactory("error/internal","dialog-warning-symbolic",translator);
		add_view("error/internal", interal_error_view_factory.construct_view);
		var gibberish_error_view_factory = new Dragonstone.Util.MessageViewFactory("error/gibberish","dialog-question-symbolic",translator);
		add_view("error/gibberish", gibberish_error_view_factory.construct_view);
		var connection_refused_error_view_factory = new Dragonstone.Util.MessageViewFactory("error/connectionRefused","action-unavailable-symbolic",translator);
		add_view("error/connectionRefused", connection_refused_error_view_factory.construct_view);
		var no_host_error_view_factory = new Dragonstone.Util.MessageViewFactory("error/noHost","find-location-symbolic",translator);
		add_view("error/noHost", no_host_error_view_factory.construct_view);
		var resource_unavaiable_error_view_factory = new Dragonstone.Util.MessageViewFactory("error/resourceUnavaiable","computer-fail-symbolic",translator);
		add_view("error/resourceUnavaiable", resource_unavaiable_error_view_factory.construct_view);
		var resource_unavaiable_temoprary_error_view_factory = new Dragonstone.Util.MessageViewFactory("error/resourceUnavaiable/temporary","computer-fail-symbolic",translator);
		add_view("error/resourceUnavaiable/temporary", resource_unavaiable_temoprary_error_view_factory.construct_view);
		var uri_unknown_scheme_error_view_factory = new Dragonstone.Util.MessageViewFactory("error/uri/unknownScheme","dialog-question-symbolic",translator);
		add_view("error/uri/unknownScheme", uri_unknown_scheme_error_view_factory.construct_view);
		var uri_unknown_scheme_error_view_factory = new Dragonstone.Util.MessageViewFactory("error/uri/unknownScheme/cat","user-available-symbolic",translator);
		add_view("error/uri/unknownScheme", uri_unknown_scheme_error_view_factory.construct_view);
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
