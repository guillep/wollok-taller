Class {
	#name : #WollokTrue,
	#superclass : #WollokVMObject,
	#category : #'WollokVM-Memory'
}

{ #category : #'logical operations' }
WollokTrue >> & unBooleano [

	^ unBooleano
]

{ #category : #'logical operations' }
WollokTrue >> isWollokFalse [

	^ false
]

{ #category : #'logical operations' }
WollokTrue >> isWollokTrue [

	^ true
]

{ #category : #accessing }
WollokTrue >> literalValue [
	
	^ true
]

{ #category : #'native methods' }
WollokTrue >> | aWollokBoolean [

	^ self
]
