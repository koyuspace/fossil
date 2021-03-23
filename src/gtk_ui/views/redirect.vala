public class Fossil.GtkUi.View.Redirect : Fossil.GtkUi.LegacyWidget.DialogViewBase, Fossil.GtkUi.Interface.LegacyView {
	
	private Fossil.Request request = null;
	private Gtk.Button redirbutton = new Gtk.Button();
	private Gtk.Label buttonlabel = new Gtk.Label("");
	private string title = "Redirect to";
	
	public Redirect(Fossil.Registry.TranslationRegistry? translation = null) {
		if(translation != null){
			this.title = translation.localize("view.fossil.redirect.title");
		}
		redirbutton.get_style_context().add_class("suggested-action");
		redirbutton.add(buttonlabel);
		buttonlabel.wrap_mode = Pango.WrapMode.WORD_CHAR;
		buttonlabel.wrap = true;
		this.append_big_icon("media-playlist-shuffle-symbolic");
		this.append_big_headline(title);
		this.append_widget(redirbutton);
		show_all();
	}
	
	public bool display_resource(Fossil.Request request, Fossil.GtkUi.LegacyWidget.Tab tab, bool as_subview){
		if (!(request.status.has_prefix("redirect"))) {return false;}
		this.request = request;
		buttonlabel.label = request.substatus;
		redirbutton.clicked.connect(() => {
			tab.redirect(this.request.substatus);
		});
		return true;
	}
	
	public bool canHandleCurrentResource(){
		if (request == null){
			return false;
		}else{
			return request.status.has_prefix("redirect");
		}
	}
	
}
