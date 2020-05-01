public class Dragonstone.Widget.ViewChooser : Gtk.ComboBoxText {
	
	private Dragonstone.Tab? tab = null;
	private bool tab_changing = false;
	private bool id_changing = false;
	
	public ViewChooser(){
		this.sensitive = false;
		this.changed.connect(on_change);
	}
	
	public void use_tab(Dragonstone.Tab? tab){
		tab_changing = true;
		if (this.tab != null){
			this.tab.view_chooser.scores_changed.disconnect(repopulate);
			this.tab.on_view_change.disconnect(update_active_id);
		}
		this.tab = tab;
		if (this.tab != null){
			repopulate();
			this.tab.view_chooser.scores_changed.connect(repopulate);
			this.tab.on_view_change.connect(update_active_id);
		} else {
			this.sensitive = false;
		}
		tab_changing = false;
	}
	
	public void repopulate(){
		this.sensitive = false;
		this.remove_all();
		if (this.tab != null){
			foreach (string key in this.tab.view_chooser.matches.get_keys()){
				uint32 score = this.tab.view_chooser.matches.get(key);
				this.append(key,@"$key [$score]");
			}
			update_active_id();
			this.sensitive = true;
		}
	}
	
	public void update_active_id(){
		if (this.tab != null){
			id_changing = true;
			this.set_active_id(this.tab.current_view_id);
			id_changing = false;
		}
	}
	
	private void on_change(){
		if (this.tab != null && !tab_changing && !id_changing){
			string? id = this.get_active_id();
			if (id != null){
				this.tab.update_view(id,"view chooser");
			}
		}
	}
}
