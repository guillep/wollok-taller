Class {
	#name : #WKPopIntoInstanceVariable,
	#superclass : #WKBytecode,
	#instVars : [
		'index'
	],
	#category : #'WollokVM-BytecodeCompiler'
}

{ #category : #'as yet unclassified' }
WKPopIntoInstanceVariable >> bytecodeSize [
	
	^ 2
]

{ #category : #accessing }
WKPopIntoInstanceVariable >> index [
	^ index
]

{ #category : #accessing }
WKPopIntoInstanceVariable >> index: anObject [
	index := anObject
]

{ #category : #encoding }
WKPopIntoInstanceVariable >> writeOn: aWriteStream [ 
	
	"13 is pop into instance variable, follow with iv index"
	aWriteStream nextPut: 13.
	aWriteStream nextPut: index
]
