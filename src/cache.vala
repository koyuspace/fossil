public interface Dragonstone.Cache : Dragonstone.ResourceStore {
	
	public abstract bool can_serve_request(string uri,int64 maxage = 0);
	
	public abstract void put_resource(Dragonstone.Resource resource);
	
	public abstract void erase();
}
