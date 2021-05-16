Class {
	#name : #WKBytecodeMethod,
	#superclass : #VMStructType,
	#instVars : [
		'selector',
		'isNative',
		'methodBytecode',
		'numberOfParameters',
		'bytecodeClass',
		'exceptionHandlers'
	],
	#category : #'WollokVM-BytecodeInterpreter'
}

{ #category : #translation }
WKBytecodeMethod class >> instVarNamesAndTypesForTranslationDo: aBinaryBlock [
	"enumerate aBinaryBlock with the names and C type strings for the inst vars to include in a BytecodeDescriptor struct."
	self filteredInstVarNames do:
		[:ivn|
		aBinaryBlock
			value: ivn
			value: (ivn caseOf: {
							[ 'selector'  		]			->	['char *'].
							[ 'isNative'   		]			->	['bool'].
							[ 'methodBytecode'		]			->	['uint8_t *'].
							[ 'numberOfParameters'				]			->	['int'].
							[ 'bytecodeClass'	]			->	['struct _VMBytecodeClass *'].
							[ 'exceptionHandlers'	]			->	['void*'].
						}
						otherwise: [ 1halt ])]
]

{ #category : #accessing }
WKBytecodeMethod >> bytecodeClass [
	^ bytecodeClass
]

{ #category : #accessing }
WKBytecodeMethod >> bytecodeClass: anObject [
	bytecodeClass := anObject
]

{ #category : #accessing }
WKBytecodeMethod >> exceptionHandlers [
	^ exceptionHandlers
]

{ #category : #accessing }
WKBytecodeMethod >> exceptionHandlers: aCollection [ 

	exceptionHandlers := aCollection 
]

{ #category : #accessing }
WKBytecodeMethod >> isNative [
	^ isNative
]

{ #category : #accessing }
WKBytecodeMethod >> isNative: anObject [
	isNative := anObject
]

{ #category : #accessing }
WKBytecodeMethod >> methodBytecode [
	
	^ methodBytecode
]

{ #category : #accessing }
WKBytecodeMethod >> methodLiteralAt: anInteger [
	
	^ bytecodeClass classLiteralAt: anInteger
]

{ #category : #accessing }
WKBytecodeMethod >> numberOfParameters [
	
	^ numberOfParameters
]

{ #category : #accessing }
WKBytecodeMethod >> numberOfParameters: anObject [
	numberOfParameters := anObject
]

{ #category : #accessing }
WKBytecodeMethod >> selector [
	^ selector
]

{ #category : #accessing }
WKBytecodeMethod >> selector: anObject [

	selector := anObject
]

{ #category : #accessing }
WKBytecodeMethod >> setMethodBytecode: bytecode [ 
	
	methodBytecode := bytecode
]
