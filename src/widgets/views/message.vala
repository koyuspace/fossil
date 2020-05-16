public class Dragonstone.View.Message : Gtk.ScrolledWindow, Dragonstone.IView {
	
	private Dragonstone.Request request = null;
	private Gtk.Label nameLabel = new Gtk.Label("");
	private Gtk.Label sublabel; 
	private Gtk.Label error_label = new Gtk.Label(""); 
	private string status;
	
	public Message(string status, string label_text = "Something went wrong ...", string sublabel_text = "...", string icon_name = "dialog-error-symbolic") {
		this.status = status;
		nameLabel.valign = Gtk.Align.START;
		var outerBox = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		var centerBox = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		var label = new Gtk.Label(label_text);
		label.wrap_mode = Pango.WrapMode.WORD_CHAR;
		label.wrap = true;
		label.justify = Gtk.Justification.CENTER;
		sublabel = new Gtk.Label(sublabel_text);
		sublabel.justify = Gtk.Justification.CENTER;
		var icon = new Gtk.Image.from_icon_name(icon_name,Gtk.IconSize.DIALOG);
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
		centerBox.pack_start(error_label);
		outerBox.set_center_widget(centerBox);
		outerBox.pack_start(nameLabel);
		var empty = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		outerBox.pack_end(empty);
		add(outerBox);
		show_all();
	}
	
	public bool displayResource(Dragonstone.Request request,Dragonstone.Tab tab){
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
