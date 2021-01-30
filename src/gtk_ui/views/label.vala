public class Dragonstone.GtkUi.View.Label : Gtk.Bin, Dragonstone.GtkUi.Interface.View {
	
	public Label(string message){
		add(new Gtk.Label(message));
		show_all();
	}

	public bool displayResource(Dragonstone.Request request, Dragonstone.Tab tab, bool as_subview){
		return true;
	}
	
	public bool canHandleCurrentResource(){
		return false;
	}
}
