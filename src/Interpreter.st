Object subclass: Interpreter [
    | environment |
    <comment: 'My instances are evaluators for the Lox programming language.'>

    Interpreter class >> new [
        "Answer with a new Lox interpeter"

        <category: 'instance creation'>
        | x |
        x := super new.
        x init.
        ^x
    ]

    init [
        "Initialize the interpreter environment"

        <category: 'initialization'>
        environment := Environment new.
    ]

    interpret: statements [
        "Interpret a list of Lox statements"

        <category: 'evaluation'>
        [ statements do: [ :statement | self execute: statement ] ]
            on: RuntimeError
            do: [ :err |
                Lox runtimeError: err.
                err return
            ].
    ]

    stringify: anObject [
        "Create printable string for object"

        <category: 'private'>
        | text len |
        anObject ifNil: [ ^'nil' ].

        (anObject class = FloatD) ifTrue: [
            text := anObject displayString.
            len := text size.
            ((len > 2) and: [ (text last) = $0 and: [ (text at: len - 1) = $. ] ])
                ifTrue: [ ^text copyFrom: 1 to: len - 2 ].
            ^text
        ].

        ^anObject displayString
    ]

    execute: stmt [
        "Send back to statement for appropriate visitor method"

        <category: 'evaluation'>
        ^stmt accept: self.
    ]

    executeBlock: statements environment: anEnvironment [
        "Execute block of statements"

        <category: 'evaluation'>
        | previous |
        previous := environment.
        [
            environment := anEnvironment.
            statements do: [ :statement | self execute: statement ].
        ]
            ensure: [ environment := previous ].
    ]

    evaluate: expr [
        "Send back to expression for appropriate visitor method"

        <category: 'evaluation'>
        ^expr accept: self.
    ]

    isTruthy: anObject [
        "Determine if value is truthy"

        <category: 'evaluation'>
        anObject ifNil: [ ^false ].
        (anObject respondsTo: #ifTrue:) ifTrue: [ ^anObject ].
        ^true.
    ]

    isEqual: a with: b [
        "Determine if a and b are equal"

        <category: 'evaluation'>
        ^a = b
    ]

    checkNumber: anOperator operand: anOperand [
        "Check valid operand for unary expression"

        <category: 'evaluation'>
        (anOperand class = FloatD) ifFalse: [
            ^RuntimeError
                error: anOperator
                message: 'Operand must be a number.'
        ]
    ]

    checkNumber: anOperator left: aLeft right: aRight [
        "Check valid operands for binary expression"

        <category: 'evaluation'>
        ((aLeft class = FloatD) & (aRight class = FloatD)) ifFalse: [
            ^RuntimeError
                error: anOperator
                message: 'Operands must be numbers.'
        ]
    ]

    visitBlockStmt: stmt [
        "Evaluate a block of statements"

        <category: 'evaluation'>
        self
            executeBlock: stmt statements
            environment: (Environment enclosing: environment).
        ^nil.
    ]

    visitExpressionStmt: stmt [
        "Evaluate an expression statement"

        <category: 'evaluation'>
        self evaluate: stmt expression.
    ]

    visitPrintStmt: stmt [
        "Evaluate a print statement"

        <category: 'evaluation'>
        | value |
        value := self evaluate: stmt expression.
        (self stringify: value) displayNl.
    ]

    visitVarStmt: stmt [
        "Evaluate a variable declaration statement"

        <category: 'evaluation'>
        | value |
        value := nil.
        stmt initializer ifNotNil: [
            value := self evaluate: stmt initializer
        ].
        environment define: (stmt name lexeme) value: value.
        ^nil.
    ]

    visitAssignExpr: expr [
        "Evaluate a variable assignment expression"

        <category: 'evaluation'>
        | value |
        value := self evaluate: expr value.
        environment assign: expr name value: value.
        ^value.
    ]

    visitLiteralExpr: expr [
        "Evaluate a literal expression"

        <category: 'evaluation'>
        ^expr value.
    ]

    visitGroupingExpr: expr [
        "Evaluate a grouping expression"

        <category: 'evaluation'>
        ^self evaluate: expr expression.
    ]

    visitUnaryExpr: expr [
        "Evaluate a unary expression"

        <category: 'evaluation'>
        | right operator type |
        right := self evaluate: expr right.
        operator := expr operator.
        type := operator type.
        
        type = #Bang ifTrue: [ ^self isTruthy: right not ].
        type = #Minus ifTrue: [
            self checkNumber: operator operand: right.
            ^right negated
        ].
        
        "Unreachable"
        ^nil
    ]

    visitVariableExpr: expr [
        "Evaluate a variable expression"

        <category: 'evaluation'>
        ^environment get: expr name.
    ]

    visitBinaryExpr: expr [
        "Evaluate a binary expression"

        <category: 'evaluation'>
        | right left operator type |
        right := self evaluate: expr right.
        left := self evaluate: expr left.
        operator := expr operator.
        type := operator type.

        type = #BangEqual ifTrue: [ ^(self isEqual: left with: right) not ].
        type = #EqualEqual ifTrue: [ ^self isEqual: left with: right ].
        type = #Greater ifTrue: [
            self checkNumber: operator left: left right: right.
            ^left > right
        ].
        type = #GreaterEqual ifTrue: [
            self checkNumber: operator left: left right: right.
            ^left >= right
        ].
        type = #Less ifTrue: [
            self checkNumber: operator left: left right: right.
            ^left < right
        ].
        type = #LessEqual ifTrue: [
            self checkNumber: operator left: left right: right.
            ^left <= right
        ].
        type = #Minus ifTrue: [
            self checkNumber: operator left: left right: right.
            ^left - right
        ].
        type = #Plus ifTrue: [
            ((left respondsTo: #+) & (right respondsTo: #+)) ifTrue: [
                ^left + right 
            ].

            ((left respondsTo: #,) & (right respondsTo: #,)) ifTrue: [
                ^left , right 
            ].
            
            ^RuntimeError
                error: expr operator
                message: 'Operands must be two numbers or two strings.'
        ].
        type = #Slash ifTrue: [
            self checkNumber: operator left: left right: right.
            ^left / right
        ].
        type = #Star ifTrue: [
            self checkNumber: operator left: left right: right.
            ^left * right
        ].
        
        "Unreachable"
        ^nil 
    ]
]
