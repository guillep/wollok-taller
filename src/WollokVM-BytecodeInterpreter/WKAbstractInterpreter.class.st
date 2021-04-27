Class {
	#name : #WKAbstractInterpreter,
	#superclass : #Object,
	#instVars : [
		'memory'
	],
	#category : #'WollokVM-BytecodeInterpreter'
}

{ #category : #converting }
WKAbstractInterpreter >> asPharoBoolean: oop [

	^ memory asPharoBoolean: oop
]

{ #category : #converting }
WKAbstractInterpreter >> asWollokBoolean: aBoolean [
	
	^ memory asWollokBoolean: aBoolean
]

{ #category : #'memory-access' }
WKAbstractInterpreter >> asWollokNumber: aPharoNumber [
	
	^ memory asWollokNumber: aPharoNumber
]

{ #category : #'memory-access' }
WKAbstractInterpreter >> classOf: aWollokObject [
	
	^ memory classOf: aWollokObject
]

{ #category : #testing }
WKAbstractInterpreter >> isFalse: aWollokObject [
	
	^ aWollokObject == memory falseObject
]

{ #category : #testing }
WKAbstractInterpreter >> isNull: aWollokVMObject [ 
	
	^ memory nullObject == aWollokVMObject
]

{ #category : #testing }
WKAbstractInterpreter >> isTrue: aWollokObject [
	
	^ memory trueObject == aWollokObject
]

{ #category : #accessing }
WKAbstractInterpreter >> memory: aMemory [
	
	memory := aMemory.
	memory interpreter: self.
	memory initializeHeap
]

{ #category : #'memory-access' }
WKAbstractInterpreter >> wollokClassName: aWollokObject [
	
	^ memory wollokClassName: aWollokObject
]
