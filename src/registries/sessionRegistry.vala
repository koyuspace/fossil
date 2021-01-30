public class Dragonstone.Registry.SessionRegistry : Object {
	public HashTable<string,Dragonstone.Interface.Session> sessions = new HashTable<string,Dragonstone.Interface.Session>(str_hash, str_equal);
	
	public void register_session(string session_id, Dragonstone.Interface.Session session){
		sessions.set(session_id,session);
	}
	
	public Dragonstone.Interface.Session? get_session_by_id(string session_id){
		return sessions.get(session_id);
	}
	
	public void erase_all_caches(){
		foreach (Dragonstone.Interface.Session session in sessions.get_values()){
			session.erase_cache();
		}
	}
}
