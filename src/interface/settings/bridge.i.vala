public interface Dragonstone.Interface.Settings.Bridge : Object {
	
	public abstract bool import(Dragonstone.Interface.Settings.Provider settings_provider);
	public abstract bool export(Dragonstone.Interface.Settings.Provider settings_provider);
	
	//returns true if the data the bride is responsible for has been modified since the last export or import
	public abstract bool is_dirty();
	
}
