## Clean architecture with SwiftUI and Concurrency

A sample home run pizza client using Domain-Repository.

Run sample server using Doc/openapi.yaml:
`prism mock -h <host> ./Doc/openapi.yaml`
`<host>` must be specified in project's `Environment/` xcconfig files, `PIZZA_API_URL`

### Details
The **Domain layer** defines a communication interface between the UI and the data layers. The communication interface consists of entity structures and use case protocols. Use cases define functions/operations on entities.

The **DataSource layer** implements low-level data sources such as network communication and databases.

The **Repository layer** implements the use cases defined in the Domain layer. Thus, the business logic is placed in the Repository layer and is completely hidden from the UI layer. Since the Domain and Repository layers are in one framework/package, they can be reused in different UI implementations like iOS, macOS, tvOS, etc.

In the **UI layer**, the MVVM pattern is used to communicate with domain interface implementations.