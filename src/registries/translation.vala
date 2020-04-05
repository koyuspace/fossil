public interface Dragonstone.Registry.TranslationRegistry : Object {
	
	//returns "?_"+text_id if no translation is known
	public abstract string get_localized_string(string text_id);
	
	public string localize(string text_id){
		return this.get_localized_string(text_id);
	}
	
	public virtual string get_language_name(){ return ""; }
	
}

public class Dragonstone.Registry.TranslationMultiplexerRegistry : Object, Dragonstone.Registry.TranslationRegistry {
	
	private HashTable<string,TranslationRegistry> languages = new HashTable<string,TranslationRegistry>(str_hash, str_equal);
	
	public List<string> active_languages = new List<string>(); //used for setting the active languages
	
	public void add_language(string id,TranslationRegistry registry){
		languages.set(id,registry);
	}
	
	public string get_localized_string(string text_id){
		string unknown_translation = "?_"+text_id;
		foreach(string language_name in active_languages){
			var language = languages.get(language_name);
			if (language != null){
				string translation = language.get_localized_string(text_id);
				if (translation != unknown_translation){
					return translation;
				}
			}
		}
		return unknown_translation;
	}
	
}

public class Dragonstone.Registry.TranslationLanguageRegistry : Object, Dragonstone.Registry.TranslationRegistry {
	
	private HashTable<string,string> texts = new HashTable<string,string>(str_hash, str_equal);
	
	public void set_text(string id,string text){
		texts.set(id,text);
	}
	
	public string get_localized_string(string text_id){
		string? translation = texts.get(text_id);
		if (translation != null){
			return translation;
		} else {
			return "?_"+text_id;
		}
	}
	
}

