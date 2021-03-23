public class Fossil.Store.Internal : Object, Fossil.Interface.ResourceStore {

	public void request(Fossil.Request request,string? filepath = null, bool upload = false){
		if (filepath == null){
			request.setStatus("error/internal","Filepath required!");
			request.finish();
			return;
		}
		if (upload){
			request.setStatus("error/noupload","Uploding not supported");
			request.finish();
			return;
		}
		if (request.uri == "fossil://") {
			var helper = new Fossil.Util.ResourceFileWriteHelper(request,filepath,0);
			helper.appendString("# Hello!

## Welcome to the internet of Gopherholes and Gemini capsules!

Warning:
Gemini is supposed to be more secure than gopher but beacause of the implementation,
it cannot vertify a servers identity yet and therefore is about as secure as gopher.

To get started here are some links:

### Gopher

=> gopher://gopher.floodgap.com/1/v2 The Veronica-2 Gopher search engine
=> gopher://khzae.net khzae has some gopher based services, that definitely deserve more attention
=> gopher://gopher.floodgap.com/1/gopher What is Gopher and why is it still relevant?
=> gopher://khzae.net/0/rfc1436.txt RFC1436 - The gopher specification
=> gopher://zaibatsu.circumlunar.space/1/~solderpunk/gemini The gemini specification
=> gopher://tilde.club tilde.club

### Gemini

=> gemini://geminispace.info/ The geminispace.info search engine (GUS is dead)
=> gemini://medusae.space/ medusae.space gemini directory
=> gemini://gemini.circumlunar.space/servers/ A list of the first known gemini servers
=> gemini://koyu.space koyu.space
=> gemini://tilde.club tilde.club

---

Fossil is based on Dragonstone
=> https://gitlab.com/baschdel/dragonstone

You can find the sourcecode over at
=> https://github.com/koyuspace/fossil

If you want to contribute just submit a pull request
			");
			if (helper.error){return;}
			helper.close();
			var resource = new Fossil.Resource(request.uri,filepath,true);
			resource.add_metadata("text/gemini","Hello!");
			request.setResource(resource,"fossil");
		} else if (request.uri == "fossil://contact") {
				var helper = new Fossil.Util.ResourceFileWriteHelper(request,filepath,0);
				helper.appendString("
Write an e-mail to support@koyu.space
=> mailto:support@koyu.space
or contact Leonie over the fediverse
=> https://koyu.space/@koyu");
			if (helper.error){return;}
			helper.close();
			var resource = new Fossil.Resource(request.uri,filepath,true);
			resource.add_metadata("text/gemini","Contact");
			request.setResource(resource,"fossil");
		} else if (request.uri == "fossil://lipsum") {
			var helper = new Fossil.Util.ResourceFileWriteHelper(request,filepath,0);
			helper.appendString("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.\nhttps://lipsum.com/
\n------------------------------------------------------\n
Fusce iaculis a urna vitae hendrerit. Fusce at risus quis neque consectetur accumsan. Aenean tristique bibendum consectetur. Nullam eleifend eros elit. Morbi ut odio sollicitudin, iaculis tortor congue, pellentesque massa. Nunc nec pulvinar eros, in bibendum urna. Nunc at porta mauris, eu commodo magna. Duis augue ante, ornare id tincidunt eget, congue sed urna. Maecenas tempor arcu ac venenatis viverra. Vivamus in magna ac mi cursus egestas at in nibh.

Sed eu orci at augue consectetur fringilla sed ac ante. Mauris fringilla sed sapien a aliquet. Praesent mattis nisl at eros sagittis maximus. Integer nisl nibh, vulputate vitae nunc a, volutpat pulvinar dolor. In consequat ex eu sapien egestas viverra at et elit. Duis tristique magna auctor ex scelerisque, non interdum est commodo. Sed porta semper posuere.

Curabitur mollis turpis quis gravida luctus. Nunc euismod augue est, ultricies posuere sapien bibendum et. Quisque non convallis purus. Sed et posuere nisi. Curabitur interdum eget sem eu scelerisque. Donec sodales mauris eget ex varius, quis tincidunt odio placerat. Aliquam blandit, lectus at suscipit posuere, magna purus semper elit, et eleifend ligula dui et nulla. Sed pellentesque diam a lorem consequat placerat. Etiam a mattis arcu, quis tristique mi. Proin et lacinia ex. Nullam at nulla gravida, posuere felis tincidunt, imperdiet tortor.

Ut consequat semper diam, in imperdiet lectus aliquet vitae. Cras augue neque, sollicitudin quis felis sit amet, suscipit rhoncus velit. Mauris pharetra mauris nec nisi lacinia tempus. Aliquam vestibulum a enim non tempus. Proin in diam pulvinar, sodales dolor sed, semper enim. Donec convallis leo non velit iaculis, ut pretium purus aliquam. Mauris interdum rhoncus quam, at laoreet est sodales eget.

Praesent metus quam, accumsan eget nunc a, pellentesque sodales velit. Aliquam ut justo urna. Nullam commodo condimentum enim vitae malesuada. Nam convallis dictum nisi, eget consequat odio tempor nec. Praesent suscipit ante nec felis malesuada tristique ac ut sem. Nunc pulvinar nulla at tellus ultricies, a aliquam augue commodo. Sed ex metus, auctor eget dolor eget, pretium posuere augue.");
			if (helper.error){return;}
			helper.close();
			var resource = new Fossil.Resource(request.uri,filepath,true);
			resource.add_metadata("text/plain","Hello World");
			request.setResource(resource,"fossil");
		} else if (request.uri == "fossil://about") {
		    var helper = new Fossil.Util.ResourceFileWriteHelper(request,filepath,0);
            helper.appendString("# About
Fossil version 1.0

A gemini/gopher client originally written by Baschdel as Dragonstone, now forked and maintained by koyu.space under the name Fossil

=> gemini://koyu.space koyu.space on Gemini
=> https://koyu.space koyu.space on the world-wide-web

I hope you enjoy this software as much we enjoyed making it! ^_^
");
			if (helper.error){return;}
			helper.close();
			var resource = new Fossil.Resource(request.uri,filepath,true);
			resource.add_metadata("text/gemini","About");
			request.setResource(resource,"fossil");
		} else if (request.uri == "fossil://uri_error") {
			request.setStatus("error/uri/unknownScheme");
			request.finish();
		} else if (request.uri == "fossil://loading") {
			request.setStatus("loading");
		} else if (request.uri == "fossil://uploading") {
			request.setStatus("uploading");
		} else if (request.uri == "fossil://offline") {
			request.setStatus("error/noHost");
			Timeout.add(0,() => {
				request.arguments.set("error.example.message","This is an example error");
				request.finish();
				return false;
			},Priority.HIGH);
		} else if (request.uri == "fossil://error") {
			request.arguments.set("error.example.boolean","true");
			request.arguments.set("error.example.message","This is an example error");
			request.arguments.set("warning.example.boolean","true");
			request.arguments.set("warning.example.message","This is an example warning");
			request.setStatus("error");
			request.finish();
		} else if (request.uri == "fossil://gibberish") {
			request.setStatus("error/gibberish");
			request.finish();
		} else {
			request.setStatus("error/resourceUnavaiable");
			request.finish();
		}
	}
}
