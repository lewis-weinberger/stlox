<p align="center">
    <a href="https://github.com/lewis-weinberger/stlox/actions/workflows/ci.yml"><img src="https://github.com/lewis-weinberger/stlox/actions/workflows/ci.yml/badge.svg"></a>
</p>

`stlox` is an interpreter of the [Lox](https://craftinginterpreters.com/the-lox-language.html) programming language as described in the excellent [Crafting Interpreters](https://craftinginterpreters.com/) book by [Robert Nystrom](https://github.com/munificent). It is a tree-walk interpreter written in [Smalltalk](https://en.wikipedia.org/wiki/Smalltalk), based directly on the Java version described in the book.

## Installation and usage

#### GNU Smalltalk
Requires [GNU Smalltalk](https://www.gnu.org/software/smalltalk), which can be installed by downloading and unpacking the latest [stable](https://ftp.gnu.org/gnu/smalltalk/)/[alpha](https://alpha.gnu.org/gnu/smalltalk/) version from the GNU FTP site:

```sh
# download and unpack source
wget https://alpha.gnu.org/gnu/smalltalk/smalltalk-3.2.91.tar.xz
tar -xvf smalltalk-3.2.91.tar.xz
cd smalltalk-3.2.91

# compile and install
export CFLAGS="-no-pie"
export LDFLAGS="-no-pie"
./configure
make
make install
```

This should create the Smalltalk interpreter `gst` (and other useful tools like `gst-load` for using packages) installed by default at `/usr/local/bin`.

Alternatively you may find that GNU Smalltalk is available in your system's package manager.

#### Lox

The Lox interpreter can be installed using the provided Makefile:

```sh
git clone https://github.com/lewis-weinberger/stlox.git
cd stlox
make install
make test # optionally run tests
```

This will place an executable script `stlox` at `/usr/local/bin` (by default) which can be used to run the interpreter:

```sh
# run as interactive interpreter by passing no arguments
stlox

# read and interpret from source file by passing file path
stlox examples/helloworld.lox
```

There are some Lox examples in the [examples](./examples) subdirectory.

## Status

Following the order in the [book](https://craftinginterpreters.com/contents.html), the following has been implemented so far:

* [x] Scanner
* [x] Parser
* [ ] Interpreter:
    * [ ] Expressions
    * [ ] Statements
    * [ ] Control flow
    * [ ] Functions
    * [ ] Variable binding
    * [ ] Classes
    * [ ] Inheritance

## License

[MIT](./LICENSE)
