public class Fossil.GtkUi.Theming.HypertextViewTheme : Fossil.GtkUi.Interface.Theming.HypertextViewTheme, Object {
	
	public bool monospaced_by_default = true;
	
	private HashTable<string,string> prefixes = new HashTable<string,string>(str_hash, str_equal);
	private HashTable<string,Fossil.GtkUi.Theming.TextTagTheme> text_tag_themes = new HashTable<string,Fossil.GtkUi.Theming.TextTagTheme>(str_hash, str_equal);
	
	public void set_prefix(string name, string? prefix){
		if (prefix != null) {
			prefixes.set(name, prefix);
		} else {
			prefixes.remove(name);
		}
	}
	
	public void set_text_tag_theme(string name, Fossil.GtkUi.Theming.TextTagTheme? theme){
		if (theme != null) {
			text_tag_themes.set(name, theme);
		} else {
			text_tag_themes.remove(name);
		}
	}
	
	public void foreach_prefix(HFunc<string,string> cb){
		prefixes.foreach(cb);
	}
	
	public void foreach_text_tag_theme(HFunc<string,Fossil.GtkUi.Theming.TextTagTheme> cb){
		text_tag_themes.foreach(cb);
	}
	
	  ////////////////////////////////////////////////////////////
	 // Fossil.GtkUi.Interface.Theming.HypertextViewTheme //
	////////////////////////////////////////////////////////////
	
	public string? get_prefix(string name){
		return prefixes.get(name);
	}
	
	public Fossil.GtkUi.Theming.TextTagTheme? get_text_tag_theme(string name){
		return text_tag_themes.get(name);
	}
	
	public bool is_monospaced_by_default(){
		return monospaced_by_default;
	}
	
	public string get_best_matching_text_tag_theme_name(string[] classes){
		if (classes.length == 0) { return "*"; }
		int best_score = 0;
		string best_theme_name = "*";
		foreach_text_tag_theme((name, _) => {
			string[] name_tokens = name.split(" ");
			if (name_tokens.length <= classes.length){
				if (name_tokens[0].has_prefix(":") || name_tokens[0] == classes[0]) {
					int score = -name_tokens.length;
					foreach(string token in name_tokens) {
						bool found = false;
						foreach (string clazz in classes) {
							if (token == clazz) {
								score += 100;
								found = true;
								break;
							}
						}
						if (!found) {
							score = -1000;
							break;
						}
					}
					if (score > best_score){
						best_score = score;
						best_theme_name = name;
					}
				}
			}
		});
		return best_theme_name;
	}
	
}
