public interface Dragonstone.Interface.Cache : Dragonstone.Interface.ResourceStore {
	
	public abstract bool can_serve_request(string uri,int64 maxage = 0);
	
	public abstract void put_resource(Dragonstone.Resource resource);
	
	public abstract void invalidate_for_uri(string uri);
	
	public abstract void erase();
}