public class Dragonstone.View.GeminiInput : Gtk.Bin, Dragonstone.IView {
	
	private Dragonstone.Request request = null;
	private Gtk.Box centerBox;
	
	construct {
		var outerBox = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		centerBox = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		centerBox.margin = 16;
		var label = new Gtk.Label(">_"); //TOTRANSLATE
		var labelAttrList = new Pango.AttrList();
		labelAttrList.insert(new Pango.AttrSize(48000));
		label.attributes = labelAttrList;
		centerBox.pack_start(label);
		outerBox.set_center_widget(centerBox);
		add(outerBox);
	}
	
	public bool displayResource(Dragonstone.Request request,Dragonstone.Tab tab){
		if (!(request.status == "success" && request.resource.mimetype == "gemini/input")) {return false;}
		this.request = request;
		centerBox.pack_start(new Gtk.Label(request.resource.name));
		var input = new Dragonstone.View.GeminiInputInput("",tab.uri);
		input.go.connect((s,uri) => {tab.go_to_uri(uri);});
		centerBox.pack_start(input);
		centerBox.set_child_packing(input,true,true,0,Gtk.PackType.START);
		show_all();
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
	private Gtk.Entry entry;
	
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
