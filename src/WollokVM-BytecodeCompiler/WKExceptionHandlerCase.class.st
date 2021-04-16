Class {
	#name : #WKExceptionHandlerCase,
	#superclass : #Object,
	#instVars : [
		'start',
		'exceptionNameLiteralIndex'
	],
	#category : #'WollokVM-BytecodeCompiler'
}

{ #category : #accessing }
WKExceptionHandlerCase >> exceptionNameLiteralIndex [
	^ exceptionNameLiteralIndex
]

{ #category : #accessing }
WKExceptionHandlerCase >> exceptionNameLiteralIndex: anObject [
	exceptionNameLiteralIndex := anObject
]

{ #category : #accessing }
WKExceptionHandlerCase >> start [
	^ start
]

{ #category : #accessing }
WKExceptionHandlerCase >> start: anObject [
	start := anObject
]
