# Spell

Spell is a semi-toy language that I wrote to learn LLVM and native code generation. 

It's an imperative language with no mutable state, and its syntax is inspired by Python, Haskell and Lisp. Some of the main features are:

* Dynamically and strongly typed
* Integer, float, string, array and dictionary types
* No mutable state: no assignments, and all operations return new objects
* Lexical closures for high order constructs
* Garbage collected

The example bellow demonstrates most of the features in the language:

    import "map"
  
    quicksort (array) =
      ? length array <= 1 -> array
      ?                 _ -> quicksort' array
      with
        quicksort' (array) = (quicksort smaller) ++ [pivot] ++ (quicksort bigger)
          with
            pivot <- array[(length array) / 2]
            smaller <- filter { element | element < pivot } array
            bigger <- filter { element | element > pivot } array

    main () = 
      do
        show (inspect sorted) + "\n"
      with
        sorted <- quicksort [4, 5, 1, 2, 3]


## Requirements

* LLVM 2.8 compiled with shared libraries
  * On Mac OS X, the quickest way is to use `brew install llvm --shared`
  * On Linux, there are usually pre-compiled packages
* Ruby
* Treetop
* Ruby LLVM bindings (currently, [my fork][1] is necessary)
* [Boehm-Demers-Weiser][2] GC
  
## A few more details

* It uses Treetop for parsing
* Objects are internally represented with tagged structs when compiling

## Running

Usage is pretty simple:

    $ ruby bin/spell --help
    Usage: spell [options] FILENAME
        -D, --debug                      Print debug information when running
        -d, --dump                       Dump bytecode
        -m, --mode [MODE]                Execution mode (interpret, jit, compile)
        -o, --output FILENAME            If compiling, the name of the generated executable file
        -h, --help                       Show this message
        
To run the example above, supposing it's on the current directory in a file named `quicksort.spell`, one would use:

    ~$ ruby ./bin/spell --mode compile quicksort.spell -o quicksort

There's nothing different used to run the compiled program:

    ~$ ./quicksort
    [1, 2, 3, 4, 5]
    
    ~$
    
There are three modes for running code:

### Interpreted

Spell will use a small internal VM with limited primitives. Since this was used mostly for testing the initial syntax of the language, library support is pretty inconsistent and will provide less primitives than the compiled version.

### JIT

Spell will use LLVM, generate IR for the code and JIT-compile it. Since this is used mostly for testing purposes, the GC will be disabled, which means that all allocated memory will leak--it should matter for small programs, though.

### Compiled

Spell will generate a LLVM bitcode file and compile it with GC support, using the [Boehm-Demers-Weiser][2] conservative GC. This will actually generate an executable file native to the platform that can be run without needing Ruby or Spell itself to be present.
  
## Tests

The _test_ directory contains a relatively sized test suite for the language, interpreter and compiler. It tests pretty much every feature implemented so far, but there are pretty much no tests for corner cases.

## The bad

* Strange syntax; for example:
  * Double line break required between statements
  * Comments fail in most cases
  * Mix of ugly whitespace-significant constructs
  * Horrible error reporting due to Treetop limitations
* Missing standard library
* No access for external libraries (libc, for example)
* Half-baked exception support (used internally in a very limited way)

## TO DO

* Clean code (lots of LLVM stuff that should be properly separated)
* Fix the syntax
* Improve LLVM generation (most methods are pretty inneficient)
* Create a standard library
  
[1]: https://github.com/rferraz/ruby-llvm
[2]: http://www.hpl.hp.com/personal/Hans_Boehm/gc/