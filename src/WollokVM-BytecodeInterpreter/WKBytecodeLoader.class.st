Class {
	#name : #WKBytecodeLoader,
	#superclass : #Object,
	#instVars : [
		'bindings',
		'asts',
		'interpreter',
		'program'
	],
	#category : #'WollokVM-BytecodeInterpreter'
}

{ #category : #actions }
WKBytecodeLoader >> addBindingOfClass: aName fromString: aString [

	| anAST astclass |
	anAST := WollokParser parse: aString.
	anAST attributeNamed: #source put: aString.
	asts at: aName put: anAST children first.

	astclass := WollokASTVMClass new
		name: aName;
		ast: anAST;
		yourself.
	
	^ self compileAndInstall: astclass
]

{ #category : #actions }
WKBytecodeLoader >> basicCompile: anAST [
	
	^ WollokBytecodeCompiler new
		loader: WollokReducedLoader new;
		asts: asts;
		compile: anAST;
		results
]

{ #category : #actions }
WKBytecodeLoader >> basicDecodeStringFrom: aReadStream [ 
	
	| stringSize |
	stringSize := aReadStream next.
	^ (aReadStream next: stringSize) utf8Decoded
]

{ #category : #actions }
WKBytecodeLoader >> compileAndInstall: astclass [

	| results |
	results := self basicCompile: astclass ast.
	results do: [ :e | self load: e ].
	^ bindings at: astclass name
]

{ #category : #'literal-decoding' }
WKBytecodeLoader >> decodeBooleanFrom: aReadStream [
	
	^ (aReadStream next = 1)
		ifTrue: [ self memory trueObject ]
		ifFalse: [ self memory falseObject ]
]

{ #category : #'literal-decoding' }
WKBytecodeLoader >> decodeLiteralFrom: aReadStream [ 
	
	| literalKind |
	literalKind := aReadStream next.
	literalKind = 1 "boolean"
		ifTrue: [ ^ self decodeBooleanFrom: aReadStream ].
	literalKind = 2 "string"
		ifTrue: [ ^ self decodeStringFrom: aReadStream ].
	literalKind = 3 "number"
		ifTrue: [ ^ self decodeNumberFrom: aReadStream ].
	literalKind = 4 "nil"
		ifTrue: [ ^ self decodeNilFrom: aReadStream ].
	self notYetImplemented
]

{ #category : #'literal-decoding' }
WKBytecodeLoader >> decodeNilFrom: aReadStream [ 
	
	^ self memory nullObject
]

{ #category : #'literal-decoding' }
WKBytecodeLoader >> decodeNumberFrom: aReadStream [ 
	
	| numerator denominator scale |
	numerator := aReadStream next: 8.
	denominator := aReadStream next: 8.
	scale := aReadStream next.
	
	^ self memory asWollokNumber: (ScaledDecimal
		newFromNumber: (numerator asInteger / denominator asInteger)
		scale: scale)
]

{ #category : #'literal-decoding' }
WKBytecodeLoader >> decodeStringFrom: aReadStream [ 

	^ self memory asWollokString: (self basicDecodeStringFrom: aReadStream)
]

{ #category : #initialization }
WKBytecodeLoader >> initialize [

	super initialize.
	bindings := Dictionary new.
	asts := Dictionary new
]

{ #category : #accessing }
WKBytecodeLoader >> interpreter [
	^ interpreter
]

{ #category : #accessing }
WKBytecodeLoader >> interpreter: anObject [
	interpreter := anObject
]

{ #category : #actions }
WKBytecodeLoader >> load: bytecode [

	| behaviourClass wollokBytecodeClass stream name |
	behaviourClass := bytecode first = 1
		ifTrue: [ WKBytecodeProgram ]
		ifFalse: [ bytecode first = 2
			ifTrue: [ WKBytecodeClass ]
			ifFalse: [ WKBytecodeObject ] ].
	
	"Decode the name first, to be able to register it"
	stream := bytecode readStream.
	stream next: 3 "skip type and number of literals and type of literal".
	name := self basicDecodeStringFrom: stream.
	
	wollokBytecodeClass := behaviourClass new.
	wollokBytecodeClass interpreter: self.
	wollokBytecodeClass name: name.
	
	"Registering before loading to cut potential recursions"
	bindings at: name put: wollokBytecodeClass.
	
	self loadBytecode: bytecode in: wollokBytecodeClass.
	^ wollokBytecodeClass
]

{ #category : #actions }
WKBytecodeLoader >> loadBytecode: bytecode in: aWollokElement [
	
	| literals | 
	literals := OrderedCollection new.
	bytecode readStreamDo: [ :stream | | type |
		type := stream next.
		self assert: type <= 3 "program, class or object for now.".
		(1 to: stream next) collect: [ :i | 
			literals add: (self decodeLiteralFrom: stream) ].
		aWollokElement literals: literals.
		aWollokElement decodeFrom: stream.
		aWollokElement finishLoadingIn: self.
	]
]

{ #category : #actions }
WKBytecodeLoader >> loadName: aClassName [

	"If already loaded, use it"
	| astclass |
	bindings at: aClassName ifPresent: [ :c | ^ c ].

	"Otherwise, load it"
	astclass := [
		WollokReducedLoader new
			loadClassNamed: aClassName
			in: self ]
		on: Error do: [ :err |
		WollokReducedLoader new
			loadClassNamed: 'wollok.lang.', aClassName
			in: self	].
	
	^ self compileAndInstall: astclass
]

{ #category : #'literal-decoding' }
WKBytecodeLoader >> memory [

	^ interpreter memory
]

{ #category : #accessing }
WKBytecodeLoader >> program: aWKBytecodeProgram [ 

	program := aWKBytecodeProgram
]
