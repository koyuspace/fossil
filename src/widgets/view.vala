public interface Dragonstone.IView : Gtk.Widget {
	//returns true if the view rendered successfully, false if not
	//only has to work once per View object
	//if the view has nothing special to offer as a subview it can safely igore the as_subview field
	public abstract bool displayResource(Dragonstone.Request request, Dragonstone.Tab tab, bool as_subview);
	//returns if the view can still handle the current resource
	public abstract bool canHandleCurrentResource(); 
	//tells the View to unhook from all resource and request signal it may be hooked up to
	//and clean up after itself
	public virtual void cleanup(){}
}

public interface Dragonstone.IViewPersistant : Object {
	public abstract bool import(string data);
	public abstract string? export();
}
