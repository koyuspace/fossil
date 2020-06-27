public interface Dragonstone.Settings.Provider : Object {
	
	public abstract bool has_object(string id);
	public abstract Dragonstone.Settings.Rom? get_object(string id);
	
	public abstract bool can_upload_object(string id);
	public abstract bool upload_object(string id, string content);
	
}

public interface Dragonstone.Settings.Bridge : Object {
	
	public abstract bool import(Dragonstone.Settings.Provider settings_provider);
	public abstract bool export(Dragonstone.Settings.Provider settings_provider);
	
	//returns true if the data the bride is responsible for has been modified since the last export or import
	public abstract bool is_dirty();
	
}

//This rom architecture is inspired by genode
public class Dragonstone.Settings.RomProvider : Object {

	private string _content;
	public string content {
		set {
			_content = value;
			this.updated();
		}
		get {
			return _content;
		}
	}
	public signal void updated();
	
	public RomProvider(string initial_content){
		this._content = initial_content;
	}
	
}

public class Dragonstone.Settings.Rom : Object {
	
	private Dragonstone.Settings.RomProvider provider;
	public string content { get; protected set; }
	public signal void update_avaiable();
	
	public Rom(Dragonstone.Settings.RomProvider provider){
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
