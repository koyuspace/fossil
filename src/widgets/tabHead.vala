//the widget, that you can see on the top tab, where you can select wich tab to see
public class Dragonstone.Widget.TabHead : Gtk.Bin {
	private Gtk.Button closeButton;
	private Gtk.Label title = new Gtk.Label("💫️ New Tab");
	private Dragonstone.Tab tab;
	
	public TabHead(Dragonstone.Tab tab) {
		closeButton = new Gtk.Button.from_icon_name("window-close-symbolic");
		closeButton.relief = Gtk.ReliefStyle.NONE;
		var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL,1);
		box.pack_start(title);
		box.pack_end(closeButton);
		add(box);
		box.show_all();
		closeButton.clicked.connect(tab.close);
		this.tab = tab;
		this.tab.on_cleanup.connect(this.detach);
		this.tab.on_title_change.connect(this.refreshTitle);
		refreshTitle();
	}
	
	public void refreshTitle(){
		string title = tab.title;
		if (title.char_count() > 40){
			var startcut = title.index_of_nth_char(20);
			var endcut = title.index_of_nth_char(title.char_count()-20);
			title = title[0:startcut]+"…"+title.slice(endcut,title.length);
		}
		this.title.label = title;
	}
	
	public void detach(){
		tab.on_cleanup.disconnect(detach);
		tab.on_title_change.disconnect(refreshTitle);
	}
	
}
