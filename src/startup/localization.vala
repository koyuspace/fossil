public class Dragonstone.Startup.LocalizationRegistry {
	public static void setup_translation_registry(SuperRegistry super_registry){
		super_registry.store("localization.translation",new Dragonstone.Registry.TranslationMultiplexerRegistry());
	}
}	
