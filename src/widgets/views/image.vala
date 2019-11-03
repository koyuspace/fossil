public class Dragonstone.View.Image : Gtk.ScrolledWindow, Dragonstone.IView {
	
	private Dragonstone.Resource resource = null;
	private Gtk.Image image;
	
	construct {}
	
	public bool displayResource(Dragonstone.Resource resource,Dragonstone.Tab tab){
		if (
			(resource.resourcetype == Dragonstone.ResourceType.STATIC ||
			resource.resourcetype == Dragonstone.ResourceType.DYNAMIC) &&
			resource.subtype.has_prefix("image/")
				){
			if (resource is Dragonstone.IResourceData){
				unowned List<Bytes>? list = (resource as Dragonstone.IResourceData).getData();
				if( list == null ){return false;}
				try{
					var pixbufloader = new Gdk.PixbufLoader();
					var length = list.length();
					for(var i = 0;i<length;i++){
						unowned Bytes bytes = list.nth_data(i);
						if (bytes != null){
							print(@"$i:lenght: $(bytes.length)\n");
							pixbufloader.write(bytes.get_data());
						} else {
							print(@"$i:bytes = null\n");
						}
					}
					pixbufloader.close();
					var pixbuf = pixbufloader.get_pixbuf();
					image = new Gtk.Image.from_pixbuf(pixbuf);
					add(image);
				} catch (GLib.Error e) {
					print("ERROR: while reading image into pixbuf: "+e.message+"\n");
				}
			} else {
				return false;
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
				resource.subtype.has_prefix("image/") &&
				(resource is Dragonstone.IResourceData);
		}
	}
	
}
