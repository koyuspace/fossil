public class Dragonstone.Registry.SessionRegistry : Object {
	public HashTable<string,Dragonstone.ISession> sessions = new HashTable<string,Dragonstone.ISession>(str_hash, str_equal);
	
	public void register_session(string session_id, Dragonstone.ISession session){
		sessions.set(session_id,session);
	}
	
	public Dragonstone.ISession? get_session_by_id(string session_id){
		return sessions.get(session_id);
	}
	
	public void erase_all_caches(){
		foreach (Dragonstone.ISession session in sessions.get_values()){
			session.erase_cache();
		}
	}
}
