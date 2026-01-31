# CapOS APP exmaple `HelloWorld`

This is a very simplified example of CapOS application source code. It uses the Go programming language to implement a HelloWorld program.

You can directly modify this repository to build your own applications.

## Repository Description

```
.
├── bin              —> Compilation results
├── config.yaml      —> Config
├── Dockerfile
├── go.mod
├── go.sum
├── handlers
│   └── handlers.go 
├── main.go          —> Main program
├── Makefile
├── README.md
├── static
│   ├── css
│   │   └── style.css
│   └── js
│       └── script.js
└── templates
    └── index.html
```

## Modification Steps

* You can delete `main.go`, `go.mod`, `go.sum`, `handlers`, `static`, and `template` from this repository as needed and replace them with your own programs. If you are not using Go, please modify `Dockerfile`.
* Modify `config.yaml` and fill in your project information.
* Run `make` in the project directory.
* Check the compilation results in the `bin` directory and extract the `cpk` file.
* If you wish to publish your application to the FWERKOR official app store, contact admin@fwerkor.com


## License

Capp-HelloWorld is licensed under MIT License.
