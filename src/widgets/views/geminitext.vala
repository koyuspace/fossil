public class Dragonstone.View.Geminitext : Dragonstone.Widget.HyperTextContent, Dragonstone.IView {
	
	private Dragonstone.Request request = null;
	private DataInputStream data_input_stream;
	private Dragonstone.Tab tab;
	
	public bool displayResource(Dragonstone.Request request,Dragonstone.Tab tab){
		this.tab = tab;
		this.link_popover = new Dragonstone.Widget.LinkButtonPopover(tab);
		if (request.status == "success" && request.resource.mimetype.has_prefix("text/gemini")){
			var file = File.new_for_path(request.resource.filepath);
			if (!file.query_exists ()) {
        this.textview.buffer.text ="The cache file for this resource does not exist!\nReloading the page should help,\nif not please contact the developer!";
			}
			try{
				//parse text
				
				data_input_stream = new DataInputStream (file.read ());
				render_batch(30000);
				
			}catch (GLib.Error e) {
				this.append_widget(new Gtk.Label("Error while rendering gemini content:\n"+e.message));
			}
		} else {
			return false;
		}
		this.request = request;
		this.go.connect(on_go_event);
		return true;
	}
	
	//returns true when finished
	private bool render_batch(int lines) {
		try{
			int linecounter = 0;
			string line;
			while ((line = data_input_stream.read_line (null)) != null) {
				//print(@"GEMINI: $line\n");
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
					this.append_link(htext,uri);
					this.append_text("\n");
					isText = false;
				}
				if (isText){
					this.append_text(line+"\n");
				}
				linecounter++;
				if (linecounter >= lines){
					return false;
				}
			}
		}catch (GLib.Error e) {
			this.append_widget(new Gtk.Label("Error while rendering gemini content:\n"+e.message));
		}
		show_all();
		return true;
	}
	
	public bool canHandleCurrentResource(){
		if (request == null){
			return false;
		}else{
			return request.status == "success" && request.resource.mimetype.has_prefix("text/gemini");
		}
	}
	
	protected void on_go_event(string uri, bool alt){
		if (this.tab != null){
			if (alt){
				tab.open_uri_in_new_tab(uri);
			} else {
				tab.go_to_uri(uri);
			}
		}
	}
	
}
