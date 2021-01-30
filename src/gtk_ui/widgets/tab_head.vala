//the widget, that you can see on the top tab, where you can select wich tab to see
public class Dragonstone.GtkUi.Widget.TabHead : Gtk.Box {
	private Gtk.Button closeButton;
	private Gtk.Label title = new Gtk.Label("💫️ New Tab");
	private Dragonstone.Tab tab;
	private Gtk.Spinner spinner = new Gtk.Spinner();
	private int title_chars = 25;
	
	public TabHead(Dragonstone.Tab tab) {
		closeButton = new Gtk.Button.from_icon_name("window-close-symbolic");
		closeButton.relief = Gtk.ReliefStyle.NONE;
		this.orientation = Gtk.Orientation.HORIZONTAL;
		pack_start(spinner);
		pack_start(title);
		pack_end(closeButton);
		set_child_packing(spinner,false,true,0,Gtk.PackType.START);
		set_child_packing(title,true,true,0,Gtk.PackType.START);
		set_child_packing(closeButton,false,true,0,Gtk.PackType.END);
		show_all();
		closeButton.clicked.connect(tab.close);
		this.tab = tab;
		this.tab.on_cleanup.connect(this.detach);
		this.tab.on_title_change.connect(this.refresh_title);
		refresh_title();
	}
	
	public void refresh_title(){
		spinner.active = tab.loading;
		spinner.visible = tab.loading;
		string title = tab.title;
		if (title.char_count() > title_chars){
			var startcut = title.index_of_nth_char(title_chars/2);
			var endcut = title.index_of_nth_char(title.char_count()-(title_chars/2));
			title = title[0:startcut]+"…"+title.slice(endcut,title.length);
		}
		this.title.label = title;
	}
	
	public void detach(){
		tab.on_cleanup.disconnect(detach);
		tab.on_title_change.disconnect(refresh_title);
	}
	
}
