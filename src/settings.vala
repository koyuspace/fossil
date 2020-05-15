public interface Dragonstone.Settings.Provider : Object {
	
	public abstract bool has_object(string id);
	public abstract string? get_object(string id);
	
	public abstract bool can_upload_object(string id);
	public abstract bool upload_object(string id, string content);
	
}

public interface Dragonstone.Settings.Bridge : Object {
	
	public abstract bool import(Dragonstone.Settings.Provider settings_provider);
	public abstract bool export(Dragonstone.Settings.Provider settings_provider);
	
}
