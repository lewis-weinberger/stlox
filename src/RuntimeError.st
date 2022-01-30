Warning subclass: RuntimeError [
    | token message |
    <comment: 'My instances are Lox runtime exceptions.'>

    RuntimeError class >> error: aToken message: aMessage [
        "Raise a runtime exception"

        <category: 'instance creation'>
        ^self new
            token: aToken;
            message: aMessage;
            signal
    ]

    token: aToken [
        <category: 'setter'>
        token := aToken.
    ]

    message: aMessage [
        <category: 'setter'>
        message := aMessage.
    ]

    token [
        <category: 'getter'>
        ^token.
    ]

    message [
        <category: 'getter'>
        ^message.
    ]
]
