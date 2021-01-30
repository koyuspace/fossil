public class Dragonstone.Interface.Settings.Rom : Object {
	
	private Dragonstone.Interface.Settings.RomProvider provider;
	public string content { get; protected set; }
	public signal void update_avaiable();
	
	public Rom(Dragonstone.Interface.Settings.RomProvider provider){
		this.provider = provider;
		this.provider.updated.connect(this.on_updated);
		this.pull_update();
	}
	
	~Rom() {
		this.provider.updated.disconnect(this.on_updated);
	}
	
	private void on_updated(){
		this.update_avaiable();
	}
	
	public void pull_update(){
		this.content = this.provider.content;
	}
}
