public class Fossil.Registry.SessionRegistry : Object {
	public HashTable<string,Fossil.Interface.Session> sessions = new HashTable<string,Fossil.Interface.Session>(str_hash, str_equal);
	
	public void register_session(string session_id, Fossil.Interface.Session session){
		sessions.set(session_id,session);
	}
	
	public Fossil.Interface.Session? get_session_by_id(string session_id){
		return sessions.get(session_id);
	}
	
	public void erase_all_caches(){
		foreach (Fossil.Interface.Session session in sessions.get_values()){
			session.erase_cache();
		}
	}
}
