public class Dragonstone.View.Error.Generic : Dragonstone.Widget.DialogViewBase, Dragonstone.IView {
	
	private Dragonstone.Request request = null;
	private Gtk.Label statuslabel; 
	private Gtk.Label sublabel;
	private Gtk.Label headline;
	private string view_status = null;
	
	public Generic() {
		//this.append_big_icon("dialog-error-symbolic");
		headline = this.append_big_headline("- ERROR -");
		statuslabel = this.append_small_headline("---");
		sublabel = this.append_label("...");
	
	}
	
	public bool displayResource(Dragonstone.Request request, Dragonstone.Tab tab, bool as_subview){
		if (!(request.status.has_prefix("error/") || request.status == "error")) {return false;}
		view_status = request.status;
		this.request = request;
		headline.label = tab.translation.localize("view.error.label");
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

