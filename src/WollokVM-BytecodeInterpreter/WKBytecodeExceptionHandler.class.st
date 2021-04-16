Class {
	#name : #WKBytecodeExceptionHandler,
	#superclass : #Object,
	#instVars : [
		'rangeStart',
		'rangeEnd',
		'handlerStart',
		'exceptionClassLiteralIndex'
	],
	#category : #'WollokVM-BytecodeInterpreter'
}

{ #category : #accessing }
WKBytecodeExceptionHandler >> exceptionClassLiteralIndex [
	^ exceptionClassLiteralIndex
]

{ #category : #accessing }
WKBytecodeExceptionHandler >> exceptionClassLiteralIndex: anObject [
	exceptionClassLiteralIndex := anObject
]

{ #category : #accessing }
WKBytecodeExceptionHandler >> handlerStart [
	^ handlerStart
]

{ #category : #accessing }
WKBytecodeExceptionHandler >> handlerStart: anObject [
	handlerStart := anObject
]

{ #category : #testing }
WKBytecodeExceptionHandler >> includesBytecode: anInteger [	
	
	^ anInteger between: rangeStart and: rangeEnd
]

{ #category : #accessing }
WKBytecodeExceptionHandler >> rangeEnd [
	^ rangeEnd
]

{ #category : #accessing }
WKBytecodeExceptionHandler >> rangeEnd: anObject [
	rangeEnd := anObject
]

{ #category : #accessing }
WKBytecodeExceptionHandler >> rangeStart [
	^ rangeStart
]

{ #category : #accessing }
WKBytecodeExceptionHandler >> rangeStart: anObject [
	rangeStart := anObject
]
