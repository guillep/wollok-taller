Class {
	#name : #WKBytecodeClass,
	#superclass : #Object,
	#instVars : [
		'literals',
		'methods',
		'superclass',
		'name',
		'interpreter'
	],
	#category : #'WollokVM-BytecodeInterpreter'
}

{ #category : #accessing }
WKBytecodeClass >> addMethod: aWKBytecodeMethod [ 
	
	methods at: aWKBytecodeMethod selector literalValue asSymbol put: aWKBytecodeMethod
]

{ #category : #accessing }
WKBytecodeClass >> allVariables [
	
	^ #()
]

{ #category : #decoding }
WKBytecodeClass >> decodeFrom: aReadStream [ 
	
	"Read Methods"
	[aReadStream atEnd] whileFalse: [
		self addMethod: (self decodeMethodFrom: aReadStream)
	]
]

{ #category : #decoding }
WKBytecodeClass >> decodeMethodFrom: aReadStream [ 

	| beginMethod selector isNative methodBytecode parameters |
	beginMethod := aReadStream next.
	self assert: beginMethod = 5.
	selector := literals at: aReadStream next.
	isNative := aReadStream next = 1.
	parameters := aReadStream next.
	
	isNative ifFalse: [
		methodBytecode := aReadStream upTo: 255 "end of method"
	].
	
	^ WKBytecodeMethod new
		bytecodeClass: self;
		selector: selector;
		isNative: isNative;
		numberOfParameters: parameters;
		methodBytecode: methodBytecode;
		yourself
]

{ #category : #loading }
WKBytecodeClass >> finishLoadingIn: aWollokBytecodeInterpreter [ 
	
	self superclassName ifNil: [ ^ nil ].
	superclass := aWollokBytecodeInterpreter resolve: self superclassName literalValue
]

{ #category : #accessing }
WKBytecodeClass >> initialize [

	super initialize.
	methods := Dictionary new.
]

{ #category : #instantiate }
WKBytecodeClass >> instantiate [
	
	^ WollokVMObject new
		wollokClass: self;
		interpreter: interpreter;
		yourself
]

{ #category : #accessing }
WKBytecodeClass >> interpreter [
	^ interpreter
]

{ #category : #accessing }
WKBytecodeClass >> interpreter: anObject [
	interpreter := anObject
]

{ #category : #accessing }
WKBytecodeClass >> literalAt: anInteger [ 
	
	^ literals at: anInteger
]

{ #category : #accessing }
WKBytecodeClass >> literals [
	^ literals
]

{ #category : #accessing }
WKBytecodeClass >> literals: aCollection [ 
	literals := aCollection
]

{ #category : #lookup }
WKBytecodeClass >> lookup: aString [

	^ methods at: aString ifAbsent: [ self superclass lookup: aString ]
]

{ #category : #accessing }
WKBytecodeClass >> methods [
	^ methods
]

{ #category : #accessing }
WKBytecodeClass >> methods: anObject [
	methods := anObject
]

{ #category : #accessing }
WKBytecodeClass >> name [
	
	^ name
]

{ #category : #accessing }
WKBytecodeClass >> name: aString [ 
	
	name := aString
]

{ #category : #accessing }
WKBytecodeClass >> superclass [
	
	^ superclass
]

{ #category : #accessing }
WKBytecodeClass >> superclass: anObject [
	superclass := anObject
]

{ #category : #accessing }
WKBytecodeClass >> superclassName [
	
	^ literals second
]
