Class {
	#name : #WKBytecodeClass,
	#superclass : #WKBytecodeElement,
	#instVars : [
		'methods',
		'superclass',
		'name',
		'interpreter',
		'numberOfSlots'
	],
	#category : #'WollokVM-BytecodeInterpreter'
}

{ #category : #enumerating }
WKBytecodeClass class >> filteredInstVarNames [
	"Eliminate the obvious simulation-only inst vars"
	^ super filteredInstVarNames copyWithoutAll: #(interpreter)
]

{ #category : #enumerating }
WKBytecodeClass class >> instVarNamesAndTypesForTranslationDo: aBinaryBlock [
	"enumerate aBinaryBlock with the names and C type strings for the inst vars to include in a BytecodeDescriptor struct."
	self filteredInstVarNames do:
		[:ivn|
		aBinaryBlock
			value: ivn
			value: (ivn caseOf: {
							[ 'literals'  		]			->	['sqInt *'].
							[ 'methods'   		]			->	['WKBytecodeMethod *'].
							[ 'superclass'		]			->	['struct _WKBytecodeClass *'].
							[ 'name'				]			->	['char *'].
							[ 'numberOfSlots'	]			->	['sqInt'].
						}
						otherwise: [ 1halt ])]
]

{ #category : #accessing }
WKBytecodeClass >> addMethod: aWKBytecodeMethod [ 

	methods at: (self memory asPharoString: aWKBytecodeMethod selector) asSymbol put: aWKBytecodeMethod
]

{ #category : #accessing }
WKBytecodeClass >> allVariables [
	
	^ #()
]

{ #category : #decoding }
WKBytecodeClass >> decodeFrom: aReadStream [ 
	
	"Read Methods"
	numberOfSlots := aReadStream next.
	[aReadStream atEnd] whileFalse: [
		self addMethod: (self decodeMethodFrom: aReadStream)
	]
]

{ #category : #loading }
WKBytecodeClass >> finishLoadingIn: aWollokBytecodeInterpreter [ 
	
	(self memory isNull: self superclassName) ifTrue: [ ^ nil ].
	superclass := aWollokBytecodeInterpreter loadName: (self memory asPharoString: self superclassName).
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
	<doNotGenerate>
	^ interpreter
]

{ #category : #accessing }
WKBytecodeClass >> interpreter: anObject [
	<doNotGenerate>
	interpreter := anObject
]

{ #category : #lookup }
WKBytecodeClass >> lookup: aString [

	^ methods at: aString ifAbsent: [ self superclass lookup: aString ]
]

{ #category : #accessing }
WKBytecodeClass >> memory [
	<doNotGenerate>
	^ interpreter memory
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
WKBytecodeClass >> numberOfSlots [
	
	^ numberOfSlots
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
