Class {
	#name : #WollokFalse,
	#superclass : #WollokVMObject,
	#category : #'WollokVM-Memory'
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

	^ memory asWollokBoolean: anotherWollokObject isWollokFalse
]

{ #category : #native }
WollokFalse >> wollokIdentity [
	
	^ memory asWollokNumber: false identityHash
]

{ #category : #'logical operations' }
WollokFalse >> | unBooleano [

	^ unBooleano
]
