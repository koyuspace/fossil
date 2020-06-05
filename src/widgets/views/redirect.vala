public class Dragonstone.View.Redirect : Dragonstone.Widget.DialogViewBase, Dragonstone.IView {
	
	private Dragonstone.Request request = null;
	private Gtk.Button redirbutton = new Gtk.Button();
	private Gtk.Label buttonlabel = new Gtk.Label("");
	private string title = "Redirect to";
	
	public Redirect(Dragonstone.Registry.TranslationRegistry? translation = null) {
		if(translation != null){
			this.title = translation.localize("view.dragonstone.redirect.title");
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
	
	public bool displayResource(Dragonstone.Request request,Dragonstone.Tab tab){
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
