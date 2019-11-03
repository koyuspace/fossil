public class Dragonstone.View.Label : Gtk.Bin, Dragonstone.IView {
	
	public Label(string message){
		add(new Gtk.Label(message));
	}

	public bool displayResource(Dragonstone.Resource resource,Dragonstone.Tab tab){
		return true;
	}
	
	public bool canHandleCurrentResource(){
		return true;
	}
}
