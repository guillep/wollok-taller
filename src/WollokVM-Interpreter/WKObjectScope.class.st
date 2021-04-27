Class {
	#name : #WKObjectScope,
	#superclass : #Object,
	#instVars : [
		'object',
		'interpreter'
	],
	#category : #'WollokVM-Interpreter'
}

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
	index := (interpreter memory classOf: object) allVariables indexOf: aString.
	^ interpreter memory fetchInstanceVariable: index ofObject: object
]

{ #category : #'name resolution' }
WKObjectScope >> scopeDefining: aString [ 
	
	((interpreter memory classOf: object) allVariables includes: aString)
		ifTrue: [ ^ self ].
	self halt
]

{ #category : #'name resolution' }
WKObjectScope >> writeVariable: aString withValue: aValue [ 

	| index |
	index := (interpreter memory classOf: object) allVariables indexOf: aString.
	^ interpreter memory storeInstanceVariable: index ofObject: object withValue: aValue
]
