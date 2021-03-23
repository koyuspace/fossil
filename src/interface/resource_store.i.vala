public interface Fossil.Interface.ResourceStore : Object  {
	
	// A resource store is basically a protocol adapter, that takes request
	// objects and fullfills the requests
	// To download a resource add a request with an uri.
	// If the reload flag is set to true, this means, that the resource should
	// not be fetched from cache.
	// the filepath argument should point to a non existant file, that the store
	// may use to store the blob part of the response, however if the file
	// already exists elsewhere in the filesystem it should use that path and
	// set the is_temporary flag on the resource to false
	
	// To upload a resource, do as if you were downloading but set the
	// upload_resource in the request and and the request argument to true
	// the store will then attempt to upload the resource, and if successful
	// download the servers response
	
	public abstract void request(Fossil.Request request, string? filepath = null, bool upload = false);
}
