public class Dragonstone.Store.Test : Object, Dragonstone.ResourceStore {

	public void reload(string uri,Dragonstone.SessionInformation? session = null) {} //does nothing in this test implementation
	
	public Dragonstone.Resource request(string uri,Dragonstone.SessionInformation? session = null){
		print(@"request: $uri\n");
		if (uri == "test://") {
			return new Dragonstone.SimpeleStaticTextResource("text/plain","Hello World","Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.\nhttps://lipsum.com/
\n------------------------------------------------------\n
Fusce iaculis a urna vitae hendrerit. Fusce at risus quis neque consectetur accumsan. Aenean tristique bibendum consectetur. Nullam eleifend eros elit. Morbi ut odio sollicitudin, iaculis tortor congue, pellentesque massa. Nunc nec pulvinar eros, in bibendum urna. Nunc at porta mauris, eu commodo magna. Duis augue ante, ornare id tincidunt eget, congue sed urna. Maecenas tempor arcu ac venenatis viverra. Vivamus in magna ac mi cursus egestas at in nibh.

Sed eu orci at augue consectetur fringilla sed ac ante. Mauris fringilla sed sapien a aliquet. Praesent mattis nisl at eros sagittis maximus. Integer nisl nibh, vulputate vitae nunc a, volutpat pulvinar dolor. In consequat ex eu sapien egestas viverra at et elit. Duis tristique magna auctor ex scelerisque, non interdum est commodo. Sed porta semper posuere.

Curabitur mollis turpis quis gravida luctus. Nunc euismod augue est, ultricies posuere sapien bibendum et. Quisque non convallis purus. Sed et posuere nisi. Curabitur interdum eget sem eu scelerisque. Donec sodales mauris eget ex varius, quis tincidunt odio placerat. Aliquam blandit, lectus at suscipit posuere, magna purus semper elit, et eleifend ligula dui et nulla. Sed pellentesque diam a lorem consequat placerat. Etiam a mattis arcu, quis tristique mi. Proin et lacinia ex. Nullam at nulla gravida, posuere felis tincidunt, imperdiet tortor.

Ut consequat semper diam, in imperdiet lectus aliquet vitae. Cras augue neque, sollicitudin quis felis sit amet, suscipit rhoncus velit. Mauris pharetra mauris nec nisi lacinia tempus. Aliquam vestibulum a enim non tempus. Proin in diam pulvinar, sodales dolor sed, semper enim. Donec convallis leo non velit iaculis, ut pretium purus aliquam. Mauris interdum rhoncus quam, at laoreet est sodales eget.

Praesent metus quam, accumsan eget nunc a, pellentesque sodales velit. Aliquam ut justo urna. Nullam commodo condimentum enim vitae malesuada. Nam convallis dictum nisi, eget consequat odio tempor nec. Praesent suscipit ante nec felis malesuada tristique ac ut sem. Nunc pulvinar nulla at tellus ultricies, a aliquam augue commodo. Sed ex metus, auctor eget dolor eget, pretium posuere augue.");
		} else if (uri == "test://uri_error") {
			return new Dragonstone.ResourceUriSchemeError("test");
		} else if (uri == "test://loading") {
			return new Dragonstone.SimpeleResource(Dragonstone.ResourceType.LOADING,"","Loading ... (forever)");
		} else if (uri == "test://offline") {
			return new Dragonstone.SimpeleResource(Dragonstone.ResourceType.ERROR_OFFLINE,"","Maybe, Maybe not ...");
		} else if (uri == "test://error") {
			return new Dragonstone.SimpeleResource(Dragonstone.ResourceType.ERROR,"test","Maybe, Maybe not ...");
		} else if (uri == "test://gibberish") {
			return new Dragonstone.SimpeleResource(Dragonstone.ResourceType.ERROR_GIBBERISH,"","Maybe, Maybe not ...");
		} else if (uri == "test://temp_unavaiable") {
			return new Dragonstone.SimpeleResource(Dragonstone.ResourceType.ERROR_TEMPORARILY_UNAVAIABLE,"","'It's been fun. Don't come back'");
		} else {
			return new Dragonstone.SimpeleResource(Dragonstone.ResourceType.ERROR_UNAVAIABLE,"","404");
		}
	}
}
