public class Fossil.GtkUi.Theming.HypertextThemeRule : Object {

	public string theme_name;
	public string? content_type = null;
	public string? scheme = null;
	public string? host = null;
	public string? port = null;
	public string? path_prefix = null;
	public string? path_suffix = null;
	
	public HypertextThemeRule(string theme_name){
		this.theme_name = theme_name;
	}
	
	public int calculate_score(string content_type, string? scheme, string? host, string? port, string? path){
		int score = 0;
		bool all_null = true;
		if (this.content_type != null) {
			all_null = false;
			if (content_type.has_prefix(this.content_type)) {
				score += 100000;
			} else {
				return 0;
			}
		}
		if (this.scheme != null) {
			all_null = false;
			if (scheme != null) {
				if (scheme == this.scheme){
					score += 5000;
					score += scheme.length*10;
				} else if (scheme.has_prefix(this.scheme+"+")) {
					score += 5000;
					score += scheme.length*10;
				} else {
					return 0;
				}
			} else {
				return 0;
			}
		}
		if (this.host != null) {
			all_null = false;
			if (host != null) {
				if (host == this.host){
					score += this.host.length*2;
					score += 1000;
				} else if (host.has_suffix("."+this.host)) {
					score += this.host.length*2;
				} else {
					return 0;
				}
			} else {
				return 0;
			}
		}
		if (this.port != null) {
			all_null = false;
			if (this.port == port) {
				score += 1000;
			} else {
				return 0;
			}
		}
		if (this.path_prefix != null) {
			all_null = false;
			if (path != null) {
				if (path.has_prefix(this.path_prefix)) {
					score += this.path_prefix.length;
					score += 100;
				} else {
					return 0;
				}
			} else {
				return 0;
			}
		}
		if (this.path_suffix != null) {
			all_null = false;
			if (path != null) {
				if (path.has_suffix(this.path_suffix)) {
					score += this.path_suffix.length;
				} else {
					return 0;
				}
			} else {
				return 0;
			}
		}
		if (all_null) {
			score++;
		}
		return score;
	}
	
}
