Object subclass: Lox [
    | prompt |
    <comment: 'My instances are interpreters for the Lox programming language,
either running programs from source or providing an interactive interpreter.'>

    hadError := false.

    Lox class >> new [
        "Answer with a new Lox interpreter"

        <category: 'instance creation'>
        | x |
        x := super new.
        x init.
        ^x
    ]

    Lox class >> report: aLine where: aLocation message: aMessage [
        "Print error message"

        <category: 'debugging'>
        stderr
            nextPutAll: '[line ', aLine displayString, '] Error' , aLocation , ': ' , aMessage;
            nl;
            flush.
        hadError := true
    ]

    Lox class >> error: aMessage line: aLine [
        "Print message regarding error at given line"

        <category: 'debugging'>
        Lox report: aLine where: '' message: aMessage.
    ]

    Lox class >> tokenError: aToken message: aMessage [
        "Print message regarding error for given token"

        <category: 'debugging'>
        aToken type = #EOF ifTrue: [
            Lox report: aToken line where: ' at end' message: aMessage.
        ] ifFalse: [
            Lox report: aToken line where: (' at ''' , aToken lexeme , '''') message: aMessage.
        ]
    ]

    init [
        "Initialize Lox interpreter"

        <category: 'initialization'>
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
        | scanner tokens parser expression |
        scanner := Scanner source: aString.
        tokens := scanner scanTokens.

        parser := Parser with: tokens.
        expression := parser parse.

        hadError ifTrue: [ ^self ].

        (ASTPrinter new print: expression) displayNl
    ]
]
