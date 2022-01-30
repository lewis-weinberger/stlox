Character extend [
    isAlphaNumericOr_ [
        "True if self is a letter, digit or underscore"

        <category: 'testing'>
        ^(self isAlphaNumeric) | (self = $_)
    ]
]

Object subclass: Scanner [
    | source tokens start current line |
    <comment: 'My instances represent scanners that can read in Lox programs,
converting source text into tokens.'>

    Keywords := nil.

    Scanner class >> source: aSource [
        "Create a scanner for given source"

        <category: 'instance creation'>
        ^self new
            init: aSource
    ]

    Scanner class >> initialize [
    	"Initialize the lookup table for keywords"

    	<category: 'initializing lookup tables'>
        Keywords := Dictionary new.
        Keywords
            at: 'and' put: #And;
            at: 'class' put: #Class;
            at: 'else' put: #Else;
            at: 'false' put: #False;
            at: 'for' put: #For;
            at: 'fun' put: #Fun;
            at: 'if' put: #If;
            at: 'nil' put: #Nil;
            at: 'or' put: #Or;
            at: 'print' put: #Print;
            at: 'return' put: #Return;
            at: 'super' put: #Super;
            at: 'this' put: #This;
            at: 'true' put: #True;
            at: 'var' put: #Var;
            at: 'while' put: #While.
    ]

    init: aSource [
        "Initialize scanner with provided source"

        <category: 'initialization'>
        source := aSource.
        tokens := OrderedCollection new.
        start := 1.
        current := 1.
        line := 1
    ]

    scanTokens [
        "Loop over source to identify tokens"

        <category: 'scanning'>
        [ self isAtEnd not ] whileTrue: [
            start := current.
            self scanToken
        ].

        tokens add: (Token type: #EOF lexeme: '' literal: nil line: line).
        ^tokens
    ]

    scanToken [
        "Scan a single token from the source"

        <category: 'scanning'>
        | c |
        c := self advance.
        c = $( ifTrue: [ ^self addToken: #LeftParen ].
        c = $) ifTrue: [ ^self addToken: #RightParen ].
        c = ${ ifTrue: [ ^self addToken: #LeftBrace ].
        c = $} ifTrue: [ ^self addToken: #RightBrace ].
        c = $, ifTrue: [ ^self addToken: #Comma ].
        c = $. ifTrue: [ ^self addToken: #Dot ].
        c = $- ifTrue: [ ^self addToken: #Minus ].
        c = $+ ifTrue: [ ^self addToken: #Plus ].
        c = $; ifTrue: [ ^self addToken: #Semicolon ].
        c = $* ifTrue: [ ^self addToken: #Star ].
        c = $! ifTrue: [
            (self match: $=)
                ifTrue: [ ^self addToken: #BangEqual ]
                ifFalse: [ ^self addToken: #Bang ]
        ].
        c = $= ifTrue: [
            (self match: $=)
                ifTrue: [ ^self addToken: #EqualEqual ]
                ifFalse: [ ^self addToken: #Equal ]
        ].
        c = $< ifTrue: [
            (self match: $=)
                ifTrue: [ ^self addToken: #LessEqual ]
                ifFalse: [ ^self addToken: #Less ]
        ].
        c = $> ifTrue: [
            (self match: $=)
                ifTrue: [ ^self addToken: #GreaterEqual ]
                ifFalse: [ ^self addToken: #Greater ]
        ].
        c = $/ ifTrue: [
            (self match: $/)
                ifTrue: [
                    [ ((self peek = Character nl) not) & (self isAtEnd not) ]
                        whileTrue: [ self advance ].
                    ^self
                ]
                ifFalse: [ ^self addToken: #Slash ].
        ].
        c = Character space ifTrue: [ ^self ].
        c = Character cr ifTrue: [ ^self ].
        c = Character tab ifTrue: [ ^self ].
        c = Character nl ifTrue: [
            line := line + 1.
            ^self
        ].
        c = $" ifTrue: [ ^self string ].
        c isDigit ifTrue: [ ^self number ].
        c isAlphaNumericOr_ ifTrue: [ ^self identifier ].
        Lox error: 'Unexpected character.' line: line
    ]

    string  [
        "Process a literal string"

        <category: 'scanning'>
        | str |
        [ ((self peek = $") not) & (self isAtEnd not) ]
            whileTrue: [
                (self peek = Character nl) ifTrue: [ line := line + 1 ].
                self advance.
            ].
        self isAtEnd ifTrue: [ ^Lox error: 'Unterminated string.' line: line ].
        self advance.

        str := source copyFrom: (start + 1) to: (current - 2).
        self addToken: #String literal: str
    ]

    number [
        "Process a literal number"

        <category: 'scanning'>
        [ self peek isDigit ] whileTrue: [ self advance ].
        (self peek = $.) & (self peekNext isDigit)
            ifTrue: [
                self advance.
                [ self peek isDigit ] whileTrue: [ self advance ]
            ].

        self
            addToken: #Number
            literal: (source copyFrom: start to: current - 1) asNumber asFloatD

    ]

    identifier [
        "Process an identifier"

        <category: 'scanning'>
        | text type |
        [ self peek isAlphaNumericOr_ ] whileTrue: [ self advance ].
        text := source copyFrom: start to: (current - 1).
        type := Keywords at: text ifAbsent: [ #Identifier ].
        self addToken: type
    ]

    isAtEnd [
        "Answer whether we have reached the end of the source"

        <category: 'testing'>
        ^current > source size
    ]

    advance [
        "Advance the scanner to the next character"

        <category: 'scanning'>
        | c |
        c := source at: current.
        current := current + 1.
        ^c
    ]

    addToken: aType [
        "Add a new token to the list"

        <category: 'scanning'>
        | text |
        text := source copyFrom: start to: (current - 1).
        tokens add: (Token type: aType lexeme: text literal: nil line: line)
    ]

    addToken: aType literal: aLiteral [
        "Add a new literal token to the list"

        <category: 'scanning'>
        | text |
        text := source copyFrom: start to: (current - 1).
        tokens add: (Token type: aType lexeme: text literal: aLiteral line: line)
    ]

    match: anExpected [
        "Match a second character in multi-character lexemes"

        <category: 'scanning'>
        self isAtEnd ifTrue: [ ^false ].
        (source at: current) = anExpected ifFalse: [ ^false ].
        current := current + 1.
        ^true
    ]

    peek  [
        "Lookahead at the next character without consuming"

        <category: 'scanning'>
        self isAtEnd ifTrue: [ ^Character nul ].
        ^source at: current
    ]

    peekNext  [
        "Lookahead at the next next character without consuming"

        <category: 'scanning'>
        (current + 1 > source size) ifTrue: [ ^Character nul ].
        ^source at: (current + 1)
    ]
]

Eval [
    Scanner initialize
]
