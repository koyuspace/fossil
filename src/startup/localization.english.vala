public class Dragonstone.Startup.Localization.English {
	public static void setup_language(SuperRegistry super_registry){
		var language = new Dragonstone.Registry.TranslationLanguageRegistry();
		//add all words, phrases, etc.
		language.set_text("action.cancel","Cancel");
		language.set_text("action.download","Download");
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
