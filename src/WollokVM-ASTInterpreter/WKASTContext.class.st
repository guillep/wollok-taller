Class {
	#name : #WKASTContext,
	#superclass : #Object,
	#instVars : [
		'method',
		'receiver',
		'arguments',
		'temporaries',
		'returned',
		'returnValue',
		'parent',
		'interpreter'
	],
	#category : #'WollokVM-ASTInterpreter'
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
WKASTContext >> at: name put: aValue [

	temporaries at: name put: aValue
]

{ #category : #accessing }
WKASTContext >> initialize [

	super initialize.
	temporaries := Dictionary new.
	returned := false
]

{ #category : #accessing }
WKASTContext >> interpreter: aWollokASTInterpreter [ 
	interpreter := aWollokASTInterpreter
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
WKASTContext >> parameterNames [
	
	^ method parameters collect: [ :e | e parameter value ]
]

{ #category : #'name-resolution' }
WKASTContext >> readVariable: aString [
	
	| index |
	temporaries at: aString ifPresent: [ :v | ^ v ].
	
	index := self parameterNames indexOf: aString.
	index > 0 ifTrue: [ ^ arguments at: index ].
	
	^ (WKObjectScope new
		object: receiver;
		interpreter: interpreter;
		yourself)
			readVariable: aString
]

{ #category : #accessing }
WKASTContext >> receiver [
	^ receiver
]

{ #category : #accessing }
WKASTContext >> receiver: anObject [
	receiver := anObject
]

{ #category : #returning }
WKASTContext >> return: aWollokObject [ 

	returned := true.	
	^ returnValue := aWollokObject
]

{ #category : #accessing }
WKASTContext >> returnValue [
	^ returnValue
]

{ #category : #testing }
WKASTContext >> returned [
	
	^ returned
]

{ #category : #'name resolution' }
WKASTContext >> scopeDefining: aString [ 
	
	(temporaries includesKey: aString) ifTrue: [ ^ self ].
	(self parameterNames includes: aString) ifTrue: [ ^self ].
	
	^ (WKObjectScope new
		object: receiver;
		interpreter: interpreter;
		yourself)
			scopeDefining: aString
]

{ #category : #'name resolution' }
WKASTContext >> writeVariable: aString withValue: anInteger [ 
	
	temporaries at: aString put: anInteger
]
