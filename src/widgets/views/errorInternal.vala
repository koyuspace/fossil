public class Dragonstone.View.InternalError : Gtk.Bin, Dragonstone.IView {
	
	private Dragonstone.Resource resource = null;
	private Gtk.Label sublabel;
	private Gtk.Label msglabel = new Gtk.Label(""); 
	
	construct {
		msglabel.selectable = true;
		var outerBox = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		var centerBox = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		var label = new Gtk.Label("Something went VERY wrong ..."); //TOTRANSLATE
		sublabel = new Gtk.Label("..."); //TOTRANSLATE
		sublabel.justify = Gtk.Justification.CENTER;
		var icon = new Gtk.Image.from_icon_name("dialog-warning-symbolic",Gtk.IconSize.DIALOG);
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
		centerBox.pack_start(msglabel);
		outerBox.set_center_widget(centerBox);
		var empty = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		outerBox.pack_end(empty);
		add(outerBox);
	}
	
	public bool displayResource(Dragonstone.Resource resource,Dragonstone.Tab tab){
		if (!(resource.resourcetype == Dragonstone.ResourceType.ERROR_URI_SCHEME_NOT_SUPPORTED)) {return false;}
		this.resource = resource;
		sublabel.label = resource.name;
		msglabel.label = "Please report this to the developer!\n"+resource.subtype;
		return true;
	}
	
	public bool canHandleCurrentResource(){
		if (resource == null){
			return false;
		}else{
			return resource.resourcetype == Dragonstone.ResourceType.ERROR_URI_SCHEME_NOT_SUPPORTED;
		}
	}
	
}
