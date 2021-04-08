Class {
	#name : #WollokVMLiteral,
	#superclass : #WollokVMObject,
	#instVars : [
		'literalValue'
	],
	#category : #'WollokVM-Interpreter'
}

{ #category : #accessing }
WollokVMLiteral >> = aLiteral [

	^ literalValue = aLiteral literalValue
]

{ #category : #accessing }
WollokVMLiteral >> hash [

	^ literalValue hash
]

{ #category : #accessing }
WollokVMLiteral >> literalValue [
	
	^ literalValue
]

{ #category : #accessing }
WollokVMLiteral >> literalValue: anObject [
	literalValue := anObject
]
