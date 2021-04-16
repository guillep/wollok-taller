Class {
	#name : #WKExceptionHandler,
	#superclass : #Object,
	#instVars : [
		'start',
		'end',
		'cases',
		'builder'
	],
	#category : #'WollokVM-BytecodeCompiler'
}

{ #category : #accessing }
WKExceptionHandler >> addCaseFor: aString startingAt: aWKLabel [ 
	
	| case |
	case := WKExceptionHandlerCase new.
	case exceptionNameLiteralIndex: (builder addLiteral: aString).
	case start: aWKLabel.
	cases add: case.
]

{ #category : #accessing }
WKExceptionHandler >> builder [
	^ builder
]

{ #category : #accessing }
WKExceptionHandler >> builder: anObject [
	builder := anObject
]

{ #category : #accessing }
WKExceptionHandler >> cases [
	^ cases
]

{ #category : #accessing }
WKExceptionHandler >> cases: anObject [
	cases := anObject
]

{ #category : #accessing }
WKExceptionHandler >> end [
	^ end
]

{ #category : #accessing }
WKExceptionHandler >> end: anObject [
	end := anObject
]

{ #category : #accessing }
WKExceptionHandler >> initialize [

	super initialize.
	cases := OrderedCollection new.
]

{ #category : #accessing }
WKExceptionHandler >> start [
	^ start
]

{ #category : #accessing }
WKExceptionHandler >> start: anObject [
	start := anObject
]
