public class Dragonstone.View.GeminiInput : Gtk.Box, Dragonstone.IView {
	
	private Dragonstone.Request request = null;
	private Gtk.Box center_box;
	
	construct {
		this.orientation = Gtk.Orientation.VERTICAL;
		center_box = new Gtk.Box(Gtk.Orientation.VERTICAL,8);
		center_box.margin = 16;
		var label = new Gtk.Label(">_"); //TOTRANSLATE
		var labelAttrList = new Pango.AttrList();
		labelAttrList.insert(new Pango.AttrSize(48000));
		label.attributes = labelAttrList;
		center_box.pack_start(label);
		set_center_widget(center_box);
	}
	
	public bool displayResource(Dragonstone.Request request,Dragonstone.Tab tab){
		if (!(request.status == "success" && request.resource.mimetype == "gemini/input")) {return false;}
		this.request = request;
		var prompt = new Gtk.Label(request.resource.name);
		var prompt_attr_list = new Pango.AttrList();
		prompt_attr_list.insert(new Pango.AttrSize(16000));
		prompt.attributes = prompt_attr_list;
		prompt.wrap_mode = Pango.WrapMode.WORD_CHAR;
		prompt.wrap = true;
		center_box.pack_start(prompt);
		var input = new Dragonstone.View.GeminiInputInput("",tab.uri);
		input.go.connect((s,uri) => {tab.go_to_uri(uri);});
		center_box.pack_start(input);
		center_box.set_child_packing(input,true,true,0,Gtk.PackType.START);
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
