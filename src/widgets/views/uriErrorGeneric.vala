public class Dragonstone.View.UriError.Generic : Dragonstone.Widget.DialogViewBase, Dragonstone.IView {
	
	private Dragonstone.Request request = null;
	
	public Generic(Dragonstone.Registry.TranslationRegistry? translation = null) {
		string title = "Invalid Uri";
		string subtitle = "Something went wrong while parsin an URL/URI";
		if (translation != null){
			title = translation.localize("view.uri_error_generic.title");
			subtitle = translation.localize("view.uri_error_generic.subtitle");
		}
		this.append_big_headline(title);
		this.append_small_headline(subtitle);
		
		show_all();
	}
	
	public bool displayResource(Dragonstone.Request request, Dragonstone.Tab tab, bool as_subview){
		if (!(request.status.has_prefix("error/uri"))) {return false;}
		this.request = request;
		show_all();
		return true;
	}
	
	public bool canHandleCurrentResource(){
		if (request == null){
			return false;
		}else{
			return request.status.has_prefix("error/uri");
		}
	}
	
}
