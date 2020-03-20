public class Dragonstone.View.Geminitext : Gtk.ScrolledWindow, Dragonstone.IView {
	
	private Dragonstone.Request request = null;
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
	
	public bool displayResource(Dragonstone.Request request,Dragonstone.Tab tab){
		if (request.status == "success" && request.resource.mimetype.has_prefix("text/gemini")){
			var file = File.new_for_path(request.resource.filepath);
			if (!file.query_exists ()) {
        this.content.pack_start(new Gtk.Label("The cache file for this resource does not exist!\nReloading the page should help,\nif not please contact the developer!"));
    	}
    	try{
				//parse text
				Gtk.Label lastlabel = null;
				var dis = new DataInputStream (file.read ());
        string line;
				while ((line = dis.read_line (null)) != null) {
					//parse geminis simple markup
					bool isText = true;
					if (line.has_prefix("=>")){
						var uri = "";
						var htext = "";
						var uri_and_text = line.substring(2).strip();
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
					if (isText && lastlabel == null){
						lastlabel = new Gtk.Label("");
						lastlabel.valign = Gtk.Align.START;
						lastlabel.halign = Gtk.Align.START;
						lastlabel.selectable = true;
						//lastlabel.wrap_mode = Pango.WrapMode.WORD;
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
			}catch (GLib.Error e) {
				this.content.pack_start(new Gtk.Label("ERROR reading cache file:\n"+e.message));
			}
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
			return request.status == "success" && request.resource.mimetype.has_prefix("text/gemini");
		}
	}
	
}
