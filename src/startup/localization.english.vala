public class Dragonstone.Startup.Localization.English {
	public static void setup_language(SuperRegistry super_registry){
		var language = new Dragonstone.Registry.TranslationLanguageRegistry();
		//add all words, phrases, etc.
		//general actions
		language.set_text("action.cancel","Cancel");
		language.set_text("action.download","Download");
		language.set_text("action.open_in_new_tab","Open in new tab");
		//Tabs
		language.set_text("tab.error.no_view.message","I'm sorry, but I don't know how to show that to you\nPlease report this to the developer if this is a release version (or you think this really shouldn't have happened)!");
		language.set_text("tab.error.wrong_view.message","I think i chose the wrong view ...\nPlease report this to the developer!");
		//window
		language.set_text("window.title","Project Dragonstone");
		language.set_text("window.main_menu.prefer_source_view.label","View Page Source");
		language.set_text("window.main_menu.cache.label","Cache");
		language.set_text("window.main_menu.settings.label","Settings");
		language.set_text("window.main_menu.close_tab.label","Close tab");
		language.set_text("window.main_menu.open_uri_externally.label","Open in external browser");
		language.set_text("window.main_menu.open_file_externally.label","Open in external viewer");
		//cache
		language.set_text("view.interactive/cache.erase_cache","Erase cache");
		language.set_text("view.interactive/cache.search.placeholder","Search for uri ...");
		language.set_text("view.interactive/cache.remove.tooltip","Remove resource from cache");
		language.set_text("view.interactive/cache.open_in_new_tab.tooltip","Open resource in new tab");
		language.set_text("view.interactive/cache.pin.tooltip","Stop resource from expireing");
		language.set_text("view.interactive/cache.column.uri.head","Uri");
		language.set_text("view.interactive/cache.column.time_to_live.head","TTL");
		language.set_text("view.interactive/cache.column.users.head","Users");
		language.set_text("view.interactive/cache.duration.infinite","forever");
		language.set_text("view.interactive/cache.duration.over_a_year","over a year");
		//messages
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
		language.set_text("view.error/resourceUnwavaiable/temporary.sublabel","Should be back soon™️");
		language.set_text("view.error/uri/unknownScheme.label","Unknown uri scheme");
		language.set_text("view.error/uri/unknownScheme.sublabel","No I don't support cat:// uris!");
		language.set_text("view.error/uri/unknownScheme/cat.label","Meow!");
		language.set_text("view.error/uri/unknownScheme/cat.sublabel","");
		//done
		super_registry.store("localization.translation.english",language);
		var multiplexer = (super_registry.retrieve("localization.translation") as Dragonstone.Registry.TranslationMultiplexerRegistry);
		if (multiplexer != null){
			multiplexer.add_language("english",language);
		}
	}
	
	public static void use_language(SuperRegistry super_registry){
		var multiplexer = (super_registry.retrieve("localization.translation") as Dragonstone.Registry.TranslationMultiplexerRegistry);
		if (multiplexer != null){
			multiplexer.active_languages.append("english");
		}
	}
}
