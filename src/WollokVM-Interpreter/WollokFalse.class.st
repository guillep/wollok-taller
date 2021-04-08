Class {
	#name : #WollokFalse,
	#superclass : #WollokVMObject,
	#category : #'WollokVM-Interpreter'
}

{ #category : #'logical operations' }
WollokFalse >> isWollokFalse [

	^ true
]

{ #category : #'logical operations' }
WollokFalse >> isWollokTrue [

	^ false
]

{ #category : #accessing }
WollokFalse >> literalValue [
	
	^ false
]

{ #category : #operators }
WollokFalse >> wollokIdenticalTo: anotherWollokObject [

	^ interpreter asWollokBoolean: anotherWollokObject isWollokFalse
]

{ #category : #native }
WollokFalse >> wollokIdentity [
	
	^ interpreter asWollokNumber: false identityHash
]

{ #category : #'logical operations' }
WollokFalse >> | unBooleano [

	^ unBooleano
]
