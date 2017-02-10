# RepositoryKit

[![Version](https://img.shields.io/cocoapods/v/RepositoryKit.svg)](http://cocoapods.org/pods/RepositoryKit)
[![Build](https://api.travis-ci.org/LucianoPolit/RepositoryKit.svg)](https://travis-ci.org/LucianoPolit/RepositoryKit)
[![Coverage](https://codecov.io/gh/LucianoPolit/RepositoryKit/graph/badge.svg)](https://codecov.io/gh/LucianoPolit/RepositoryKit)
[![Documentation](https://img.shields.io/cocoapods/metrics/doc-percent/RepositoryKit.svg)](http://cocoadocs.org/docsets/RepositoryKit)

## Index

- [Introduction](#introduction)
- [Example](#example)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
    - [Starting with the Entity](#starting-with-the-entity)
    - [Creating the Repository](#creating-the-repository)
    - [Lets Try It](#lets-try-it)
    - [More Repositories](#more-repositories)
- [Communication](#communication)
- [Author](#author)
- [License](#license)

## Introduction

RepositoryKit is a framework that eases the way of organizing your code.

It is based on the Repository Pattern which main purpose is to separate the logic that retrieves the data of the store modules (such as networking or local storage) from your code. It is usually located in a controller, forcing it to do more things than what it is supposed to (and making it bigger). However, now, they have the right and cleaner place to be.

It consists on three components:
- Entity: the thing that we need to represent, usually known as an object.
- Repository: the one that knows how to operate between entities and data stores.
- Data store: some place where the data is stored and brings a way to communicate with it, like a Networking Session or a Core Data Stack.

Moreover, it uses Promises, which is a good way to manage asynchronous code.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first. Another simpler way is executing `pod try RepositoryKit` from the Terminal.

## Requirements

- iOS 9.0+
- Swift 3.0+

## Installation

RepositoryKit is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod "RepositoryKit", "~> 4.0"
```

## Usage

The case: it is needed to interact with a REST API to manage a conversation, just the simple case, 'Message' as the unique entity. With that messages, we need to make four different operations and the Repository will be the responsable of executing them. The operations are: Create, Read, Update, Delete, which are known as CRUD.

### Starting with the Entity

First of all, to interact with our API, our repository needs to be able to identify the entity because it needs to execute the different operations over the same entity. So, we have to conform 'Identifiable', as simple as adding an 'id' property.

```swift
struct Message: Identifiable {
    
    // Entity identification.
    var id: String
    // Properties.
    var text: String
    
}
```

Then, just because the repository needs to communicate to our API in a common data representation, the entity has to conform two new protocols: 'DictionaryInitializable' & 'DictionaryRepresentable'.

```swift
extension Message: DictionaryInitializable {
    
    // Initialize with a dictionary.
    init?(dictionary: Dictionary<String, Any>) {
        
        // Here we will have the dictionary that should initialize the entity.
        // We have to be careful that every information we need is inside the dictionary.
        // If not, return nil, and we will have an error in the promise of the repository operation.
        guard let id = dictionary["_id"] as? String, let text = dictionary["text"] as? String else { return nil }
        
        // In case that we have the data needed, set it.
        self.id = id
        self.text = text
        
    }
    
}

extension Message: DictionaryRepresentable {
    
    // Dictionary representation.
    var dictionary: Dictionary<String, Any> {
        return [
            "_id": id,
            "text": text
        ]
    }
    
}
```

And thats all! We have the entity ready to interact with our repository and our API!

### Creating the Repository

Now that we have our entity ready, we need to make something that should be able to interact with our API with the information that the entity is able to bring.

First of all, our repository needs to know about our entity. Conforming 'Repository' is easy.

```swift
class MessageRepository: Repository {
    
    // It is the entity that the repository operates.
    typealias Entity = Message
    
}
```

Then, we need to conform to 'NetworkingRepository'. So, the repository needs:
- The path with which the repository will be represented.
- Some way to interact with our API, making HTTP requests. In this case, the KIT will bring one to use as the default, which is called 'NetworkingSession' and it can be changed by one that you makes, or one of another framework. Just something to interact with our API as long as it conforms to 'Networking'.

```swift
class MessageRepository: NetworkingRepository {
    
    // It is the entity that the repository operates.
    typealias Entity = Message
    
    // It will make the requests.
    var store: Networking
    
    // The path that represents the repository.
    var path: String = "messages"
    
    // Initialize it with a networking store.
    init(store: Networking) {
        self.store = store
    }
    
}
```

Now, we are able to communicate between Entity - Repository - API. But, what operations can we make? Anyone yet…
So, as the case requires, we need to be able to make the CRUD operations:
- Create:
    - Request: 'url/path'.
    - Method: POST.
    - Parameters: Entity dictionary.
    - Returns: An object with the extra attributes, at least the id.
- Read:
    - Request: 'url/path' or 'url/path/:id'.
    - Method: GET.
    - Returns: An object or an array of objects.
- Update:
    - Request: 'url/path/:id'.
    - Method: PUT.
    - Parameters: Entity dictionary.
    - Returns: An object with the extra attributes, if it is needed.
- Delete:
    - Request: 'url/path/:id'.
    - Method: DELETE.
    
If we just make the repository conforms to 'CRUDNetworkingRepository', it will be able to make this operations. Is that cool? Thanks to Swift, it is possible because of default protocol implementations!

```swift
class MessageRepository: CRUDNetworkingRepository { ... }
```

In the case that the CRUD concept is not enough for what you need, or another repository that the KIT includes, you can extend the repository and define your own methods, or also make your own type of repository.

Now, we are ready to try it!

### Lets try it

First of all, we are using Promises. If you have no knowledge about them, I invite you to figure out a little about [PromiseKit](http://promisekit.org/).

Before starting to make the CRUD operations, we need to initialize the networking session and the repository.

```swift
let networkingSession = NetworkingSession(url: "http://localhost:3000")
let messageRepository = MessageRepository(store: networkingSession)
```

Now we are ready! Lets create a message.

```swift
// It will create a message on your API.
messageRepository.create(["text": "Here goes a message!!!"])
    .then { message in
        print(message)
        // Observe that you should have at least the 'text' and 'id' properties initialized.
        // In my case, it printed 'Message(id: "581a8e2da80614c82661b98d", text: "Here goes a message!!!")'.
        // Here you can update the UI for example.
    }
    .catch { error in
        // In case that an error occurs, do whatever you have to do here.
        errorHandler(error)
    }
```

Let me show you one more case. Then try whatever you want!

```swift
messageRepository.search("581a8e2da80614c82661b98d")
    .then(execute: messageRepository.delete)
    .then {
        print("The message has been deleted")
    }
    .catch { error in
        // In case that an error occurs, do whatever you have to do here.
        errorHandler(error)
    }
```

In this case, it will try to search the entity on the API with the specified id. Then, in case of success, it will try to delete it, and, if everything is OK, it will print that the entity was deleted. Just remember to not forget to handle if an error occurs.

Is it easy? And cleaner? That's cool! And now, its your turn to try it!

### More Repositories

The usage case was only the beginning and the simplest one. There are more repositories types, therefore, the entities might have more requirements. To see a more complex case, download the example, and see how it works with multiple repositories (networking and local storage together, for a list of users in this case).

Here goes a list of the current repositories available (for every single repository, check what protocols are required to be implemented, for both cases, the entity and the repository):

- CRUD Networking repository: it is the specified on the usage case.
- CRUD Networking repository (dictionary): it is the same as the previous one, but it is only able to represent dictionaries.
- CRUD Networking & Storage repository: it manages the same operations as the other CRUD repositories, but it will able to operate in both, a networking repository and a storage one (both as children), keeping them synchronized.
- Synchronizable repository: 
    - Purpose: it is used to synchronize multiple repositories.
    - API requirements:
        - Request: 'url/path/collection'.
        - Method: POST.
        - Parameters: An array of objects with all the entities that are not synchronized.
        - Returns: An ordered array of objects with the extra attributes, if it is needed.
    - Usage: just implementing it is enough to call the synchronize method. 
- Patchable repository (only for networking cases): 
    - Purpose: avoid sending unnecessary data when modifying resources.
    - API requirements: 
        - Request: 'url/path/:id'.
        - Method: PATCH.
        - Parameters: An object that represents the difference between the old one and the new one.
        - Returns: An object with the extra attributes, if it is needed.
    - Usage: implement the protocol and take care of update the 'memoryDictionary' every time that a request is executed and something is modified on the API.
    
## Communication

- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.

## Author

Luciano Polit, lucianopolit@gmail.com

## License

RepositoryKit is available under the MIT license. See the LICENSE file for more info.
