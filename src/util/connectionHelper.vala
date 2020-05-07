public class Dragonstone.Util.ConnectionHelper : Object {
		
		public uint default_timeout = 30;
		
		public GLib.IOStream? connect_to_server(string host, uint16 port, Dragonstone.Request request, bool use_tls){
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
			
			GLib.IOStream? conn = null;
			foreach (InetAddress address in addresses){
				if (address.to_string().index_of_char(':') < 0){ //prefer IPv4 connections
					conn = try_connect(new InetSocketAddress (address, port), use_tls, request);
					if ( conn != null ) { break; }
					addresses.remove(address);
				}
			}
			if (conn == null){
				foreach (InetAddress address in addresses){
					conn = try_connect(new InetSocketAddress (address, port), use_tls, request);
					if ( conn != null ) { break; }
				}
			}
			if ( conn == null ){ request.setStatus("error/connectionRefused"); }
			return conn;
		}
		
		public GLib.IOStream? try_connect(InetSocketAddress address, bool use_tls, Dragonstone.Request request){
			try {
				// Connect
				var client = new SocketClient ();
				client.timeout = default_timeout;
				/*if (use_tls){
					client.tls = true;
					client.set_tls_validation_flags(GLib.TlsCertificateFlags.GENERIC_ERROR | GLib.TlsCertificateFlags.INSECURE | GLib.TlsCertificateFlags.NOT_ACTIVATED | GLib.TlsCertificateFlags.REVOKED); // GLib.TlsCertificateFlags.EXPIRED |
				}*/
				print (@"[connection_helper] Connecting to $address ...\n");
				var conn = client.connect (address);
				print (@"[connection_helper] Connected to $address\n");
				if (use_tls){
					return upgrade_to_tls_connection(conn,request);
				}
				return conn;
			} catch (Error e) {
				print(@"[connection_helper] ERROR while connecting to $address : $(e.message)\n");
				return null;
			}
		}
		
		public TlsConnection? upgrade_to_tls_connection(SocketConnection socket,Dragonstone.Request request){
			try {
				print("[connection_helper] Upgrading to tls connection\n");
				var tls_connection = TlsClientConnection.@new(socket,socket.get_remote_address());
				
				string? client_certificate_pem = request.arguments.get("tls.client.certificate");
				if (client_certificate_pem != null){
					print("[connection_helper] Using Tls client certificate\n");
					var client_certificate = new TlsCertificate.from_pem(client_certificate_pem,client_certificate_pem.length);
					tls_connection.set_certificate(client_certificate);
				}
				tls_connection.accept_certificate.connect((peer_certificate, tls_errors) => {
					//TODO!
					return true;
				});
				var success = tls_connection.handshake();
				if (!success){
					print("[connection_helper] Tls handshake failed\n");
					return null;
				}
				print("[connection_helper] Tls upgrade successful\n");
				return tls_connection;
			} catch (Error e) {
				print(@"[connection_helper] Something went wrong during TLS connection attempt: $(e.message)\n");
				return null;
			}
		}
	
}
