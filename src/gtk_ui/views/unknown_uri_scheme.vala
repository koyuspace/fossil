public class Dragonstone.GtkUi.View.UnknownUriScheme : Dragonstone.GtkUi.Widget.DialogViewBase, Dragonstone.GtkUi.Interface.View {
	
	private Dragonstone.Request request = null;
	private Gtk.Button open_externally_button = new Gtk.Button.with_label("Open in external Browser");
	private string title = "Unknown Uri Scheme";
	
	public UnknownUriScheme(Dragonstone.Registry.TranslationRegistry? translation = null) {
		if(translation != null){
			this.title = translation.localize("view.dragonstone.unknown_uri_scheme.title");
			this.open_externally_button.label = translation.localize("action.open_uri_externally");
		}
		open_externally_button.get_style_context().add_class("suggested-action");
		
		this.append_big_icon("dialog-question-symbolic");
		this.append_big_headline(title);
		this.append_widget(open_externally_button);
		
		show_all();
	}
	
	public bool displayResource(Dragonstone.Request request, Dragonstone.Tab tab, bool as_subview){
		if (request.status != "error/uri/unknownScheme") {return false;}
		this.request = request;
		open_externally_button.clicked.connect(() => {
			tab.open_uri_externally(this.request.uri);
		});
		return true;
	}
	
	public bool canHandleCurrentResource(){
		if (request == null){
			return false;
		}else{
			return request.status == "error/uri/unknownScheme";
		}
	}
	
}
