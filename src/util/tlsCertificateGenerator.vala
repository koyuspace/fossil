public class Dragonstone.Util.TlsCertficateGenerator {

	public static GnuTLS.X509.PrivateKey generate_private_key() {
		var key = GnuTLS.X509.PrivateKey.create();
		key.generate(GnuTLS.PKAlgorithm.RSA, 4096);
		return key;
	}
	
	public static GnuTLS.X509.Certificate? generate_client_certificate(GnuTLS.X509.PrivateKey key){
		var certificate = GnuTLS.X509.Certificate.create();
		var activation_time = new DateTime.now_local();
		var expiration_time = activation_time.add_years(15);
		
		certificate.set_key(key);
		certificate.set_version(1);
		certificate.set_activation_time((time_t) activation_time.to_unix());
		certificate.set_expiration_time((time_t) expiration_time.to_unix());
		uint32 serial = 0;
		certificate.set_serial(&serial, sizeof(uint32));
		
		var error = certificate.sign(certificate, key);
		if(error == GnuTLS.ErrorCode.SUCCESS){
			return certificate;		
		} else {
			print(@"[util.TlsCertficateGenerator] Error while signing certificate ($error)\n");
			return null;
		}
	}
	
	public static string? certificate_to_pem(GnuTLS.X509.Certificate certificate){
		var buffer = new uint8[16384];
		size_t size = buffer.length;
		
		var error = certificate.export (GnuTLS.X509.CertificateFormat.PEM, buffer, ref size);
		if (error == GnuTLS.ErrorCode.SUCCESS){
			return (string) buffer;
		} else {
			print(@"[util.TlsCertficateGenerator] Error while encoding certificate ($error)\n");
			return null;
		}
	}
	
	public static string? private_key_to_pem(GnuTLS.X509.PrivateKey key){
		var buffer = new uint8[16384];
		size_t size = buffer.length;
		
		var error = key.export_pkcs8 (GnuTLS.X509.CertificateFormat.PEM, "", GnuTLS.X509.PKCSEncryptFlags.PLAIN, buffer, ref size);
		if (error == GnuTLS.ErrorCode.SUCCESS){
			return (string) buffer;
		} else {
			print(@"[util.TlsCertficateGenerator] Error while encoding private key ($error)\n");
			return null;
		}
	}
	
	public static string? generate_signed_certificate_key_pair_pem(){
		var key = Dragonstone.Util.TlsCertficateGenerator.generate_private_key();
		var certificate = Dragonstone.Util.TlsCertficateGenerator.generate_client_certificate(key);
		if (certificate != null) {
			var certificate_pem = certificate_to_pem(certificate);
			var key_pem = private_key_to_pem(key);
			if (certificate_pem != null && key_pem != null){
				return certificate_pem+key_pem;
			}
		}
		return null;
	}
	
}
