public class Dragonstone.View.Geminitext : Dragonstone.Widget.TextContent, Dragonstone.IView {
	
	private Dragonstone.Request request = null;
	
	public bool displayResource(Dragonstone.Request request,Dragonstone.Tab tab){
		if (request.status == "success" && request.resource.mimetype.has_prefix("text/gemini")){
			var file = File.new_for_path(request.resource.filepath);
			if (!file.query_exists ()) {
        this.textview.buffer.text ="The cache file for this resource does not exist!\nReloading the page should help,\nif not please contact the developer!";
    	}
    	try{
				//parse text
				
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
						this.appendWidget(new Dragonstone.Widget.LinkButton(tab,htext,uri));
						isText = false;
					}
					if (isText){
						this.appendText(line+"\n");
					}
				}
			}catch (GLib.Error e) {
				this.appendWidget(new Gtk.Label("Error while rendering gemini content:\n"+e.message));
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
