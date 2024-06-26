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

        [ self isAtEnd ] whileFalse: [
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
        "Parse the source tokens into a list of statements"

        <category: 'built ins'>
        | statements |
        statements := OrderedCollection new.
        [ self isAtEnd ] whileFalse: [ statements add: self declaration ].
        ^statements.
    ]

    declaration [
        "Grammar rule for a declaration"

        <category: 'rule'>
        [
            (self match: #(#Var)) ifTrue: [ ^self varDeclaration ].
            ^self statement.
        ]
            on: ParseError
            do: [ :err | self synchronize. err return ].
    ]

    varDeclaration [
        "Grammar rule for a variable declaration"

        <category: 'rule'>
        | name initializer |
        name := self consume: #Identifier expect: 'Expect variable name.'.
        initializer := nil.
        (self match: #(#Equal)) ifTrue: [ initializer := self expression ].
        self consume: #Semicolon expect: 'Expect '';'' after variable declaration'.
        ^StmtVar name: name initializer: initializer
    ]

    statement [
        "Grammar rule for a statement"

        <category: 'rule'>
        (self match: #(#For)) ifTrue: [ ^self forStatement ].
        (self match: #(#If)) ifTrue: [ ^self ifStatement ].
        (self match: #(#Print)) ifTrue: [ ^self printStatement ].
        (self match: #(#While)) ifTrue: [ ^self whileStatement ].
        (self match: #(#LeftBrace)) ifTrue: [ ^StmtBlock statements: self block ].
        ^self expressionStatement.
    ]

    forStatement [
        "Grammar rule for desugaring a for statement"

        <category: 'rule'>
        | ini cond incr body stmts |
        self consume: #LeftParen expect: 'Expect ''('' after ''for''.'.

        (self match: #(#Semicolon)) ifTrue: [ ini := nil ].
        (self match: #(#Var)) ifTrue: [
            ini := self varDeclaration
        ] ifFalse: [
            ini := self expressionStatement
        ].

        cond := nil.
        (self check: #Semicolon) ifFalse: [ cond := self expression ].
        self consume: #Semicolon expect: 'Expect '';'' after loop condition.'.

        incr := nil.
        (self check: #RightParen) ifFalse: [ incr := self expression ].
        self consume: #RightParen expect: 'Expect '')'' after for clauses.'.
        body := self statement.

        incr ifNotNil: [
            stmts := OrderedCollection new.
            stmts
                add: body;
                add: (StmtExpression expression: incr).
            body := StmtBlock statements: stmts
        ].

        cond ifNil: [ cond := ExprLiteral value: true ].
        body := StmtWhile condition: cond body: body.

        ini ifNotNil: [
            stmts := OrderedCollection new.
            stmts
                add: ini;
                add: body.
            body := StmtBlock statements: stmts
        ].

        ^body.
    ]

    ifStatement [
        "Grammar rule for an if statement"

        <category: 'rule'>
        | cond then else |
        self consume: #LeftParen expect: 'Expect ''('' after ''if''.'.
        cond := self expression.
        self consume: #RightParen expect: 'Expect '')'' after if condition.'.
        then := self statement.
        else := nil.
        (self match: #(#Else)) ifTrue: [ else := self statement ].
        ^StmtIf condition: cond thenBranch: then elseBranch: else.
    ]

    printStatement [
        "Grammar rule for a print statement"

        <category: 'rule'>
        | value |
        value := self expression.
        self consume: #Semicolon expect: 'Expect '';'' after value.'.
        ^StmtPrint expression: value.
    ]

    whileStatement [
        "Grammar rule for a while statement"

        <category: 'rule'>
        | cond body |
        self consume: #LeftParen expect: 'Expect ''('' after ''while''.'.
        cond := self expression.
        self consume: #RightParen expect: 'Expect '')'' after condition.'.
        body := self statement.
        ^StmtWhile condition: cond body: body.
    ]

    expressionStatement [
        "Grammar rule for an expression statement"

        <category: 'rule'>
        | expr |
        expr := self expression.
        self consume: #Semicolon expect: 'Expect '';'' after expression.'.
        ^StmtExpression expression: expr.
    ]

    block [
        "Grammar rule for a block"

        <category: 'rule'>
        | statements |
        statements := OrderedCollection new.
        [ ((self check: #RightBrace) not) & (self isAtEnd not) ] whileTrue: [
            statements add: self declaration.
        ].
        self consume: #RightBrace expect: 'Expect ''}'' after block.'.
        ^statements.
    ]

    expression [
        "Grammar rule for an expression"

        <category: 'rule'>
        ^self assignment.
    ]

    assignment [
        "Grammar rule for an assignment"

        <category: 'rule'>
        | expr equals value name |
        expr := self or.

        (self match: #(#Equal)) ifTrue: [
            equals := self previous.
            value := self assignment.

            (expr class = ExprVariable) ifTrue: [
                name := expr name.
                ^ExprAssign name: name value: value.
            ].

            Lox tokenError: equals message: 'Invalid assignment target'.
        ].

        ^expr.
    ]

    or [
        "Grammar rule for an or expression"

        <category: 'rule'>
        | expr operator right |
        expr := self and.

        [ self match: #(#Or) ] whileTrue: [
            operator := self previous.
            right := self and.
            expr := ExprLogical left: expr operator: operator right: right
        ].
        ^expr.
    ]

    and [
        "Grammar rule for an and expression"

        <category: 'rule'>
        | expr operator right |
        expr := self equality.

        [ self match: #(#And) ] whileTrue: [
            operator := self previous.
            right := self equality.
            expr := ExprLogical left: expr operator: operator right: right
        ].
        ^expr.
    ]

    equality [
        "Grammar rule for an equality"

        <category: 'rule'>
        | expr operator right |
        expr := self comparison.
        [ self match: #(#BangEqual #EqualEqual) ] whileTrue: [
            operator := self previous.
            right := self comparison.
            expr := ExprBinary left: expr operator: operator right: right
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
            expr := ExprBinary left: expr operator: operator right: right
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
            expr := ExprBinary left: expr operator: operator right: right
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
            expr := ExprBinary left: expr operator: operator right: right
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
            ^ExprUnary operator: operator right: right
        ].
        ^self call.
    ]

    finishCall: callee [
        "Helper to parse function arguments"

        <category: 'helper'>
        | arguments paren |
        arguments := OrderedCollection new.
        (self check: #RightParen) ifFalse: [
            arguments add: (self expression).
            [ self match: #(#Comma) ] whileTrue: [
                ((arguments size) >= 255) ifTrue: [
                    ^ParseError
                        error: (self peek)
                        message: 'Can''t have more than 255 arguments'
                ].
                arguments add: (self expression)
            ]
        ].

        paren := self
            consume: #RightParen
            expect: 'Expect '')'' after arguments.'.
        ^ExprCall callee: callee paren: paren arguments: arguments.
    ]

    call [
        "Grammar rule for a function call"

        <category: 'rule'>
        | expr done |
        expr := self primary.
        done := false.
        [ done ] whileFalse: [
            (self match: #(#LeftParen)) ifTrue: [
                expr := self finishCall: expr
            ] ifFalse: [
                done := true
            ]
        ].

        ^expr.
    ]

    primary [
        "Grammar rule for a primary"

        <category: 'rule'>
        | expr |
        (self match: #(#False)) ifTrue: [ ^ExprLiteral value: false ].
        (self match: #(#True)) ifTrue: [ ^ExprLiteral value: true ].
        (self match: #(#Nil)) ifTrue: [ ^ExprLiteral value: nil ].

        (self match: #(#Number #String)) ifTrue: [
            ^ExprLiteral value: (self previous literal)
        ].

        (self match: #(#Identifier)) ifTrue: [
            ^ExprVariable name: (self previous)
        ].

        (self match: #(#LeftParen)) ifTrue: [
            expr := self expression.
            self consume: #RightParen expect: 'Expect '')'' after expression'.
            ^ExprGrouping expression: expr
        ].

        ^ParseError error: (self peek) message: 'Expected expression'.
    ]
]
