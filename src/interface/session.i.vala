public interface Fossil.Interface.Session : Object {

	public virtual Fossil.Interface.Cache? get_cache() { return null; }
	public abstract bool set_default_backend(Fossil.Interface.ResourceStore store); //returns true on success
	public abstract Fossil.Interface.ResourceStore? get_default_backend();
	
	public abstract Fossil.Request make_download_request(string uri, bool reload=false);
	public abstract Fossil.Request make_upload_request(string uri, Fossil.Resource resource, out string upload_urn = null);
	
	public virtual void erase_cache() {}
	
	public abstract void set_name(string name);
	public abstract string get_name();
	
}
