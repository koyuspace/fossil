public class Dragonstone.View.Unavaiable : Gtk.Bin, Dragonstone.IView {
	
	private Dragonstone.Request request = null;
	private Gtk.Label sublabel = new Gtk.Label("...");
	
	construct {
		var outerBox = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		var centerBox = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		var label = new Gtk.Label("Resource unavaiable"); //TOTRANSLATE
		var icon = new Gtk.Image.from_icon_name("computer-fail-symbolic",Gtk.IconSize.DIALOG);
		icon.icon_size=6;
		var labelAttrList = new Pango.AttrList();
		labelAttrList.insert(new Pango.AttrSize(48000));
		var sublabelAttrList = new Pango.AttrList();
		sublabelAttrList.insert(new Pango.AttrSize(16000));
		var sublabelFontDesc = new Pango.FontDescription();
		sublabelFontDesc.set_style(Pango.Style.OBLIQUE);
		sublabelAttrList.insert(new Pango.AttrFontDesc(sublabelFontDesc));
		label.attributes = labelAttrList;
		sublabel.attributes = sublabelAttrList;
		centerBox.pack_start(icon);
		centerBox.pack_start(label);
		centerBox.pack_start(sublabel);
		outerBox.set_center_widget(centerBox);
		var empty2 = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		outerBox.pack_start(empty2);
		var empty1 = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		outerBox.pack_end(empty1);
		add(outerBox);
	}
	
	public bool displayResource(Dragonstone.Request request,Dragonstone.Tab tab){
		if (request.status == "error/resourceUnavaiable") {
			sublabel.label = "No idea if or when it will be back\nThe server says:\n"+request.substatus; //TOTRANSLATE
		} else if (request.status == "error/resourceUnavaiable/temporary") {
			sublabel.label = "Should come back soon™\nThe server says:\n"+request.substatus; //TOTRANSLATE
		} else {
			return false;
		}
		this.request = request;
		return true;
	}
	
	public bool canHandleCurrentResource(){
		if (request == null){
			return false;
		}else{
			return 
				request.status == "error/resourceUnavaiable" || 
				request.status == "error/resourceUnavaiable/temporary";
		}
	}
	
}
