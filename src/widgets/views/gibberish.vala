public class Dragonstone.View.Gibberish : Gtk.Bin, Dragonstone.IView {
	
	private Dragonstone.Resource resource = null;
	private Gtk.Label nameLabel = new Gtk.Label("");
	
	construct {
		nameLabel.valign = Gtk.Align.START;
		var outerBox = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		var centerBox = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		var label = new Gtk.Label("Gibberish"); //TOTRANSLATE
		var sublabel = new Gtk.Label("Looks beatiful, but I have no way\nof showing it to you :("); //TOTRANSLATE
		var icon = new Gtk.Image.from_icon_name("dialog-question-symbolic",Gtk.IconSize.DIALOG);
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
		if (!(resource.resourcetype == Dragonstone.ResourceType.ERROR_GIBBERISH)) {return false;}
		this.resource = resource;
		//nameLabel.label = resource.name;
		return true;
	}
	
	public bool canHandleCurrentResource(){
		if (resource == null){
			return false;
		}else{
			return resource.resourcetype == Dragonstone.ResourceType.ERROR_GIBBERISH;
		}
	}
	
}
