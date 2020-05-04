public interface Dragonstone.Settings.Provider : Object {
	
	public bool has_object(string id);
	public string? get_object(string id);
	
	public bool can_upload_object(string id);
	public bool upload_object(string id);
	
}
