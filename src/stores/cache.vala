public class Dragonstone.Store.Cache : Object, Dragonstone.ResourceStore, Dragonstone.Cache{
	
	public HashTable<string,Dragonstone.Resource> cached_resources { get; protected set; }
	
	construct {
		cached_resources = new HashTable<string,Dragonstone.Resource>(str_hash, str_equal);
		Timeout.add(1000*60*5,() => { //clean cache
			print("[cache] Cleaning Up!\n");
			clean();
			return true;
		},Priority.LOW);
	}
	
	public void request(Dragonstone.Request request,string? filepath = null, bool upload = false){
		if (upload){
			request.setStatus("error/noupload","Uploding not supported");
			request.finish();
			return;
		}
		var resource = cached_resources.get(request.uri); //let's hope this is threadsafe
		if(resource == null) {
			request.setStatus("error/resourceUnavaiable");
			request.finish();
		}
		request.setResource(resource,"cache");
	}
	
	//if maxage is 0 assume the age doesn't matter
	//maxge is in milliseconds
	public bool can_serve_request(string uri,int64 maxage = 0){
		print(@"[cache] can serve request? URI:$uri MAXAGE:$maxage\n");
		var resource = cached_resources.get(uri); //let's hope this is threadsafe
		if(resource == null) { print("[cache] No, beacause resource is not cached.\n"); return false; }
		if(resource.filepath == null) { print("[cache] No, beacause resource is not cached anymore.\n"); return false; }
		//No, I'm not a LISP developer.
		if (((resource.valid_until - (GLib.get_real_time()/1000)) < 0) && (resource.valid_until != int64.MAX)){ print("[cache] No, beacause resource is not valid anymore.\n"); return false; }
		if(maxage > 0){ return resource.timestamp+maxage >= (GLib.get_real_time()/1000); }
		return true;
	}
	
	public void put_resource(Dragonstone.Resource resource){
		if (will_cache_resource(resource)){
			print(@"[cache] put resource $(resource.uri) fully loaded at $(resource.timestamp) valid until $(resource.valid_until)\n");
			resource.increment_users("cache");
			lock (cached_resources){
				var old_resource = cached_resources.get(resource.uri);
				if (old_resource != null){ old_resource.decrement_users("cache"); }
				cached_resources.set(resource.uri,resource);
			}
		}
	}
	
	private bool will_cache_resource(Dragonstone.Resource resource){
		if(resource.valid_until == 0){ return false; }
		if(!resource.is_temporary){ return false; } //permanent resoureces are already in the filesystem and fetched fast
		if(resource.filepath == null){ return false; }
		return true;
	}
	
	public void erase(){
		lock (cached_resources){
			foreach (Dragonstone.Resource resource in cached_resources.get_values()){
				resource.decrement_users("cache");
			}
			cached_resources.remove_all();
		}
	}
	
	public void clean(){
		//print(@"[cache] $(GLib.get_real_time()) | current time\n");
		lock (cached_resources){
			foreach (string uri in cached_resources.get_keys()){
				var resource = cached_resources.get(uri);
				bool clean = false;
				if (resource.filepath == null){ clean = true; }
				//print(@"[cache] $(resource.valid_until) | $uri");
				if (resource.valid_until < (GLib.get_real_time()/1000)){ clean = true; }
				//print(@" [$clean]\n");
				if (clean){
					resource.decrement_users("cache");
					cached_resources.remove(uri);
				}
			}
		}
	}
	
	public void invalidate_for_uri(string uri){
		lock (cached_resources){
			var resource = cached_resources.get(uri);
			if (resource != null){
				resource.decrement_users("cache");
				cached_resources.remove(uri);
			}
		}
	}
}
