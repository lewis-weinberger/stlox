Object subclass: Callable [
    <comment: 'My instances can be called.'>
    call: anInterpreter arguments: someArguments [
        "Evaluate the function/class call"

        <category: 'evaluation'>
        self subclassResponsibility
    ]

    arity [
        <category: 'evaluation'>
        self subclassResponsibility
    ]
]

Callable subclass: Clock [
    <comment: 'A native function to measure time'>
    call: anInterpreter arguments: someArguments [
        "Evaluate the clock() function call, returning seconds since
         midnight 01/01/1901"

        <category: 'evaluation'>
        ^Time secondClock
    ]

    arity [
        <category: 'evaluation'>
        ^0
    ]
]

Eval [
    Time initialize
]
