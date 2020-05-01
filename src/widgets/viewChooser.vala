public class Dragonstone.Widget.ViewChooser : Gtk.Bin {
	private Gtk.ComboBoxText combo_box = new Gtk.ComboBoxText();
	
	private Dragonstone.Tab? tab = null;
	private bool tab_changing = false;
	
	public ViewChooser(){
		add(combo_box);
		combo_box.sensitive = false;
		combo_box.changed.connect(on_change);
	}
	
	public void use_tab(Dragonstone.Tab? tab){
		tab_changing = true;
		if (this.tab != null){
			this.tab.view_chooser.scores_changed.disconnect(repopulate);
			this.tab.on_view_update.disconnect(update_active_id);
		}
		this.tab = tab;
		if (this.tab != null){
			repopulate();
			this.tab.view_chooser.scores_changed.connect(repopulate);
			this.tab.on_view_update.connect(update_active_id);
		} else {
			combo_box.sensitive = false;
		}
		tab_changing = false;
	}
	
	public void repopulate(){
		combo_box.sensitive = false;
		combo_box.remove_all();
		if (this.tab != null){
			foreach (string key in this.tab.view_chooser.matches.get_keys()){
				uint32 score = this.tab.view_chooser.matches.get(key);
				combo_box.append(key,@"$key [$score]");
			}
			update_active_id();
			combo_box.sensitive = true;
		}
	}
	
	public void update_active_id(){
		if (this.tab != null){
			combo_box.set_active_id(this.tab.current_view_id);
		}
	}
	
	private void on_change(){
		if (this.tab != null && !tab_changing){
			string? id = combo_box.get_active_id();
			if (id != null){
				this.tab.update_view(id);
			}
		}
	}
}
