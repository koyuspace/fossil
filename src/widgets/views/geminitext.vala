public class Dragonstone.View.Geminitext : Gtk.ScrolledWindow, Dragonstone.IView {
	
	private Dragonstone.Resource resource = null;
	private Gtk.Box content;
	
	construct {
		content = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		content.homogeneous = false;
		content.halign = Gtk.Align.START;
		content.valign = Gtk.Align.START;
		//content.get_style_context().add_class("textview.view");
		//content.editable = false;
		//content.wrap_mode = Gtk.WrapMode.WORD;
		//content.set_monospace(true);
		add(content);
	}
	
	public bool displayResource(Dragonstone.Resource resource,Dragonstone.Tab tab){
		if (
			(resource.resourcetype == Dragonstone.ResourceType.STATIC ||
			resource.resourcetype == Dragonstone.ResourceType.DYNAMIC) &&
			resource.subtype.has_prefix("text/gemini")
				){
			string? text = null;
			if (resource is Dragonstone.IResourceText){
				text = (resource as Dragonstone.IResourceText).getText();
			} else if (resource is Dragonstone.IResourceData){
				text = (resource as Dragonstone.IResourceData).getDataAsString();
			}
			if( text == null ){return false;}
			//parse text
			Gtk.Label lastlabel = null;
			string[] lines = text.split("\n");
			foreach(unowned string line in lines){
				//parse geminis simple markup
				bool isText = true;
				if (line.has_prefix("=>")){
					if (line.get(2) == ' ' || line.get(2) == '\t'){
						var uri = "";
						var htext = "";
						var uri_and_text = line.substring(3).strip();
						var spaceindex = uri_and_text.index_of_char(' ');
						var tabindex = uri_and_text.index_of_char('\t');
						if (spaceindex < 0 && tabindex < 0){
							uri = uri_and_text;
							htext = uri_and_text;
						} else if ((tabindex > 0 && tabindex < spaceindex) || spaceindex < 0){
							uri = uri_and_text.substring(0,tabindex);
							htext = uri_and_text.substring(tabindex).strip();
						} else if ((spaceindex > 0 && spaceindex < tabindex) || tabindex < 0){
							uri = uri_and_text.substring(0,spaceindex);
							htext = uri_and_text.substring(spaceindex).strip();
						}
						this.content.pack_start(new Dragonstone.Widget.LinkButton(tab,htext,uri));
						isText = false;
					}
				}
				if (isText && lastlabel == null){
					lastlabel = new Gtk.Label("");
					lastlabel.valign = Gtk.Align.START;
					lastlabel.halign = Gtk.Align.START;
					lastlabel.selectable = true;
					var fontdesc = new Pango.FontDescription();
					fontdesc.set_family("monospace");
					lastlabel.override_font(fontdesc);
					this.content.pack_start(lastlabel);
					lastlabel.margin_start = 4;
					lastlabel.label = lastlabel.label+line;
				} else if (isText){
					lastlabel.label = lastlabel.label+"\n"+line;
				} else {
					lastlabel = null;
				}
			}
			
		} else {
			return false;
		}
		this.resource = resource;
		return true;
	}
	
	public bool canHandleCurrentResource(){
		if (resource == null){
			return false;
		}else{
			return 
				(resource.resourcetype == Dragonstone.ResourceType.STATIC ||
				resource.resourcetype == Dragonstone.ResourceType.DYNAMIC) &&
				resource.subtype.has_prefix("text/gemini") &&
				(resource is Dragonstone.IResourceData);
		}
	}
	
}
