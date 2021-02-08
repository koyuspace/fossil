//the widget, that you can see on the top tab, where you can select wich tab to see
public class Dragonstone.GtkUi.Widget.TabHead : Gtk.Box {
	private Gtk.Button close_button;
	private Gtk.Label title = new Gtk.Label("💫️ New Tab");
	private Dragonstone.GtkUi.Tab tab;
	private Gtk.Spinner spinner = new Gtk.Spinner();
	private Gtk.Image error_icon = new Gtk.Image.from_icon_name("dialog-error", Gtk.IconSize.LARGE_TOOLBAR);
	private int title_chars = 25;
	
	public TabHead(Dragonstone.GtkUi.Tab tab) {
		close_button = new Gtk.Button.from_icon_name("window-close-symbolic");
		close_button.relief = Gtk.ReliefStyle.NONE;
		this.orientation = Gtk.Orientation.HORIZONTAL;
		pack_start(spinner);
		pack_start(error_icon);
		pack_start(title);
		pack_end(close_button);
		set_child_packing(spinner, false, true, 0, Gtk.PackType.START);
		set_child_packing(title, true, true, 0, Gtk.PackType.START);
		set_child_packing(close_button, false, true, 0, Gtk.PackType.END);
		show_all();
		close_button.clicked.connect(tab.close);
		this.tab = tab;
		this.tab.on_cleanup.connect(this.detach);
		this.tab.on_title_change.connect(this.refresh_title);
		refresh_title(tab.title, tab.display_state);
	}
	
	public void refresh_title(string title, Dragonstone.Ui.TabDisplayState state){
		spinner.active = state == LOADING;
		spinner.visible = state == LOADING;
		error_icon.visible = state == ERROR;
		if (title.char_count() > title_chars){
			if (title == tab.uri){
				var startcut = title.index_of_nth_char(title_chars/2);
				var endcut = title.index_of_nth_char(title.char_count()-(title_chars/2));
				this.title.label = title[0:startcut]+"…"+title.slice(endcut,title.length);
			} else {
				var cutat = title.index_of_nth_char(title_chars);
				this.title.label = title[0:cutat]+"…";
			}
		} else {
			this.title.label = title;
		}
		if (title == tab.uri){
			this.tooltip_text = title;
		} else {
			this.tooltip_markup = "<b>"+Markup.escape_text(title)+"</b>\n"+Markup.escape_text(tab.uri);
		}
	}
	
	public void detach(){
		tab.on_cleanup.disconnect(detach);
		tab.on_title_change.disconnect(refresh_title);
	}
	
}
