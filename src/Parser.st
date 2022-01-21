Warning subclass: ParseError [
    <comment: 'My instances are resumable parsing exceptions.'>

    ParseError class >> error: aToken message: aMessage [
        "Raise a parse exception"

        <category: 'instance creation'>
        Lox tokenError: aToken message: aMessage.
        ^self new signal
    ]
]

Object subclass: Parser [
    | tokens current |
    <comment: 'My instances are recursive descent parsers for
the Lox programming language.'>

    Parser class >> with: tokenList [
        "Answer with a new Lox parser"

        <category: 'instance creation'>
        ^self new
            init;
            tokens: tokenList;
            yourself.
    ]

    init [
        "Initialise the parser"

        <category: 'initialization'>
        current := 1.
    ]

    tokens: tokenList [
        "Set the tokens to be parsed"

        <category: 'setter'>
        tokens := tokenList.
    ]

    advance [
        "Consume current token and advance to the next token"

        <category: 'built ins'>
        self isAtEnd ifFalse: [ current := current + 1 ].
        ^self previous.
    ]

    check: tokenType [
        "Check if current token matches given token type"

        <category: 'built ins'>
        self isAtEnd ifTrue: [ ^false ].
        ^(self peek type = tokenType).
    ]

    isAtEnd [
        "Check if current token is EOF"

        <category: 'built ins'>
        ^(self peek type = #EOF).
    ]

    peek [
        "Get the current token to be parsed"

        <category: 'built ins'>
        ^tokens at: current
    ]

    previous [
        "Get the previous token that was just parsed"

        <category: 'built ins'>
        ^tokens at: (current - 1)
    ]

    consume: aType expect: aMessage [
        "Consume the next token, panicking if not as expected"

        <category: 'built ins'>
        (self check: aType) ifTrue: [ ^self advance ].
        ^ParseError error: (self peek) message: aMessage
    ]

    synchronize [
        "Synchronize the parser after an exception"

        <category: 'built ins'>
        | next |
        self advance.

        self isAtEnd whileFalse: [
            self previous type = #Semicolon ifTrue: [ ^self ].

            (#(#Class #Fun #Var #For #If #While #Print #Return) includes: self peek type)
                ifTrue: [ ^self ].

            self advance.
        ]
    ]

    match: tokenList [
        "Check if current token matches provided list"

        <category: 'built ins'>
        tokenList do: [ :type |
            (self check: type) ifTrue: [
                self advance.
                ^true
            ]
        ].
        ^false.
    ]
    
    parse [
        "Begin parsing the tokens"

        <category: 'built ins'>
        [ ^self expression ]
            on: ParseError
            do: [ :sig | sig return ]
    ]

    expression [
        "Grammar rule for an expression"

        <category: 'rule'>
        ^self equality.
    ]

    equality [
        "Grammar rule for an equality"

        <category: 'rule'>
        | expr operator right |
        expr := self comparison.
        [ self match: #(#BangEqual #EqualEqual) ] whileTrue: [
            operator := self previous.
            right := self comparison.
            expr := Binary left: expr operator: operator right: right
        ].
        ^expr.
    ]

    comparison [
        "Grammar rule for a comparison"

        <category: 'rule'>
        | expr operator right |
        expr := self term.
        [ self match: #(#Greater #GreaterEqual #Less #LessEqual) ] whileTrue: [
            operator := self previous.
            right := self term.
            expr := Binary left: expr operator: operator right: right
        ].
        ^expr.
    ]

    term [
        "Grammar rule for a term"

        <category: 'rule'>
        | expr operator right |
        expr := self factor.
        [ self match: #(#Minus #Plus) ] whileTrue: [
            operator := self previous.
            right := self factor.
            expr := Binary left: expr operator: operator right: right
        ].
        ^expr.
    ]

    factor [
        "Grammar rule for a factor"

        <category: 'rule'>
        | expr operator right |
        expr := self unary.
        [ self match: #(#Slash #Star) ] whileTrue: [
            operator := self previous.
            right := self unary.
            expr := Binary left: expr operator: operator right: right
        ].
        ^expr.
    ]

    unary [
        "Grammar rule for a unary"

        <category: 'rule'>
        | operator right |
        (self match: #(#Bang #Minus)) ifTrue: [
            operator := self previous.
            right := self unary.
            ^Unary operator: operator right: right
        ].
        ^self primary.
    ]

    primary [
        "Grammar rule for a primary"

        <category: 'rule'>
        | expr |
        (self match: #(#False)) ifTrue: [ ^Literal value: false ].
        (self match: #(#True)) ifTrue: [ ^Literal value: true ].
        (self match: #(#Nil)) ifTrue: [ ^Literal value: nil ].
        
        (self match: #(#Number #String)) ifTrue: [
            ^Literal value: (self previous literal)
        ].
        
        (self match: #(#LeftParen)) ifTrue: [
            expr := self expression.
            self consume: #RightParen expect: 'Expect '')'' after expression'.
            ^Grouping expression: expr
        ].
        
        ^ParseError error: (self peek) message: 'Expected expression'.
    ]
]