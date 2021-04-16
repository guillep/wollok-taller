Class {
	#name : #WKBytecodeClass,
	#superclass : #WKBytecodeElement,
	#instVars : [
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
	
	^ interpreter instantiateClass: self
]

{ #category : #accessing }
WKBytecodeClass >> interpreter [
	^ interpreter
]

{ #category : #accessing }
WKBytecodeClass >> interpreter: anObject [
	interpreter := anObject
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
