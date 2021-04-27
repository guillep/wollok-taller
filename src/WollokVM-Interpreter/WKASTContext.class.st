Class {
	#name : #WKASTContext,
	#superclass : #Object,
	#instVars : [
		'method',
		'receiver',
		'arguments'
	],
	#category : #'WollokVM-Interpreter'
}

{ #category : #accessing }
WKASTContext >> arguments [
	^ arguments
]

{ #category : #accessing }
WKASTContext >> arguments: anObject [
	arguments := anObject
]

{ #category : #accessing }
WKASTContext >> method [
	^ method
]

{ #category : #accessing }
WKASTContext >> method: aWollokMethodDeclarationNode [ 
	method := aWollokMethodDeclarationNode
]

{ #category : #'name-resolution' }
WKASTContext >> readVariable: aString [ 
	
	| index |
	index := (method parameters collect: [ :e | e parameter value ]) indexOf: aString.
	self haltIf: index = 0.
	^ arguments at: index
]

{ #category : #accessing }
WKASTContext >> receiver [
	^ receiver
]

{ #category : #accessing }
WKASTContext >> receiver: anObject [
	receiver := anObject
]
