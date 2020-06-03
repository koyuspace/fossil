public class Dragonstone.Resource : Object {
	//requester
	public string uri { get; protected set; default = null;} //where did you find that one?
	public string filepath { get; protected set; default = null;} //the file, that contains the information
	//store
	public string mimetype { get; protected set; default = null;} //what does it contain?
	public int64 timestamp { get; set; default = 0;} //The unix time in milliseconds when the resource was fully loaded
	public string origin { get; protected set; default = null;} //who made it?
	public string metadata { get; protected set; default = null;} //cookies, certificates, identifiers
	public string name { get; protected set; default = "";}
	//cache
	public int64 valid_until { get; set; default = 0;} //The unix time in milliseconds when the resource is invlid in cache, do not cache if 0, valid for forever if int64.MAX
	public bool is_temporary { get; protected set; default = false;} //only for cache, if the file may be deleted
	public int users { get; protected set; default=0; } //how many systems use this resource
	private HashTable<string,bool> user_ids = new HashTable<string,bool>(str_hash, str_equal);
	
	public Resource(string uri,string filepath,bool is_temporary){
		Object(
			uri:uri,
			filepath:filepath,
			is_temporary:is_temporary
		);
	}
	
	~Resource(){
		this.delete_file();
	}
	
	public void increment_users(string user){
		print(@"[res] Users increment: URI:$(this.uri) FILEPATH:$(this.filepath) {$user}\n");
		if (!user_ids.contains(user)){
			this.user_ids.set(user,true);
			this.users++;
		}
	}
	
	public void decrement_users(string user){
		print(@"[res] Users decrement: URI:$(this.uri) FILEPATH:$(this.filepath) {$user}\n");
		if (user_ids.contains(user)){
			this.user_ids.remove(user);
			this.users--;
		}
		if (this.users <= 0){
			this.delete_file();
		}
	}
	
	private void delete_file(){
		if (this.is_temporary){
			var file = File.new_for_path(this.filepath);
			if (file.query_exists()){
				try{
					file.delete();
				}catch( Error e ){
					print(@"[res][error] Failed to delete file for resource $(this.uri) | $(e.message)\n");
				}
				print(@"[res] Resource free: URI:$(this.uri) FILEPATH:$(this.filepath)\n");
			}
		}
	}
	
	public void add_metadata(string mimetype, string name, string metadata=""){
		if (this.timestamp != 0){return;}
		this.mimetype = mimetype;
		this.name = name;
		this.metadata = metadata;
		this.timestamp = (GLib.get_real_time()/1000);
	}
}
