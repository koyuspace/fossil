public class Dragonstone.Util.ConnectionHelper : Object {
		
		public uint default_timeout = 30;
		
		public GLib.SocketConnection? connect_to_server(string host, uint16 port, Dragonstone.Request request, bool use_tls){
			//make request
			List<InetAddress> addresses;
			try {
				// Resolve hostname to IP address
				var resolver = Resolver.get_default ();
				addresses = resolver.lookup_by_name (host, null);
			} catch (Error e) {
				request.setStatus("error/noHost");
				return null;
			}
			
			SocketConnection? conn = null;
			foreach (InetAddress address in addresses){
				if (address.to_string().index_of_char(':') < 0){ //prefer IPv4 connections
					conn = try_connect(new InetSocketAddress (address, port), use_tls);
					if ( conn != null ) { break; }
					addresses.remove(address);
				}
			}
			if (conn == null){
				foreach (InetAddress address in addresses){
					conn = try_connect(new InetSocketAddress (address, port), use_tls);
					if ( conn != null ) { break; }
				}
			}
			if ( conn == null ){ request.setStatus("error/connectionRefused"); }
			return conn;
		}
		
		public SocketConnection? try_connect(InetSocketAddress address, bool use_tls){
			try {
				// Connect
				var client = new SocketClient ();
				client.timeout = default_timeout;
				if (use_tls){
					client.tls = true;
					client.set_tls_validation_flags(GLib.TlsCertificateFlags.GENERIC_ERROR | GLib.TlsCertificateFlags.INSECURE | GLib.TlsCertificateFlags.NOT_ACTIVATED | GLib.TlsCertificateFlags.REVOKED); // GLib.TlsCertificateFlags.EXPIRED |
				}
				print (@"[connection_helper] Connecting to $address ...\n");
				var conn = client.connect (address);
				print (@"[connection_helper] Connected to $address\n");
				return conn;
			} catch (Error e) {
				print(@"[connection_helper] ERROR while connecting to $address : $(e.message)\n");
				return null;
			}
		}
	
}
