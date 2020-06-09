public class Dragonstone.View.GeminiInput : Dragonstone.Widget.DialogViewBase, Dragonstone.IView {
	
	private Dragonstone.Request request = null;
	
	construct {
		this.append_big_headline(">_");
	}
	
	public bool displayResource(Dragonstone.Request request, Dragonstone.Tab tab, bool as_subview){
		if (!(request.status == "success" && request.resource.mimetype == "gemini/input")) {return false;}
		this.request = request;
		this.append_small_headline(request.resource.name);
		var input = new Dragonstone.View.GeminiInputInput("",tab.uri);
		input.go.connect((s,uri) => {tab.go_to_uri(uri);});
		if (request.arguments.get("gemini.statuscode") == "11") {
			input.entry.input_purpose = Gtk.InputPurpose.PASSWORD;
		}
		this.append_widget(input);
		this.center_box.set_child_packing(input,true,true,0,Gtk.PackType.START);
		show_all();
		input.entry.grab_focus();
		return true;
	}
	
	public bool canHandleCurrentResource(){
		if (request == null){
			return false;
		}else{
			return (request.status == "success" && request.resource.mimetype == "gemini/input");
		}
	}
	
}

private class Dragonstone.View.GeminiInputInput : Gtk.Box {

	public signal void go(string uri);
	private string base_uri;
	public Gtk.Entry entry;
	
	public GeminiInputInput(string htext,string uri){
		var indexofqm = uri.index_of_char('?');
		if (indexofqm < 0){
			base_uri = uri;
		} else {
			base_uri = uri.substring(0,indexofqm);
		}
		this.homogeneous = false;
		this.orientation = Gtk.Orientation.HORIZONTAL;
		this.spacing = 4;
		entry = new Gtk.Entry();
		entry.placeholder_text = htext;
		entry.activate.connect(submit);
		entry.expand = true;
		var button = new Gtk.Button.from_icon_name("go-next-symbolic");
		button.get_style_context().add_class("suggested-action");
		button.clicked.connect(submit);
		pack_start(entry);
		pack_start(button);
		set_child_packing(button,false,false,0,Gtk.PackType.START);
		set_child_packing(entry,true,true,0,Gtk.PackType.START);
		expand = true;
	}
	
	private void submit(){
		if (entry.text != ""){
			var searchstring = Uri.escape_string(entry.text);
			go(@"$base_uri?$searchstring");
		}
	}
}
