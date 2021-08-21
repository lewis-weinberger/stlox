Object subclass: Lox [
    | hadError prompt |
    <comment: 'My instances are interpreters for the Lox programming language,
either running programs from source or providing an interactive interpreter.'>

    Lox class >> new [
        "Answer with a new Lox interpreter"

        <category: 'instance creation'>
        | x |
        x := super new.
        x init.
        ^x
    ]

    Lox class >> error: aMessage line: aLine [
        "Print message regarding error at given line"

        <category: 'debugging'>
        stderr
            nextPutAll: '[line ', aLine displayString, '] Error: ', aMessage;
            nl;
            flush
    ]

    init [
        "Initialize Lox interpreter"

        <category: 'initialization'>
        hadError := false.
        prompt := '> '
    ]

    runFile: aPath [
        "Run the interpreter on the provided source file at aPath"

        <category: 'built ins'>
        | file src |
        file := FileStream open: aPath mode: FileStream read.
        src := file upToEnd.
        file close.
        self run: src.
        hadError ifTrue: [ ObjectMemory quit: 65 ]
    ]

    runPrompt [
        "Run the interpreter interactively"

        <category: 'built ins'>
        prompt display.
        stdin linesDo: [ :line |
            self run: line.
            prompt display.
            hadError := false
        ].
        Transcript nl
    ]

    run: aString [
        "Interpret aString as Lox program"

        <category: 'built ins'>
        | scanner tokens |
        scanner := Scanner source: aString.
        tokens := scanner scanTokens.

        "Currently just print out scanned tokens"
        tokens do: [ :token | token displayNl ]
    ]
]
