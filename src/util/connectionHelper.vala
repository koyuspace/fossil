public class Dragonstone.Util.ConnectionHelper : Object {
		
		public uint default_timeout = 30;
		
		public GLib.IOStream? connect_to_server(string host, uint16 port, Dragonstone.Request request, bool use_tls, SocketConnectable? _server_identity = null){
			//make request
			List<InetAddress> addresses;
			try {
				// Resolve hostname to IP address
				var resolver = Resolver.get_default ();
				addresses = resolver.lookup_by_name (host, null);
			} catch (Error e) {
				request.setStatus("error/noHost");
				request.finish();
				return null;
			}
			SocketConnectable? server_identity = _server_identity;
			if (use_tls && server_identity == null){
				server_identity = new NetworkAddress(host,port);
			}
			string? client_certificate = request.arguments.get("tls.client.certificate");
			string? expected_server_certificate = request.arguments.get("tls.server.expected_certificate");
			var tls_check_settings = new Dragonstone.Util.ConnectionHelperTlsCheckSettings().import_from_request(request);
			Dragonstone.Util.ConnectionHelperTlsConnection? last_tls_attempt = null;
			SocketConnection? conn = null;
			bool has_connection = false;
			foreach (InetAddress address in addresses){
				if (address.to_string().index_of_char(':') < 0){ //prefer IPv4 connections
					conn = try_connect(new InetSocketAddress (address, port));
					if (conn != null){
						if (use_tls){
							last_tls_attempt = upgrade_to_tls_connection(conn,client_certificate,expected_server_certificate,tls_check_settings,server_identity);
							if(last_tls_attempt.success == true){
								has_connection = true;
								break;
							}
						} else {
							has_connection = true;
							break;
						}
					}
					addresses.remove(address);
				}
			}
			
			if (!has_connection){
				foreach (InetAddress address in addresses){
					conn = try_connect(new InetSocketAddress (address, port));
					if (conn != null){
						if (use_tls){
							last_tls_attempt = upgrade_to_tls_connection(conn,client_certificate,expected_server_certificate,tls_check_settings,server_identity);
							if(last_tls_attempt.success == true){
								has_connection = true;
								break;
							}
						} else {
							has_connection = true;
							break;
						}
					}
				}
			}
			if ( conn == null ){
				request.setStatus("error/connectionRefused");
				request.finish();
				return null;
			}
			if (last_tls_attempt != null){
				last_tls_attempt.write_arguments(request);
				last_tls_attempt.write_status(request);
				if (last_tls_attempt.success){
					return last_tls_attempt.connection;
				}else{
					return null;
				}
			}
			return conn;
		}
		
		public SocketConnection? try_connect(InetSocketAddress address){
			try {
				// Connect
				var client = new SocketClient ();
				client.timeout = default_timeout;
				print (@"[connection_helper] Connecting to $address ...\n");
				var conn = client.connect (address);
				print (@"[connection_helper] Connected to $address\n");
				return conn;
			} catch (Error e) {
				print(@"[connection_helper] ERROR while connecting to $address : $(e.message)\n");
				return null;
			}
		}
		
		public Dragonstone.Util.ConnectionHelperTlsConnection upgrade_to_tls_connection(SocketConnection socket, string? client_certificate_pem, string? expected_server_certificate_pem, Dragonstone.Util.ConnectionHelperTlsCheckSettings? check_settings = null, SocketConnectable? server_identity = null){
			try {
				print("[connection_helper] Upgrading to TLS connection\n");
				if (server_identity != null){
					print("[connection_helper] Server identity: "+server_identity.to_string()+"\n");
				}
				Dragonstone.Util.ConnectionHelperTlsConnection returninfo = new Dragonstone.Util.ConnectionHelperTlsConnection(check_settings);
				returninfo.expected_server_certificate_pem = expected_server_certificate_pem;
				returninfo.connection = TlsClientConnection.@new(socket,server_identity);
				
				if (client_certificate_pem != null){
					print("[connection_helper] Using TLS client certificate\n");
					var client_certificate = new TlsCertificate.from_pem(client_certificate_pem,client_certificate_pem.length);
					returninfo.connection.set_certificate(client_certificate);
				}
				returninfo.connection.accept_certificate.connect((peer_certificate, tls_errors) => {
					returninfo.tls_errors = tls_errors;
					returninfo.peer_certificate = peer_certificate;
					returninfo.check_server_cerificate();
					return returninfo.may_connect_with_certificate() && returninfo.may_connect_with_error_flags();
				});
				var success = returninfo.connection.handshake();
				if (!success){
					print("[connection_helper] TLS handshake failed\n");
					return returninfo;
				}
				print("[connection_helper] TLS upgrade successful\n");
				returninfo.success = true;
				return returninfo;
			} catch (Error e) {
				print(@"[connection_helper] Something went wrong during TLS connection attempt: $(e.message)\n");
				return new Dragonstone.Util.ConnectionHelperTlsConnection.error(e.message);
			}
		}
	
}

public class Dragonstone.Util.ConnectionHelperTlsCheckSettings {
	public bool unexpected_certificate_critical = false;
	public bool identity_mismatch_critical = true;
	public bool expired_critical = false;
	public bool unknown_error_critical = false;
	public bool insecure_algorythm_critical = false;
	public bool future_activation_date_critical = false;
	public bool revoked_critical = false;
	
	public ConnectionHelperTlsCheckSettings(){
		//Do nothing
	}
	
	public ConnectionHelperTlsCheckSettings import_from_request(Dragonstone.Request request){
		unexpected_certificate_critical = get_is_critical(request,"unexpected_certificate",unexpected_certificate_critical);
		identity_mismatch_critical = get_is_critical(request,"identity_mismatch",identity_mismatch_critical);
		expired_critical = get_is_critical(request,"expired",expired_critical);
		unknown_error_critical = get_is_critical(request,"unknown_error",unknown_error_critical);
		insecure_algorythm_critical = get_is_critical(request,"insecure_algorythm",insecure_algorythm_critical);
		future_activation_date_critical = get_is_critical(request,"future_activation_date",future_activation_date_critical);
		revoked_critical = get_is_critical(request,"revoked",revoked_critical);
		return this;
	}
	
	private static bool get_is_critical(Dragonstone.Request request,string check_id,bool default_critical){
		string? val = request.arguments.get("tls.check."+check_id);
		if (val != null){
			return val == "critical";
		} else {
			return default_critical;
		}
	}
}

public class Dragonstone.Util.ConnectionHelperTlsConnection : Object {
	public TlsConnection? connection = null;
	public TlsCertificateFlags? tls_errors = null;
	public TlsCertificate? peer_certificate = null;
	public string? expected_server_certificate_pem = null;
	public string? error_message = null;
	public bool server_certificate_passed = false;
	public bool success = false;
	
	Dragonstone.Util.ConnectionHelperTlsCheckSettings? check_settings = null;
	
	public ConnectionHelperTlsConnection(Dragonstone.Util.ConnectionHelperTlsCheckSettings? check_settings){
		this.check_settings = check_settings;
	}
	
	public ConnectionHelperTlsConnection.error(string error_message){
		this.error_message = error_message;
		check_settings = new ConnectionHelperTlsCheckSettings();
	}
	
	public void write_arguments(Dragonstone.Request request){
		if (tls_errors != null){
			if ((tls_errors & GLib.TlsCertificateFlags.BAD_IDENTITY) != 0){request.arguments.set("warning.tls.certificate.identity_mismatch","true");}
			if ((tls_errors & GLib.TlsCertificateFlags.EXPIRED) != 0){request.arguments.set("warning.tls.certificate.expired","true");}
			if ((tls_errors & GLib.TlsCertificateFlags.GENERIC_ERROR) != 0){request.arguments.set("warning.tls.certificate.unknown_error","true");}
			if ((tls_errors & GLib.TlsCertificateFlags.INSECURE) != 0){request.arguments.set("warning.tls.certificate.insecure_algorythm","true");}
			if ((tls_errors & GLib.TlsCertificateFlags.NOT_ACTIVATED) != 0){request.arguments.set("warning.tls.certificate.future_activation_date","true");}
			if ((tls_errors & GLib.TlsCertificateFlags.REVOKED) != 0){request.arguments.set("warning.tls.certificate.revoked","true");}
		}
		if (!server_certificate_passed){request.arguments.set("warning.tls.certificate.unexpected_certificate","true");}
		if (error_message != null){request.arguments.set("error.tls",error_message);}
		if (peer_certificate != null){request.arguments.set("tls.server.certificate",peer_certificate.certificate_pem);}
	}
	
	public void write_status(Dragonstone.Request request){
		if (!success){
			if (error_message != null){
				if (error_message == "Unacceptable TLS certificate"){
					request.setStatus("error/tls/certificateRejected");
					request.finish();
				} else {
					request.setStatus("error/internal",error_message);
					request.finish();
				}
			}
		}
	}
	
	public void check_server_cerificate(){
		if (expected_server_certificate_pem == null || peer_certificate == null){
			server_certificate_passed = false;
			return;
		}
		try {
			var expected_certificate = new TlsCertificate.from_pem(expected_server_certificate_pem,expected_server_certificate_pem.length);
			server_certificate_passed = expected_certificate.is_same(peer_certificate);
		} catch (Error e){
			print(@"[connection_helper] Something went wrong while checking the servers TLS certificate: $(e.message)\n");
			server_certificate_passed = false;
			return;
		}
	}
	
	public bool may_connect_with_certificate(){
		check_check_settings();
		return (!check_settings.unexpected_certificate_critical)  || server_certificate_passed;
	}
	
	public bool may_connect_with_error_flags(){
		check_check_settings();
		bool identity_mismatch = ((tls_errors & GLib.TlsCertificateFlags.BAD_IDENTITY) != 0);
		bool expired = ((tls_errors & GLib.TlsCertificateFlags.EXPIRED) != 0);
		bool unknown_error = ((tls_errors & GLib.TlsCertificateFlags.GENERIC_ERROR) != 0);
		bool insecure_algorythm = ((tls_errors & GLib.TlsCertificateFlags.INSECURE) != 0);
		bool future_activation_date = ((tls_errors & GLib.TlsCertificateFlags.NOT_ACTIVATED) != 0);
		bool revoked = ((tls_errors & GLib.TlsCertificateFlags.REVOKED) != 0);
		bool may_connect = true;
		may_connect = may_connect && ((!check_settings.identity_mismatch_critical) || identity_mismatch);
		may_connect = may_connect && ((!check_settings.expired_critical) || expired);
		may_connect = may_connect && ((!check_settings.unknown_error_critical) || unknown_error);
		may_connect = may_connect && ((!check_settings.insecure_algorythm_critical) || insecure_algorythm);
		may_connect = may_connect && ((!check_settings.future_activation_date_critical) || future_activation_date);
		may_connect = may_connect && ((!check_settings.revoked_critical) || revoked);
		return may_connect;
	}
	
	private void check_check_settings(){
		if (check_settings == null){
			check_settings = new ConnectionHelperTlsCheckSettings();
		}
	}
}

//TLS checks my have the following states
//null: default ("warn")
//"critical": do not accept connection if fails
//"warn": accept the connection, but set a warning if the check fails
