public interface Dragonstone.ISession : Object {
	public Dragonstone.Cache? get_cache() {return null;}
	public abstract bool set_default_backend(Dragonstone.ResourceStore store); //returns true on success
	public abstract Dragonstone.ResourceStore? get_default_backend();
	
	public abstract Dragonstone.Request make_request(string uri, bool reload=false);
	
}
