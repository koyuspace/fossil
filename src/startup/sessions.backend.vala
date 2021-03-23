public class Fossil.Startup.Sessions.Backend {
	public static void register_core_sessions(Fossil.SuperRegistry super_registry){
		print("[startup][sessions] Adding core sessions... \n");
		var session_registry = (super_registry.retrieve("core.sessions") as Fossil.Registry.SessionRegistry);
		var main_store = (super_registry.retrieve("core.stores.main") as Fossil.Interface.ResourceStore);
		if (session_registry == null){
			print("[startup][sessions][error] No session registry found ...\n");
			return;
		}
		if (main_store == null){
			print("[startup][sessions][error] No main resource store found ...\n");
			return;
		}
		session_registry.register_session("core.default",new Fossil.Session.Default(main_store));
		session_registry.register_session("core.uncached",new Fossil.Session.Uncached(main_store));
		session_registry.register_session("fossil.tls_0",new Fossil.Session.Tls(main_store));
	}
}
