public class Fossil.GtkUi.View.GeminiInput : Fossil.GtkUi.LegacyWidget.DialogViewBase, Fossil.GtkUi.Interface.LegacyView {
	
	private Fossil.Request request = null;
	
	private Fossil.GtkUi.View.GeminiInputInput? input = null;
	private bool confidential = false;
	
	construct {
		this.append_big_headline(">_");
	}
	
	public bool display_resource(Fossil.Request request, Fossil.GtkUi.LegacyWidget.Tab tab, bool as_subview){
		if (!(request.status == "success" && request.resource.mimetype == "gemini/input")) {return false;}
		this.request = request;
		this.append_small_headline(request.resource.name);
		input = new Fossil.GtkUi.View.GeminiInputInput("",tab.uri);
		input.go.connect((s,uri) => {tab.go_to_uri(uri);});
		if (request.arguments.get("gemini.statuscode") == "11") {
			confidential = true;
			input.entry.input_purpose = Gtk.InputPurpose.PASSWORD;
			input.entry.set_visibility(false);
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
	
	public bool import(string data){
		if (confidential || input == null){
			return false;
		}
		var kv = new Fossil.Util.Kv();
		kv.import(data);
		if (kv.get_value("view_type") != "fossil.gemini_input.0"){
			return false;
		}
		string? val = kv.get_value("input");
		if (val != null){
			input.entry.text = val;
		}
		return true;
	}
	
	public string? export(){
		if (confidential || input == null){
			return null;
		}
		var kv = new Fossil.Util.Kv();
		kv.set_value("view_type","fossil.gemini_input.0");
		kv.set_value("input",input.entry.text);
		return kv.export();
	}
	
}

private class Fossil.GtkUi.View.GeminiInputInput : Gtk.Box {

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
