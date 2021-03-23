public interface Fossil.GtkUi.Interface.HypertextThemeRuleProvider : Object {
	
	public abstract void foreach_relevant_rule(string content_type, string uri, Func<Fossil.GtkUi.Theming.HypertextThemeRule> cb);
	
}
