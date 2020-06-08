public class Dragonstone.View.Message : Dragonstone.Widget.DialogViewBase, Dragonstone.IView {
	
	private Dragonstone.Request request = null;
	private Gtk.Label error_label = new Gtk.Label(""); 
	private string status;
	
	public Message(string status, string label_text = "Something went wrong ...", string sublabel_text = "...", string icon_name = "dialog-error-symbolic") {
		this.status = status;
		this.append_big_icon(icon_name);
		this.append_big_headline(label_text);
		this.append_small_headline(sublabel_text);
		this.append_widget(error_label);
		show_all();
	}
	
	public bool displayResource(Dragonstone.Request request, Dragonstone.Tab tab, bool as_subview){
		if (!(request.status.has_prefix(status))) {return false;}
		this.request = request;
		error_label.label = request.status+"\n"+request.substatus;
		//nameLabel.label = request.name;
		return true;
	}
	
	public bool canHandleCurrentResource(){
		if (request == null){
			return false;
		}else{
			return request.status.has_prefix(status);
		}
	}
	
}
