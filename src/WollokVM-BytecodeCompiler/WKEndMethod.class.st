Class {
	#name : #WKEndMethod,
	#superclass : #WKBytecode,
	#instVars : [
		'exceptionHandlers',
		'methodStart'
	],
	#category : #'WollokVM-BytecodeCompiler'
}

{ #category : #encoding }
WKEndMethod >> bytecodeSize [
	
	^ 1
]

{ #category : #accessing }
WKEndMethod >> exceptionHandlers [
	^ exceptionHandlers
]

{ #category : #accessing }
WKEndMethod >> exceptionHandlers: aCollection [

	exceptionHandlers := aCollection 
]

{ #category : #accessing }
WKEndMethod >> methodStart [
	^ methodStart
]

{ #category : #accessing }
WKEndMethod >> methodStart: anObject [
	methodStart := anObject
]

{ #category : #encoding }
WKEndMethod >> writeExceptionTableOn: aWriteStream [

	exceptionHandlers ifEmpty: [ ^ self ].
	
	"Encode Start of Table"
	aWriteStream nextPut: 253.
	exceptionHandlers do: [ :e |
		e cases do: [ :c |
			"Encode the range"
			aWriteStream nextPut: e start position - methodStart position.
			aWriteStream nextPut: e end position - methodStart position.
			"The exception that matches"
			aWriteStream nextPut: c exceptionNameLiteralIndex.
			"Where to jump in this case"
			aWriteStream nextPut: c start position - methodStart position.
		]
	].
	"Encode End of Table"
	aWriteStream nextPut: 253
]

{ #category : #encoding }
WKEndMethod >> writeOn: aWriteStream [ 

	"Encode End of method"
	aWriteStream nextPut: 255.
	self writeExceptionTableOn: aWriteStream.
]
