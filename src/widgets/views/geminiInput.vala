public class Dragonstone.View.GeminiInput : Gtk.Bin, Dragonstone.IView {
	
	private Dragonstone.Resource resource = null;
	private Gtk.Box centerBox;
	
	construct {
		var outerBox = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		centerBox = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		var label = new Gtk.Label(">_"); //TOTRANSLATE
		//var icon = new Gtk.Image.from_icon_name("input-keyboard-symbolic",Gtk.IconSize.DIALOG);
		//icon.icon_size=6;
		var labelAttrList = new Pango.AttrList();
		labelAttrList.insert(new Pango.AttrSize(48000));
		label.attributes = labelAttrList;
		//centerBox.pack_start(icon);
		centerBox.pack_start(label);
		outerBox.set_center_widget(centerBox);
		var empty0 = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		outerBox.pack_start(empty0);
		var empty1 = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		outerBox.pack_end(empty1);
		add(outerBox);
	}
	
	public bool displayResource(Dragonstone.Resource resource,Dragonstone.Tab tab){
		if (!(resource.resourcetype == Dragonstone.ResourceType.DYNAMIC && resource.subtype == "gemini/input")) {return false;}
		this.resource = resource;
		centerBox.pack_start(new Gtk.Label(resource.name));
		var input = new Dragonstone.View.GeminiInputInput("",tab.uri);
		input.go.connect((s,uri) => {tab.goToUri(uri);});
		centerBox.pack_start(input);
		return true;
	}
	
	public bool canHandleCurrentResource(){
		if (resource == null){
			return false;
		}else{
			return (resource.resourcetype == Dragonstone.ResourceType.DYNAMIC 
				&& resource.subtype == "gemini/input");
		}
	}
	
}

private class Dragonstone.View.GeminiInputInput : Gtk.Bin {

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
		halign = Gtk.Align.CENTER;
		var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL,4);
		box.homogeneous = false;
		box.margin_start = 4;
		entry = new Gtk.Entry();
		entry.placeholder_text = htext;
		entry.halign = Gtk.Align.FILL;
		entry.activate.connect(submit);
		entry.expand = true;
		//var icon = new Gtk.Image.from_icon_name("system-search-symbolic",Gtk.IconSize.LARGE_TOOLBAR);
		//icon.halign = Gtk.Align.CENTER;
		var button = new Gtk.Button.from_icon_name("go-next-symbolic");
		button.get_style_context().add_class("suggested-action");
		button.clicked.connect(submit);
		button.halign = Gtk.Align.START;
		//box.pack_start(icon);
		box.set_center_widget(entry);
		box.pack_end(button);
		box.halign = Gtk.Align.FILL;
		add(box);
	}
	
	private void submit(){
		if (entry.text != ""){
			var searchstring = entry.text.replace("\t","%09").replace(" ","%20"); //TODO: prpoper url encode
			go(@"$base_uri?$searchstring");
		}
	}
}
