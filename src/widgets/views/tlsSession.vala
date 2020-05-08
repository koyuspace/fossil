public class Dragonstone.View.TlsSession : Dragonstone.Widget.TextContent, Dragonstone.IView{

	private Dragonstone.Request? request = null;
	private Dragonstone.Tab? tab = null;
	private Dragonstone.Registry.TranslationRegistry? translation = null;
	
	public TlsSession(Dragonstone.Registry.TranslationRegistry? translation){
		this.translation = translation;
	}
	
	public bool displayResource(Dragonstone.Request request,Dragonstone.Tab tab){
		if (!(request.status == "interactive/tls_session")) {return false;}
		this.request = request;
		this.tab = tab;
		var session = tab.session as Dragonstone.Session.Tls;
		if (session != null){
			appendText(translation.localize("view.session.tls.title")+"\n");
			appendText(session.get_name()+"\n");
		} else {
			appendText(translation.localize("view.session.tls.not_a_tls_session")+"\n");
		}
		return true;
	}
	
	public bool canHandleCurrentResource(){
		if (request == null){
			return false;
		}else{
			return request.status == "interactive/tls_session";
		}
	}
	
	public void cleanup(){
	
	} 
}
