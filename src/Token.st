Object subclass: Token [
    | type lexeme literal line |
    <comment: 'My instances represent tokens read from Lox programs'>

    Token class >> type: aType lexeme: aLexeme literal: aLiteral line: aLine [
        "Create a new Token"

        <category: 'instance creation'>
        ^self new
            type: aType
            lexeme: aLexeme
            literal: aLiteral
            line: aLine
    ]

    type: aType lexeme: aLexeme literal: aLiteral line: aLine [
        "Set the receiver to have the given parameters"

        <category: 'initialization'>
        type := aType.
        lexeme := aLexeme.
        literal := aLiteral.
        line := aLine
    ]

    type [
        "Return the receiver's type"

        <category: 'getter'>
        ^type
    ]

    lexeme [
        "Return the receiver's lexeme"

        <category: 'getter'>
        ^lexeme
    ]

    literal [
        "Return the receiver's literal"

        <category: 'getter'>
        ^literal
    ]

    line [
        "Return the receiver's line"

        <category: 'getter'>
        ^line
    ]

    displayOn: aStream [
        "Display a representation of the receiver on aStream"

        <category: 'printing'>
        super displayOn: aStream.
        aStream nextPutAll: ' of type: '.
        type displayOn: aStream.
        aStream nextPutAll: ', with lexeme: '.
        lexeme displayOn: aStream.
    ]

    = aToken [
        "Answers whether the receiver is equal to aToken"

        <category: 'comparing'>
        (aToken class = Token) ifFalse: [ ^false ].
        self class allInstVarNames do: [ :var |
            (self instVarNamed: var) = (aToken instVarNamed: var)
                ifFalse: [ ^false ]
        ].
        ^true
    ]
]
