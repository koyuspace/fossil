public interface Dragonstone.GtkUi.Interface.HypertextThemeRuleProvider : Object {
	
	public abstract void foreach_relevant_rule(string content_type, string uri, Func<Dragonstone.GtkUi.Theming.HypertextThemeRule> cb);
	
}
