public class Dragonstone.View.Image : Gtk.ScrolledWindow, Dragonstone.IView {
	
	private Dragonstone.Request request = null;
	private Gtk.Image image;
	
	construct {}
	
	public bool displayResource(Dragonstone.Request request,Dragonstone.Tab tab){
		if ((request.status == "success") && request.resource.mimetype.has_prefix("image/")){
			image = new Gtk.Image.from_file(request.resource.filepath);
			add(image);
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
			return (request.status == "success") && request.resource.mimetype.has_prefix("image/");
		}
	}
	
}
