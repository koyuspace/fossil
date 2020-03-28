public interface Dragonstone.IView : Gtk.Widget {
	//returns true if the view rendered successfully, false if not
	//only has to work once per View object
	public abstract bool displayResource(Dragonstone.Request request,Dragonstone.Tab tab);
	//returns if the view can still handle the current resource
	public abstract bool canHandleCurrentResource(); 
	//tells the View to unhook from all resource and request signal it may be hooked up to
	//and clean up after itself
	public virtual void cleanup(){}
}
