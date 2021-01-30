public interface Dragonstone.Interface.Settings.Provider : Object {
	
	public abstract bool has_object(string id);
	public abstract Dragonstone.Interface.Settings.Rom? get_object(string id);
	
	public abstract bool can_upload_object(string id);
	public abstract bool upload_object(string id, string content);
	
}
