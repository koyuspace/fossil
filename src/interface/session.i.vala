public interface Dragonstone.Interface.Session : Object {

	public virtual Dragonstone.Interface.Cache? get_cache() { return null; }
	public abstract bool set_default_backend(Dragonstone.Interface.ResourceStore store); //returns true on success
	public abstract Dragonstone.Interface.ResourceStore? get_default_backend();
	
	public abstract Dragonstone.Request make_download_request(string uri, bool reload=false);
	public abstract Dragonstone.Request make_upload_request(string uri, Dragonstone.Resource resource, out string upload_urn = null);
	
	public virtual void erase_cache() {}
	
	public abstract void set_name(string name);
	public abstract string get_name();
	
}