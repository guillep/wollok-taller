Class {
	#name : #WKBytecode,
	#superclass : #Object,
	#instVars : [
		'position'
	],
	#category : #'WollokVM-BytecodeCompiler'
}

{ #category : #'as yet unclassified' }
WKBytecode >> bytecodeSize [

	^ self subclassResponsibility
]

{ #category : #accessing }
WKBytecode >> position [
	^ position
]

{ #category : #accessing }
WKBytecode >> position: anObject [
	position := anObject
]
