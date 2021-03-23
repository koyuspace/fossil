public interface Fossil.GtkUi.Interface.LegacyView : Gtk.Widget {
	//returns true if the view rendered successfully, false if not
	//only has to work once per View object
	//if the view has nothing special to offer as a subview it can safely igore the as_subview field
	public abstract bool display_resource(Fossil.Request request, Fossil.GtkUi.LegacyWidget.Tab tab, bool as_subview);
	//returns if the view can still handle the current resource
	public abstract bool canHandleCurrentResource(); 
	//tells the View to unhook from all resource and request signal it may be hooked up to
	//and clean up after itself
	public virtual void cleanup(){}
	
	public virtual bool import(string data){
		return false;
	}
	public virtual string? export(){
		return null;
	}
}
