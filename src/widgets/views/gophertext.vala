public class Dragonstone.View.Gophertext : Gtk.ScrolledWindow, Dragonstone.IView {
	
	private Dragonstone.Resource resource = null;
	private Gtk.Box content;
	
	construct {
		content = new Gtk.Box(Gtk.Orientation.VERTICAL,1);
		content.homogeneous = false;
		content.halign = Gtk.Align.START;
		content.valign = Gtk.Align.START;
		content.get_style_context().add_class("textview.view");
		//content.editable = false;
		//content.wrap_mode = Gtk.WrapMode.WORD;
		//content.set_monospace(true);
		add(content);
	}
	
	public bool displayResource(Dragonstone.Resource resource,Dragonstone.Tab tab){
		if (
			(resource.resourcetype == Dragonstone.ResourceType.STATIC ||
			resource.resourcetype == Dragonstone.ResourceType.DYNAMIC) &&
			resource.subtype.has_prefix("text/gopher")
				){
			string? text = null;
			if (resource is Dragonstone.IResourceText){
				text = (resource as Dragonstone.IResourceText).getText();
			} else if (resource is Dragonstone.IResourceData){
				text = (resource as Dragonstone.IResourceData).getDataAsString();
			}
			if( text == null ){return false;}
			//parse text
			char lasttype = '\0';
			Gtk.Label lastlabel = null;
			string[] lines = text.split("\n");
			foreach(unowned string line in lines){
				var tokens = line.split("\t");
				if(tokens.length == 4){//valid line
					char gophertype = 'i';
					string htext = "";
					if (tokens[0].length != 0){
						gophertype = tokens[0].get(0);
						htext = tokens[0].substring(1);//human text
					}
					var query = tokens[1].strip(); //look for url in here
					var host = tokens[2].strip();
					var port = tokens[3].strip();
					
					//
					if(gophertype == '+' && (gophertype == '0' || gophertype == '1' || gophertype == '9' || gophertype == '7')){
						gophertype = lasttype;
					}
					if (gophertype == 'i'){ //text
						if (lastlabel == null || lasttype != gophertype){
							lastlabel = new Gtk.Label("");
							lastlabel.valign = Gtk.Align.START;
							lastlabel.halign = Gtk.Align.START;
							lastlabel.selectable = true;
							var fontdesc = new Pango.FontDescription();
							fontdesc.set_family("monospace");
							lastlabel.override_font(fontdesc);
							this.content.pack_start(lastlabel);
							lastlabel.margin_start = 4;
							lastlabel.label = lastlabel.label+htext;
						}else{
							lastlabel.label = lastlabel.label+"\n"+htext;
						}
						
					}else if (gophertype == '0' || gophertype == '1' || gophertype == '9' || gophertype == 'g' || gophertype == 'I' || query.has_prefix("URL:")){
						string? uri = null;
						if (query.has_prefix("URL:")) {
							uri = query.substring(4);
						}else{
							if( port != "70" ){
								uri = @"gopher://$host:$port/$gophertype$query";
							}else{
								uri = @"gopher://$host/$gophertype$query";
							}
						}
						//print(@"URI:$uri\n");
						var icon_name = "go-jump-symbolic";
						if (gophertype == '0'){ //file
							icon_name = "text-x-generic-symbolic";
						} else if (gophertype == '1'){ //directory
							icon_name = "folder-symbolic";
						} else if (gophertype == '7'){ //search
							icon_name = "system-search-symbolic";
						} else if (gophertype == '9'){ //binary
							icon_name = "folder-download-symbolic";
						} else if (gophertype == 'g'){ //gif
							icon_name = "image-x-generic-symbolic";
						} else if (gophertype == 'I'){ //image
							icon_name = "image-x-generic-symbolic";
						}
						if (uri.has_prefix("http")){
							icon_name = "text-html-symbolic";
						} else if (uri.has_prefix("mailto:")){
							icon_name = "mail-message-new-symbolic";
						}
						//make link and add it
						//TODO: right click menu with a copy to clipvoaed option
						var linkwidget = new Dragonstone.View.GophertextLinkDisplay(htext,uri,icon_name);
						var button = new Gtk.Button();//.with_label(@"$htext [$uri]");
						button.halign = Gtk.Align.START;
						button.clicked.connect((s) => {
							tab.goToUri(uri);
						});
						button.add(linkwidget);
						button.set_relief(Gtk.ReliefStyle.NONE);
						this.content.pack_start(button);
					} else if (gophertype == '7'){ //Search
						string? uri = null;
						if( port != "70" ){
							uri = @"gopher://$host:$port/$gophertype$query";
						}else{
							uri = @"gopher://$host/$gophertype$query";
						}
						var searchfield = new Dragonstone.View.GophertextInlineSearch(htext,uri);
						searchfield.go.connect(tab.goToUri);
						this.content.pack_start(searchfield);
					} else if (gophertype == '3'){ //Error
						this.content.pack_start(
							new Dragonstone.View.GophertextIconLabel(htext,"dialog-error-symbolic")
						);
					} else {
						this.content.pack_start(
							new Dragonstone.View.GophertextUnknownItem(gophertype,htext,query,host,port)
						);
					}
					lasttype = gophertype;
				}else if(tokens.length == 0){ //empty line, ignore
				}else{ //invalid line
				
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
				resource.subtype.has_prefix("text/gopher") &&
				(resource is Dragonstone.IResourceData);
		}
	}
	
}

private class Dragonstone.View.GophertextLinkDisplay : Gtk.Bin {
	public GophertextLinkDisplay(string name,string uri,string icon_name){
		var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL,4);
		box.homogeneous = false;
		var label = new Gtk.Label(@"$name [$uri]");
		label.selectable = true;
		label.halign = Gtk.Align.START;
		var labelAttrList = new Pango.AttrList();
		labelAttrList.insert(new Pango.AttrSize(12000));
		label.attributes = labelAttrList;
		var icon = new Gtk.Image.from_icon_name(icon_name,Gtk.IconSize.LARGE_TOOLBAR);
		icon.halign = Gtk.Align.START;
		box.pack_start(icon);
		box.pack_start(label);
		box.halign = Gtk.Align.START;
		add(box);
	}
}

private class Dragonstone.View.GophertextInlineSearch : Gtk.Bin {

	public signal void go(string uri);
	private string base_uri;
	private Gtk.Entry entry;
	
	public GophertextInlineSearch(string htext,string uri){
		base_uri = uri;
		var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL,4);
		box.homogeneous = false;
		box.margin_start = 4;
		entry = new Gtk.Entry();
		entry.placeholder_text = htext;
		//entry.halign = Gtk.Align.FILL;
		entry.activate.connect(submit);
		entry.expand = true;
		//var icon = new Gtk.Image.from_icon_name("system-search-symbolic",Gtk.IconSize.LARGE_TOOLBAR);
		//icon.halign = Gtk.Align.START;
		var button = new Gtk.Button.from_icon_name("go-next-symbolic");
		button.clicked.connect(submit);
		button.halign = Gtk.Align.START;
		//box.pack_start(icon);
		box.pack_start(entry);
		box.pack_start(button);
		box.halign = Gtk.Align.FILL;
		add(box);
	}
	
	private void submit(){
		if (entry.text != ""){
			var searchstring = entry.text.replace("\t","%09");
			go(@"$base_uri\t$searchstring");
		}
	}
}

private class Dragonstone.View.GophertextUnknownItem : Gtk.Bin {
	public GophertextUnknownItem(char gophertype,string htext,string query,string host,string port){
		var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL,4);
		box.homogeneous = false;
		box.margin_start = 4;
		var label = new Gtk.Label(@"Unknown Item Type: '$gophertype' -> $host:$port/$query\n$htext");
		label.selectable = true;
		label.halign = Gtk.Align.START;
		//var labelAttrList = new Pango.AttrList();
		//labelAttrList.insert(new Pango.AttrSize(8000));
		//label.attributes = labelAttrList;
		var icon = new Gtk.Image.from_icon_name("dialog-question-symbolic",Gtk.IconSize.BUTTON);
		icon.halign = Gtk.Align.START;
		box.pack_start(icon);
		box.pack_start(label);
		box.halign = Gtk.Align.START;
		add(box);
	}
}

//gopher://khzae.net/1/poll/1556462960/vote?CARTOON NETWORK WEBSITE GOT HACKED??? NO!!!!!!!!!!!
// /\ for testing putposes
private class Dragonstone.View.GophertextIconLabel : Gtk.Bin {
	public GophertextIconLabel(string text,string icon_name){
		var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL,4);
		box.margin_start = 8; 
		box.homogeneous = false;
		var label = new Gtk.Label(text);
		label.selectable = true;
		label.halign = Gtk.Align.START;
		var labelAttrList = new Pango.AttrList();
		labelAttrList.insert(new Pango.AttrSize(10000));
		label.attributes = labelAttrList;
		var icon = new Gtk.Image.from_icon_name(icon_name,Gtk.IconSize.BUTTON);
		icon.halign = Gtk.Align.START;
		box.pack_start(icon);
		box.pack_start(label);
		box.halign = Gtk.Align.START;
		add(box);
	}
}
