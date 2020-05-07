public class Dragonstone.Startup.Sessions {
	public static void register_core_sessions(Dragonstone.SuperRegistry super_registry){
		print("[startup][sessions] Adding core sessions... \n");
		var session_registry = (super_registry.retrieve("core.sessions") as Dragonstone.Registry.SessionRegistry);
		var main_store = (super_registry.retrieve("core.stores.main") as Dragonstone.ResourceStore);
		if (session_registry == null){
			print("[startup][sessions][error] No session registry found ...\n");
			return;
		}
		if (main_store == null){
			print("[startup][sessions][error] No main resource store found ...\n");
			return;
		}
		session_registry.register_session("core.default",new Dragonstone.Session.Default(main_store));
		session_registry.register_session("core.uncached",new Dragonstone.Session.Uncached(main_store));
		session_registry.register_session("test.tls_0",new Dragonstone.Session.Tls(main_store));
	}
}
