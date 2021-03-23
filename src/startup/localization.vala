public class Fossil.Startup.LocalizationRegistry {
	public static void setup_translation_registry(SuperRegistry super_registry){
		super_registry.store("localization.translation",new Fossil.Registry.TranslationMultiplexerRegistry());
	}
}	
