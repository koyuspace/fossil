public delegate Dragonstone.GtkUi.Interface.LegacyView Dragonstone.GtkUi.ViewConstructor();

public class Dragonstone.GtkUi.LegacyViewRegistry : Object {
	
	public HashTable<string,LegacyViewRegistryEntry> views = new HashTable<string,LegacyViewRegistryEntry>(str_hash, str_equal);
	
	public LegacyViewRegistry.default_configuration(Dragonstone.Registry.TranslationRegistry? translatori = null){
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
			language.set_text("view.error/uri/unknownSchem.label","Meow!");
			language.set_text("view.error/uri/unknownSchem.sublabel","");
			translator = (owned) language;
		}
		print(@"$(translator != null)\n");
		add_view("dragonstone.loading", () => { return new Dragonstone.GtkUi.View.Loading(); });
		add_view("dragonstone.redirect", () => { return new Dragonstone.GtkUi.View.Redirect(translator);});
		var interal_error_view_factory = new Dragonstone.GtkUi.LegacyUtil.MessageViewFactory("error/internal","dialog-warning-symbolic",translator);
		add_view("dragonstone.error.internal", interal_error_view_factory.construct_view);
		var gibberish_error_view_factory = new Dragonstone.GtkUi.LegacyUtil.MessageViewFactory("error/gibberish","dialog-question-symbolic",translator);
		add_view("dragonstone.error.gibberish", gibberish_error_view_factory.construct_view);
		var connection_refused_error_view_factory = new Dragonstone.GtkUi.LegacyUtil.MessageViewFactory("error/connectionRefused","action-unavailable-symbolic",translator);
		add_view("dragonstone.error.connectionRefused", connection_refused_error_view_factory.construct_view);
		var no_host_error_view_factory = new Dragonstone.GtkUi.LegacyUtil.MessageViewFactory("error/noHost","find-location-symbolic",translator);
		add_view("dragonstone.error.noHost", no_host_error_view_factory.construct_view);
		var resource_unavaiable_error_view_factory = new Dragonstone.GtkUi.LegacyUtil.MessageViewFactory("error/resourceUnavaiable","computer-fail-symbolic",translator);
		add_view("dragonstone.error.resourceUnavaiable", resource_unavaiable_error_view_factory.construct_view);
		var resource_unavaiable_temoprary_error_view_factory = new Dragonstone.GtkUi.LegacyUtil.MessageViewFactory("error/resourceUnavaiable/temporary","computer-fail-symbolic",translator);
		add_view("dragonstone.error.resourceUnavaiable.temporary", resource_unavaiable_temoprary_error_view_factory.construct_view);
		add_view("dragonstone.error.uri.unknownScheme", () => { return new Dragonstone.GtkUi.View.UnknownUriScheme(translator); });
		var uri_unknown_scheme_error_cat_view_factory = new Dragonstone.GtkUi.LegacyUtil.MessageViewFactory("error/uri/unknownScheme","user-available-symbolic",translator,"view.meow.label","view.meow.sublabel");
		add_view("dragonstone.meow", uri_unknown_scheme_error_cat_view_factory.construct_view);
		add_view("dragonstone.error",() => { return new Dragonstone.GtkUi.View.Error.Generic(); });
		add_view("dragonstone.text",() => { return new Dragonstone.GtkUi.View.Plaintext(); });
		add_view("dragonstone.image",() => { return new Dragonstone.GtkUi.View.Image(); });
		add_view("dragonstone.download",() => { return new Dragonstone.GtkUi.View.Download(translator); });
		
		//add rules
		add_rule(new LegacyViewRegistryRule("loading","dragonstone.loading"));
		add_rule(new LegacyViewRegistryRule("uploading","dragonstone.loading"));
		add_rule(new LegacyViewRegistryRule("connecting","dragonstone.loading"));
		add_rule(new LegacyViewRegistryRule("routing","dragonstone.loading"));
		add_rule(new LegacyViewRegistryRule("redirect","dragonstone.redirect"));
		add_rule(new LegacyViewRegistryRule("error/internal","dragonstone.error.internal"));
		add_rule(new LegacyViewRegistryRule("error/gibberish","dragonstone.error.gibberish"));
		add_rule(new LegacyViewRegistryRule("error/connectionRefused","dragonstone.error.connectionRefused"));
		add_rule(new LegacyViewRegistryRule("error/noHost","dragonstone.error.noHost"));
		add_rule(new LegacyViewRegistryRule("error/resourceUnavaiable","dragonstone.error.resourceUnavaiable"));
		add_rule(new LegacyViewRegistryRule("error/resourceUnavaiable/temporary","dragonstone.error.resourceUnavaiable.temporary"));
		add_rule(new LegacyViewRegistryRule("error/uri/unknownScheme","dragonstone.error.uri.unknownScheme"));
		add_rule(new LegacyViewRegistryRule("error/uri/unknownScheme","dragonstone.meow").prefix("cat://"));
		add_rule(new LegacyViewRegistryRule("error","dragonstone.error"));
		add_rule(new LegacyViewRegistryRule.resource_view("text/","dragonstone.text").set_flag(LegacyViewRegistryRule.FLAG_SOURCEVIEW));
		add_rule(new LegacyViewRegistryRule.resource_view("application/xml","dragonstone.text").set_flag(LegacyViewRegistryRule.FLAG_SOURCEVIEW));
		add_rule(new LegacyViewRegistryRule.resource_view("application/json","dragonstone.text").set_flag(LegacyViewRegistryRule.FLAG_SOURCEVIEW));
		add_rule(new LegacyViewRegistryRule.resource_view("image/","dragonstone.image"));
		add_rule(new LegacyViewRegistryRule.resource_view("","dragonstone.download"));
	}
	
	public void add_view(string id,owned Dragonstone.GtkUi.ViewConstructor constructor){
		views.set(id,new LegacyViewRegistryEntry((owned) constructor));
	}
	
	
	public Dragonstone.GtkUi.Interface.LegacyView? get_view(string? id){
		if(id == null){ return null; }
		if (views.contains(id)){
			var entry = views.get(id);
			if (entry != null){
				return entry.constructor();
			}
		}
		return null;
	}
	
	//View rule stuff
	public List<Dragonstone.GtkUi.LegacyViewRegistryRule> rules = new List<Dragonstone.GtkUi.LegacyViewRegistryRule>();
	
	
	public void add_rule(LegacyViewRegistryRule rule){
		rules.append(rule);
	}
}

public class Dragonstone.GtkUi.LegacyViewRegistryViewChooser : Object {
	public string? best_match = null; //may be overidden by i.e. user choice
	public HashTable<string,uint32> matches = new HashTable<string,uint32>(str_hash, str_equal);
	public LegacyViewRegistry registry;
	public signal void scores_changed();
	
	public LegacyViewRegistryViewChooser(LegacyViewRegistry registry){
		this.registry = registry;
	}
	
	public void reset(){
		best_match = null;
		matches.remove_all();
	}
	
	public void choose(string status, string? mimetype, string uri, List<string>? required_flags = null){
		//print(@"status: $(status != null)\n");
		//print(@"mimetype: $(mimetype != null)\n");
		//print(@"uri: $(uri != null)\n");
		/*print(@"Choosing view for status=$status, uri=$uri\n");
		if (required_flags != null) {
			foreach (string flag in required_flags){
				print(@" flag: $flag\n");
			}
		}*/
		this.reset();
		string? best_match = null;
		uint32 highscore = 0;
		foreach (Dragonstone.GtkUi.LegacyViewRegistryRule rule in registry.rules) {
			if (status.has_prefix(rule.status)){
				//print(@"checking $(rule.view)\n");
				bool exact_status_match = status == rule.status;
				bool exact_mimetype_match = false;
				bool fuzzy_mimetype_match = true;
				if (mimetype == rule.mimetype) {
					exact_mimetype_match = true;
				} else if (mimetype == null) {
					fuzzy_mimetype_match = false;
				} else {
					fuzzy_mimetype_match = mimetype.has_prefix(rule.mimetype);
				}
				if (fuzzy_mimetype_match || exact_mimetype_match){
					bool uri_prefix_match = false;
					bool uri_suffix_match = false;
					bool uri_mismatch = false;
					if (rule.uri_prefix != null) {
						uri_prefix_match = uri.has_prefix(rule.uri_prefix);
						uri_mismatch = uri_mismatch || (!uri_prefix_match);
					}
					if (rule.uri_suffix != null) {
						uri_suffix_match = uri.has_suffix(rule.uri_suffix);
						uri_mismatch = uri_mismatch || (!uri_suffix_match);
					}
					if (!uri_mismatch) {
						int score = 10;
						if (mimetype != null){
							score += rule.mimetype.length;
						}
						if(uri_prefix_match){ score += rule.uri_prefix.length + 500; }
						if(uri_suffix_match){ score += rule.uri_suffix.length + 500; }
						if(exact_status_match){ score += 1000; }
						if (required_flags != null){
							foreach (string flag in required_flags){
								if (rule.has_flag(flag)){ score += 1100; }
							}
						}
						score -= (int)rule.flags.length();
						print(@"  $(rule.view): $score\n");
						if (matches.contains(rule.view)) {
							if(matches.get(rule.view) < score){
								matches.set(rule.view,score);
							}
						} else {
							matches.set(rule.view,score);
						}
						if (highscore < score) {
							highscore = score;
							best_match = rule.view;
						}
					}
				}
			}
		}
		this.best_match = best_match;
		scores_changed();
	}
	
}

public class Dragonstone.GtkUi.LegacyViewRegistryRule : Object {
	public string status;
	public string view;
	public string? mimetype = null;
	public string? uri_prefix = null;
	public string? uri_suffix = null;
	public List<string> flags = new List<string>();
	
	public LegacyViewRegistryRule(string status,string view){
		this.status = status;
		this.view = view;
	}
	
	public LegacyViewRegistryRule.resource_view(string mimetype, string view, string? uri_prefix=null){
		this.status = "success";
		this.view = view;
		this.mimetype = mimetype;
		this.uri_prefix = uri_prefix;
	}
	
	public LegacyViewRegistryRule prefix(string uri_prefix){
		this.uri_prefix = uri_prefix;
		return this;
	}
	
	public LegacyViewRegistryRule suffix(string uri_suffix){
		this.uri_suffix = uri_suffix;
		return this;
	}
	
	public LegacyViewRegistryRule set_flag(string flag){
		lock(flags) {
			if (!has_flag(flag)){
				flags.append(flag);
			}
		}
		return this;
	}
	
	public LegacyViewRegistryRule clear_flag(string flag){
		lock(flags) {
			if (has_flag(flag)){
				flags.remove(flag);
			}
		}
		return this;
	}
	
	public bool has_flag(string flag){
		foreach( string f in flags ) {
			if (f==flag) {return true;}
		}
		return false;
	}
	
	public const string FLAG_SOURCEVIEW = "sourceview";
	public const string FLAG_UPLOAD = "upload";
}

public class Dragonstone.GtkUi.LegacyViewRegistryEntry : Object {
	
	public Dragonstone.GtkUi.ViewConstructor constructor;
	
	public LegacyViewRegistryEntry(owned Dragonstone.GtkUi.ViewConstructor constructor){
		this.constructor = (owned) constructor;
	}
}
