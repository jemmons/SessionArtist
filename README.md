# SessionArtist
### Adds structure around URLSession for beautiful Services.

SessionArtist combines a `Host` and a set of `Endpoint`s to create a `URLSession` that models a web service. It also provides some niceties for creating requests and handling responses.

## Hosts

A `Host` is just the location of a service. It can be specified as a `URL` or a `String` (with the added complexity of a `try`):

```
let fooHost = Host(url: myURL)
let barHost = try! Host(urlString: "http://example.com")
```

Why use a `Host` instead of just a `URL`, then? Because `Host` has a bunch of goodies for creating requests that we'll look at in a bit. And convenience initializers mean you'll rarely have to deal directly with `Host`, anyway.  

## Endpoints

An endpoint can be any type conforming to the `Endpoint` protocol, but it makes most sense as an `enum`:

```
enum MyEndpoint: Endpoint {
   case listing(id: String), createListing(name: String, description: String)
   
   func makeRequest(host: Host) -> URLRequest {
     switch self {
     case let .listing(id):
       return host.get("/listing/\(id)")
     case let .createListing(name, description):
       return host.post("/listing", params: ["name": name, "description": description])
     }
   }   
}
```

Note that the `Host` is passed in to `makeRequest`, making its URLRequest constructors available. See the documentation for `Host` to find the full list of these convenience methods.