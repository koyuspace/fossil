public interface Dragonstone.Interface.Page.Service.LinearHistory : Object {

	public abstract void go_back();
	public abstract bool can_go_back();
	public virtual string? get_next_past_uri(){ return null; }
	//will iterate over the past uris in reverse cronological order
	public virtual void foreach_past_uri(Func<string> cb){ return; }
	
	public abstract void go_forward();
	public abstract bool can_go_forward();
	public virtual string? get_next_future_uri(){ return null; }
	// will iterate over the future uris in cronological order
	public virtual void foreach_future_uri(Func<string> cb){ return; }
	
}
