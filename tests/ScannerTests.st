TestCase subclass: ScannerTests [
    TestIdentifiers [
        "Test the scanning of identifiers"

        <category: 'testing'>
        | src scanner tokens expected |
        src := 'andy formless fo _ _123 _abc ab123
abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_'.
        scanner := Scanner source: src.
        tokens := scanner scanTokens.

        expected := OrderedCollection new.
        expected
            add: (Token type: #Identifier lexeme: 'andy' literal: nil line: 1);
            add: (Token type: #Identifier lexeme: 'formless' literal: nil line: 1);
            add: (Token type: #Identifier lexeme: 'fo' literal: nil line: 1);
            add: (Token type: #Identifier lexeme: '_' literal: nil line: 1);
            add: (Token type: #Identifier lexeme: '_123' literal: nil line: 1);
            add: (Token type: #Identifier lexeme: '_abc' literal: nil line: 1);
            add: (Token type: #Identifier lexeme: 'ab123' literal: nil line: 1);
            add: (Token type: #Identifier lexeme: 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_' literal: nil line: 2);
            add: (Token type: #EOF lexeme: '' literal: nil line: 2).

        1 to: (expected size) do: [ :i | self assert: (tokens at: i) = (expected at: i) ]
    ]

    TestKeywords [
        "Test the scanning of keywords"

        <category: 'testing'>
        | src scanner tokens expected |
        src := 'and class else false for fun if nil or return super this true var while'.
        scanner := Scanner source: src.
        tokens := scanner scanTokens.

        expected := OrderedCollection new.
        expected
            add: (Token type: #And lexeme: 'and' literal: nil line: 1);
            add: (Token type: #Class lexeme: 'class' literal: nil line: 1);
            add: (Token type: #Else lexeme: 'else' literal: nil line: 1);
            add: (Token type: #False lexeme: 'false' literal: nil line: 1);
            add: (Token type: #For lexeme: 'for' literal: nil line: 1);
            add: (Token type: #Fun lexeme: 'fun' literal: nil line: 1);
            add: (Token type: #If lexeme: 'if' literal: nil line: 1);
            add: (Token type: #Nil lexeme: 'nil' literal: nil line: 1);
            add: (Token type: #Or lexeme: 'or' literal: nil line: 1);
            add: (Token type: #Return lexeme: 'return' literal: nil line: 1);
            add: (Token type: #Super lexeme: 'super' literal: nil line: 1);
            add: (Token type: #This lexeme: 'this' literal: nil line: 1);
            add: (Token type: #True lexeme: 'true' literal: nil line: 1);
            add: (Token type: #Var lexeme: 'var' literal: nil line: 1);
            add: (Token type: #While lexeme: 'while' literal: nil line: 1);
            add: (Token type: #EOF lexeme: '' literal: nil line: 1).

        1 to: (expected size) do: [ :i | self assert: (tokens at: i) = (expected at: i) ]
    ]

    TestNumbers [
        "Test the scanning of numbers"

        <category: 'testing'>
        | src scanner tokens expected |
        src := '123
123.456
.456
123.'.
        scanner := Scanner source: src.
        tokens := scanner scanTokens.

        expected := OrderedCollection new.
        expected
            add: (Token type: #Number lexeme: '123' literal: 123.0 line: 1);
            add: (Token type: #Number lexeme: '123.456' literal: 123.456 line: 2);
            add: (Token type: #Dot lexeme: '.' literal: nil line: 3);
            add: (Token type: #Number lexeme: '456' literal: 456.0 line: 3);
            add: (Token type: #Number lexeme: '123' literal: 123.0 line: 4);
            add: (Token type: #Dot lexeme: '.' literal: nil line: 4);
            add: (Token type: #EOF lexeme: '' literal: nil line: 4).

        1 to: (expected size) do: [ :i | self assert: (tokens at: i) = (expected at: i) ]
    ]

    TestPunctuation [
        "Test the scanning of punctuation"

        <category: 'testing'>
        | src scanner tokens expected |
        src := '(){};,+-*!===<=>=!=<>/.'.
        scanner := Scanner source: src.
        tokens := scanner scanTokens.

        expected := OrderedCollection new.
        expected
            add: (Token type: #LeftParen lexeme: '(' literal: nil line: 1);
            add: (Token type: #RightParen lexeme: ')' literal: nil line: 1);
            add: (Token type: #LeftBrace lexeme: '{' literal: nil line: 1);
            add: (Token type: #RightBrace lexeme: '}' literal: nil line: 1);
            add: (Token type: #Semicolon lexeme: ';' literal: nil line: 1);
            add: (Token type: #Comma lexeme: ',' literal: nil line: 1);
            add: (Token type: #Plus lexeme: '+' literal: nil line: 1);
            add: (Token type: #Minus lexeme: '-' literal: nil line: 1);
            add: (Token type: #Star lexeme: '*' literal: nil line: 1);
            add: (Token type: #BangEqual lexeme: '!=' literal: nil line: 1);
            add: (Token type: #EqualEqual lexeme: '==' literal: nil line: 1);
            add: (Token type: #LessEqual lexeme: '<=' literal: nil line: 1);
            add: (Token type: #GreaterEqual lexeme: '>=' literal: nil line: 1);
            add: (Token type: #BangEqual lexeme: '!=' literal: nil line: 1);
            add: (Token type: #Less lexeme: '<' literal: nil line: 1);
            add: (Token type: #Greater lexeme: '>' literal: nil line: 1);
            add: (Token type: #Slash lexeme: '/' literal: nil line: 1);
            add: (Token type: #Dot lexeme: '.' literal: nil line: 1);
            add: (Token type: #EOF lexeme: '' literal: nil line: 1).

        1 to: (expected size) do: [ :i | self assert: (tokens at: i) = (expected at: i) ]
    ]

    TestStrings [
        "Test the scanning of strings"

        <category: 'testing'>
        | src scanner tokens expected |
        src := '""
"string"'.
        scanner := Scanner source: src.
        tokens := scanner scanTokens.

        expected := OrderedCollection new.
        expected
            add: (Token type: #String lexeme: '""' literal: '' line: 1);
            add: (Token type: #String lexeme: '"string"' literal: 'string' line: 2);
            add: (Token type: #EOF lexeme: '' literal: nil line: 2).

        1 to: (expected size) do: [ :i | self assert: (tokens at: i) = (expected at: i) ]
    ]

    TestWhitespace [
        "Test the scanning of whitespace"

        <category: 'testing'>
        | src scanner tokens expected |
        src := 'space    tabs				newlines




end'.
        scanner := Scanner source: src.
        tokens := scanner scanTokens.

        expected := OrderedCollection new.
        expected
            add: (Token type: #Identifier lexeme: 'space' literal: nil line: 1);
            add: (Token type: #Identifier lexeme: 'tabs' literal: nil line: 1);
            add: (Token type: #Identifier lexeme: 'newlines' literal: nil line: 1);
            add: (Token type: #Identifier lexeme: 'end' literal: nil line: 6);
            add: (Token type: #EOF lexeme: '' literal: nil line: 6).

        1 to: (expected size) do: [ :i | self assert: (tokens at: i) = (expected at: i) ]
    ]
]
