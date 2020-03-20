public class Dragonstone.View.Geminitext : Gtk.ScrolledWindow, Dragonstone.IView {
	
	private Dragonstone.Request request = null;
	private Gtk.TextView textview = null;
	
	construct {
		textview = new Gtk.TextView();
		textview.editable = false;
		textview.wrap_mode = Gtk.WrapMode.WORD;
		textview.set_monospace(true);
		textview.set_left_margin(4);
		add(textview);
	}
	
	public bool displayResource(Dragonstone.Request request,Dragonstone.Tab tab){
		if (request.status == "success" && request.resource.mimetype.has_prefix("text/gemini")){
			var file = File.new_for_path(request.resource.filepath);
			if (!file.query_exists ()) {
        this.textview.buffer.text ="The cache file for this resource does not exist!\nReloading the page should help,\nif not please contact the developer!";
    	}
    	try{
				//parse text
				var buffer = textview.buffer;
				
				var dis = new DataInputStream (file.read ());
        string line;
				while ((line = dis.read_line (null)) != null) {
					//parse geminis simple markup
					bool isText = true;
					Gtk.TextIter end_iter;
					buffer.get_end_iter(out end_iter);
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
						var anchor = buffer.create_child_anchor(end_iter);
						textview.add_child_at_anchor(new Dragonstone.Widget.LinkButton(tab,htext,uri),anchor);
						isText = false;
					}
					if (isText){
						buffer.insert(ref end_iter,line+"\n",line.length+1);
					}
				}
			}catch (GLib.Error e) {
				print("Error while rendering gemini content:\n"+e.message);
				/*Gtk.TextIter end_iter;
				textview.buffer.get_end_iter(out end_iter);;
				textview.buffer.insert(end_iter,e.message,e.message.length);*/
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
