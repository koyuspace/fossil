public interface Dragonstone.IView : Gtk.Widget {
	public abstract bool displayResource(Dragonstone.Request request,Dragonstone.Tab tab);
	//returns true if the view rendered successfully, false if not
	public abstract bool canHandleCurrentResource(); 
	//returns if the view can still handle the current resource
}
