import PackageDescription

let package = Package(
    name: "RepositoryKit",
    dependencies: [
        .Package(url: "https://github.com/mxcl/PromiseKit", majorVersion: 4)
    ]
)
