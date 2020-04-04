public class Dragonstone.Util.MessageViewFactory : Object {
	
	string unlocalized_label_text;
	string unlocalized_sublabel_text;
	string icon_name;
	string view_status;
	Dragonstone.Registry.TranslationRegistry? translator;
	
	public MessageViewFactory(string view_status, string icon_name, Dragonstone.Registry.TranslationRegistry? translator, string? unlocalized_label_text = null, string? unlocalized_sublabel_text = null) {
		this.unlocalized_label_text = unlocalized_label_text;
		if (this.unlocalized_label_text == null){
			this.unlocalized_label_text = @"view.$view_status.label";
		}
		this.unlocalized_sublabel_text = unlocalized_sublabel_text;
		if (this.unlocalized_sublabel_text == null){
			this.unlocalized_sublabel_text = @"view.$view_status.sublabel";
		}
		this.icon_name = icon_name;
		this.view_status = view_status;
		if (translator == null){
			this.translator = new Dragonstone.Registry.TranslationLanguageRegistry();
		} else {
			this.translator = translator;
		}
	}
	
	public Dragonstone.IView construct_view(){
		string label_text = translator.get_localized_string(unlocalized_label_text);
		string sublabel_text = translator.get_localized_string(unlocalized_sublabel_text);
		return new Dragonstone.View.Message(view_status, label_text, sublabel_text, icon_name);
	}
	
}
