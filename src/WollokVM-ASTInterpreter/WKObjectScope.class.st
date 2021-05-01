Class {
	#name : #WKObjectScope,
	#superclass : #Object,
	#instVars : [
		'object',
		'interpreter'
	],
	#category : #'WollokVM-ASTInterpreter'
}

{ #category : #'name resolution' }
WKObjectScope >> allVariablesOf: anObject [
	
	(interpreter memory classOf: object) ifNil: [ ^ #() ].
	^ (interpreter memory classOf: object) allVariables
]

{ #category : #accessing }
WKObjectScope >> interpreter [
	^ interpreter
]

{ #category : #accessing }
WKObjectScope >> interpreter: anObject [
	interpreter := anObject
]

{ #category : #accessing }
WKObjectScope >> object [
	^ object
]

{ #category : #accessing }
WKObjectScope >> object: anObject [
	object := anObject
]

{ #category : #'name resolution' }
WKObjectScope >> readVariable: aString [ 
	
	| index |
	index := (self allVariablesOf: object) indexOf: aString.
	^ interpreter memory fetchInstanceVariable: index ofObject: object
]

{ #category : #'name resolution' }
WKObjectScope >> scopeDefining: aString [ 
	
	((self allVariablesOf: object) includes: aString)
		ifTrue: [ ^ self ].
	self halt
]

{ #category : #'name resolution' }
WKObjectScope >> writeVariable: aString withValue: aValue [ 

	| index |
	index := (self allVariablesOf: object) indexOf: aString.
	^ interpreter memory storeInstanceVariable: index ofObject: object withValue: aValue
]
