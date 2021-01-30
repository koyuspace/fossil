public class Dragonstone.Interface.Settings.RomProvider : Object {

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
