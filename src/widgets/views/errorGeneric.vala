public class Dragonstone.View.Error.Generic : Dragonstone.Widget.DialogViewBase, Dragonstone.IView {
	
	private Dragonstone.Request request = null;
	private Gtk.Label statuslabel; 
	private Gtk.Label sublabel;
	private string view_status = null;
	
	public Generic(Dragonstone.Registry.TranslationRegistry? translation = null) {
		string title = "ERROR";
		if (translation != null){
			title = translation.localize("view.error.title");
		}
		
		this.append_big_icon("dialog-error-symbolic");
		this.append_big_headline(title);
		statuslabel = this.append_small_headline("---");
		sublabel = this.append_label("...");
	
	}
	
	public bool displayResource(Dragonstone.Request request,Dragonstone.Tab tab){
		if (!(request.status.has_prefix("error/"))) {return false;}
		view_status = request.status;
		this.request = request;
		
		statuslabel.label = request.status;
		sublabel.label = request.substatus;
		//nameLabel.label = request.name;
		show_all();
		return true;
	}
	
	public bool canHandleCurrentResource(){
		if (request == null){
			return false;
		}else{
			return request.status == view_status; //refresh when status changes
		}
	}
	
}

