public interface Fossil.Interface.Document.TokenRenderer : Object {
	
	public abstract void append_token(Fossil.Ui.Document.Token token);
	
	public abstract void reset_renderer();
}
