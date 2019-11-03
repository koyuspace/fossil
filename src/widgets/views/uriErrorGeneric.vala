public class Dragonstone.View.UriError.Generic : Gtk.Bin, Dragonstone.IView {
	
	private Dragonstone.Resource resource = null;
	private Gtk.Label nameLabel = new Gtk.Label("");
	private Gtk.Label sublabel; 
	
	construct {
		nameLabel.valign = Gtk.Align.START;
		var outerBox = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		var centerBox = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		var label = new Gtk.Label("Invalid URI"); //TOTRANSLATE
		sublabel = new Gtk.Label(@"Something went wrong while\nparsing a URL/URI"); //TOTRANSLATE
		sublabel.justify = Gtk.Justification.CENTER;
		var icon = new Gtk.Image.from_icon_name("dialog-error-symbolic",Gtk.IconSize.DIALOG);
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
		outerBox.pack_start(nameLabel);
		var empty = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		outerBox.pack_end(empty);
		add(outerBox);
	}
	
	public bool displayResource(Dragonstone.Resource resource,Dragonstone.Tab tab){
		if (!(resource.resourcetype == Dragonstone.ResourceType.ERROR_URI_SCHEME_NOT_SUPPORTED)) {return false;}
		this.resource = resource;
		sublabel.label = @"Something went wrong parsing this\nas a $(resource.subtype) uri/url scheme.";
		//nameLabel.label = resource.name;
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
