public class Fossil.GtkUi.View.Download : Fossil.GtkUi.LegacyWidget.DialogViewBase, Fossil.GtkUi.Interface.LegacyView {
	
	private Fossil.Request request = null;
	private Gtk.Label name_label = new Gtk.Label("");
	private Gtk.Button save_button = new Gtk.Button.with_label("Save");
	private Gtk.Button open_button = new Gtk.Button.with_label("Open in external viewer");
	private string title = "Downloaded!";
	
	public Download(Fossil.Registry.TranslationRegistry? translation = null) {
		if (translation != null){
			save_button.label = translation.localize("view.fossil.download.save_button.label");
			open_button.label = translation.localize("view.fossil.download.open_button.label");
			this.title = translation.localize("view.fossil.download.title");
		}
		save_button.get_style_context().add_class("suggested-action");
		this.append_big_icon("document-save-symbolic");
		this.append_big_headline(this.title);
		name_label = this.append_small_headline("");
		this.append_widget(save_button);
		this.append_widget(open_button);
		
	}
	
	public bool display_resource(Fossil.Request request, Fossil.GtkUi.LegacyWidget.Tab tab, bool as_subview){
		if (!(request.status == "success")) {return false;}
		this.request = request;
		name_label.label = Fossil.Util.Uri.get_filename(request.uri);
		save_button.clicked.connect(() => {
			tab.download();
		});
		open_button.clicked.connect(() => {
			tab.open_resource_externally();
		});
		show_all();
		return true;
	}
	
	public bool canHandleCurrentResource(){
		if (request == null){
			return false;
		}else{
			return request.status == "success";
		}
	}
	
}
