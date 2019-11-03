public class Dragonstone.View.Plaintext : Gtk.ScrolledWindow, Dragonstone.IView {
	
	private Dragonstone.Resource resource = null;
	private Gtk.TextView textview;
	
	construct {
		textview = new Gtk.TextView();
		textview.editable = false;
		textview.wrap_mode = Gtk.WrapMode.WORD;
		textview.set_monospace(true);
		textview.set_left_margin(4);
		add(textview);
	}
	
	public bool displayResource(Dragonstone.Resource resource,Dragonstone.Tab tab){
		if (
			(resource.resourcetype == Dragonstone.ResourceType.STATIC ||
			resource.resourcetype == Dragonstone.ResourceType.DYNAMIC) &&
			resource.subtype.has_prefix("text/")
				){
			string? text = null;
			if (resource is Dragonstone.IResourceText){
				text = (resource as Dragonstone.IResourceText).getText();
			} else if (resource is Dragonstone.IResourceData){
				text = (resource as Dragonstone.IResourceData).getDataAsString();
			}
			if( text == null ){return false;}
			textview.buffer.text = text;
			
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
				resource.subtype.has_prefix("text/") &&
				(resource is Dragonstone.IResourceData ||
				resource is Dragonstone.IResourceText);
		}
	}
	
}
