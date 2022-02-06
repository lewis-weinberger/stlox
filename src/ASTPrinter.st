Object subclass: ASTPrinter [
    <comment: 'My instances are pretty printers for the Lox AST.'>

    print: anExpression [
        "Pretty print the given expression"

        <category: 'printing'>
        ^anExpression accept: self
    ]

    visitBinaryExpr: aBinary [
        "Handle the case of binary expressions"

        <category: 'printing'>
        ^self
            parenthesize: (aBinary operator lexeme)
            with: (aBinary left)
            with: (aBinary right).
    ]

    visitGroupingExpr: aGrouping [
        "Handle the case of group expressions"

        <category: 'printing'>
        ^self
            parenthesize: 'group'
            with: (aGrouping expression)
            with: nil.
    ]

    visitLiteralExpr: aLiteral [
        "Handle the case of literal expressions"

        <category: 'printing'>
        (aLiteral value) ifNil: [ ^'nil' ].
        ^aLiteral value displayString
    ]

    visitUnaryExpr: aUnary [
        "Handle the case of unary expressions"

        <category: 'printing'>
        ^self
            parenthesize: (aUnary operator lexeme)
            with: (aUnary right)
            with: nil.
    ]

    parenthesize: aName with: first with: second [
        "Recursively create display form for given expression"

        <category: 'printing'>
        | str |
        str := WriteStream on: String new.

        str 
            nextPutAll: '(' , aName;
            nextPutAll: ' ' , (first accept: self).
        second ifNotNil: [ str nextPutAll: ' ' , (second accept: self) ].
        str nextPutAll: ')'.

        ^str contents
    ]
]
