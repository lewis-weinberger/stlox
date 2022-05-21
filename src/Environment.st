Object subclass: Environment [
    | values enclosing |
    <comment: 'My instances are environments for variable bindings.'>

    Environment class >> new [
        "Answer with a new environment"

        <category: 'instance creation'>
        | x |
        x := super new.
        x init.
        ^x.
    ]

    Environment class >> enclosing: anEnclosing [
        "Answer with a enclosed environment "

        <category: 'instance creation'>
        ^self new
            enclosing: anEnclosing.
    ]

    init [
        "Initialise the environment"

        <category: 'initialization'>
        values := Dictionary new.
        enclosing := nil.
    ]

    enclosing: anEnclosing [
        "Set the enclosing environment"

        <category: 'setter'>
        enclosing := anEnclosing.
    ]

    define: aName value: aValue [
        "Variable definition"

        <category: 'built ins'>
        values at: aName put: aValue.
    ]

    get: aName [
        "Variable look-up"

        <category: 'built ins'>
        (values includesKey: aName lexeme) ifTrue: [
            ^values at: aName lexeme.
        ].

        enclosing ifNotNil: [ ^enclosing get: aName ].

        ^RuntimeError
            error: aName
            message: 'Undefined variable ''' , aName lexeme , '''.'.
    ]

    assign: aName value: aValue [
        "Variable assignment"

        <category: 'built ins'>
        (values includesKey: aName lexeme) ifTrue: [
            values at: aName lexeme put: aValue.
            ^aValue.
        ].

        enclosing ifNotNil: [ ^enclosing assign: aName value: aValue ].

        ^RuntimeError
            error: aName
            message: 'Undefined variable ''' , aName lexeme , '''.'.
    ]
]
