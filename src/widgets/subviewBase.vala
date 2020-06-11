public class Dragonstone.Widget.SubviewBase : Gtk.Box {
	
	public Gtk.Button backbutton = new Gtk.Button.from_icon_name("go-previous-symbolic");
	public Gtk.HeaderBar titlebar = new Gtk.HeaderBar();
	
	public SubviewBase (string title = ""){
		this.orientation = Gtk.Orientation.VERTICAL;
		titlebar.title = title;
		titlebar.show_close_button = false;
		titlebar.has_subtitle = false;
		titlebar.pack_start(backbutton);
		this.pack_start(titlebar);
		this.set_child_packing(titlebar,false,true,0,Gtk.PackType.START);
	}
	
	public void append_child(Gtk.Widget widget){
		this.pack_start(widget);
		this.set_child_packing(widget,false,true,0,Gtk.PackType.START);
	}
	
	public void set_title(string title){
		titlebar.title = title;
	}
}
