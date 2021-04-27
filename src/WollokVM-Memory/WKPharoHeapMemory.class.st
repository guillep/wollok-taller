Class {
	#name : #WKPharoHeapMemory,
	#superclass : #Object,
	#instVars : [
		'trueObject',
		'falseObject',
		'nullObject',
		'interpreter'
	],
	#category : #'WollokVM-Memory'
}

{ #category : #converting }
WKPharoHeapMemory >> asPharoBoolean: oop [
	
	oop = trueObject ifTrue: [ ^ true ].
	oop = falseObject ifTrue: [ ^ false ].
	self error: 'invalid boolean'
]

{ #category : #converting }
WKPharoHeapMemory >> asPharoNumber: aWollokObject [ 
	
	| sd |
	sd := aWollokObject literalValue asScaledDecimal.
	^ ScaledDecimal newFromNumber: sd scale: (sd scale max: 8)
]

{ #category : #converting }
WKPharoHeapMemory >> asPharoString: aWollokVMLiteral [ 
	
	^ aWollokVMLiteral literalValue
]

{ #category : #visiting }
WKPharoHeapMemory >> asWollokBoolean: aPharoBoolean [
	
	^ aPharoBoolean
		ifTrue: [ trueObject ]
		ifFalse: [ falseObject ]
]

{ #category : #literals }
WKPharoHeapMemory >> asWollokNumber: anInteger [ 

	^ WollokVMLiteral new
		wollokClass: (self resolve: 'wollok.lang.Number');
		literalValue: anInteger;
		yourself
]

{ #category : #converting }
WKPharoHeapMemory >> asWollokString: aString [ 

	^ WollokVMLiteral new
		wollokClass: (self resolve: 'wollok.lang.String');
		literalValue: aString;
		yourself
]

{ #category : #'object-format' }
WKPharoHeapMemory >> classOf: aWollokObject [ 
	
	^ aWollokObject wollokClass 
]

{ #category : #accessing }
WKPharoHeapMemory >> falseObject [
	^ falseObject
]

{ #category : #accessing }
WKPharoHeapMemory >> falseObject: anObject [
	falseObject := anObject
]

{ #category : #'object-format' }
WKPharoHeapMemory >> fetchInstanceVariable: instanceVariableIndex ofObject: anObject [
	
	^ anObject wollokInstanceVariableAt: instanceVariableIndex
]

{ #category : #'object-format' }
WKPharoHeapMemory >> identityOf: anOop [
	
	^ anOop wollokIdentity
]

{ #category : #initialization }
WKPharoHeapMemory >> initializeHeap [
	
	trueObject := WollokTrue new
		memory: self;
		wollokClass: (self resolve: 'wollok.lang.Boolean');
		yourself.

	falseObject := WollokFalse new
		memory: self;
		wollokClass: (self resolve: 'wollok.lang.Boolean');
		yourself.
		
	nullObject := WollokVMObject new
		memory: self;
		yourself.
]

{ #category : #allocation }
WKPharoHeapMemory >> instantiateClass: aClass [

	^ WollokVMObject new
		wollokClass: aClass;
		memory: self;
		yourself
]

{ #category : #allocation }
WKPharoHeapMemory >> instantiateList [

	| class |
	class := self resolve: 'wollok.lang.List'.
	^ WollokVMLiteral new
		wollokClass: class;
		memory: self;
		literalValue: OrderedCollection new;
		yourself.
]

{ #category : #accessing }
WKPharoHeapMemory >> interpreter [
	^ interpreter
]

{ #category : #accessing }
WKPharoHeapMemory >> interpreter: anObject [
	interpreter := anObject
]

{ #category : #testing }
WKPharoHeapMemory >> isNull: aWollokObject [
	
	^ aWollokObject == nullObject 
]

{ #category : #accessing }
WKPharoHeapMemory >> nullObject [
	^ nullObject
]

{ #category : #accessing }
WKPharoHeapMemory >> nullObject: anObject [
	nullObject := anObject
]

{ #category : #'name resolution' }
WKPharoHeapMemory >> resolve: aString [ 
	
	^ interpreter resolve: aString
]

{ #category : #'object-format' }
WKPharoHeapMemory >> storeInstanceVariable: instanceVariableIndex ofObject: anObject withValue: aValue [ 
	
	anObject wollokInstanceVariableAt: instanceVariableIndex put: aValue
]

{ #category : #accessing }
WKPharoHeapMemory >> trueObject [
	^ trueObject
]

{ #category : #accessing }
WKPharoHeapMemory >> trueObject: anObject [
	trueObject := anObject
]

{ #category : #'object-format' }
WKPharoHeapMemory >> wollokClassName: aWollokObject [ 
	
	^ (self classOf: aWollokObject) name
]
