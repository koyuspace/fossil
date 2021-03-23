public class Fossil.GtkUi.View.Error.Generic : Fossil.GtkUi.LegacyWidget.DialogViewBase, Fossil.GtkUi.Interface.LegacyView {
	
	private Fossil.Request request = null;
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
	
	public bool display_resource(Fossil.Request request, Fossil.GtkUi.LegacyWidget.Tab tab, bool as_subview){
		//if (!(request.status.has_prefix("error/") || request.status == "error")) {return false;}
		view_status = request.status;
		this.request = request;
		headline.label = tab.translation.localize("view.error.label");
		statuslabel.label = request.status;
		sublabel.label = request.substatus;
		var argument_display = new Fossil.GtkUi.LegacyWidget.RequestArgumentDisplay(request);
		append_widget(argument_display);
		//nameLabel.label = request.name;
		show_all();
		if (as_subview){ use_as_subview(tab); }
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
