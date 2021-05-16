Class {
	#name : #WKBytecodeElement,
	#superclass : #VMStructType,
	#instVars : [
		'literals'
	],
	#category : #'WollokVM-BytecodeInterpreter'
}

{ #category : #translation }
WKBytecodeElement class >> instVarNamesAndTypesForTranslationDo: aBinaryBlock [
	"enumerate aBinaryBlock with the names and C type strings for the inst vars to include in a BytecodeDescriptor struct."
	self instVarNames do:
		[:ivn|
		aBinaryBlock
			value: ivn
			value: (ivn caseOf: {
							['literals']			->	[#('sqInt *')]
						}
						otherwise: [ 1halt ])]
]

{ #category : #accessing }
WKBytecodeElement >> classLiteralAt: anInteger [

	^ literals at: anInteger
]

{ #category : #decoding }
WKBytecodeElement >> decodeFrom: aReadStream [

	self subclassResponsibility
]

{ #category : #decoding }
WKBytecodeElement >> decodeMethodFrom: aReadStream [ 

	| beginMethod selector isNative methodBytecode parameters handlers |
	beginMethod := aReadStream next.
	self assert: beginMethod = 5.

	selector := literals at: aReadStream next.
	isNative := aReadStream next = 1.
	parameters := aReadStream next.
	
	isNative ifFalse: [
		methodBytecode := aReadStream upTo: 255 "end of method"
	].

	"Check if there is an exception table attached to this method"
	handlers := OrderedCollection new.
	aReadStream peek = 253 ifTrue: [
		aReadStream next.
		"While not end of table"
		[aReadStream peek = 253] whileFalse: [
			handlers add: (WKBytecodeExceptionHandler new
				rangeStart: aReadStream next;
				rangeEnd: aReadStream next;
				exceptionClassLiteralIndex: aReadStream next;
				handlerStart: aReadStream next;
				yourself) ] ].
	
	^ WKBytecodeMethod new
		bytecodeClass: self;
		selector: selector;
		isNative: isNative;
		numberOfParameters: parameters;
		methodBytecode: methodBytecode;
		exceptionHandlers: handlers;
		yourself
]

{ #category : #loading }
WKBytecodeElement >> finishLoadingIn: aWollokBytecodeInterpreter [

	self subclassResponsibility
]

{ #category : #accessing }
WKBytecodeElement >> literals [
	^ literals
]

{ #category : #accessing }
WKBytecodeElement >> literals: anObject [
	literals := anObject
]
