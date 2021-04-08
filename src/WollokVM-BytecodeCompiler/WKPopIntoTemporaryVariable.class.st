Class {
	#name : #WKPopIntoTemporaryVariable,
	#superclass : #WKBytecode,
	#instVars : [
		'index'
	],
	#category : #'WollokVM-BytecodeCompiler'
}

{ #category : #'as yet unclassified' }
WKPopIntoTemporaryVariable >> bytecodeSize [

	^ 2
]

{ #category : #accessing }
WKPopIntoTemporaryVariable >> index [
	^ index
]

{ #category : #accessing }
WKPopIntoTemporaryVariable >> index: anObject [
	index := anObject
]

{ #category : #'as yet unclassified' }
WKPopIntoTemporaryVariable >> writeOn: aWriteStream [ 
	
	"11 is pop into temporary variable, follow with temporary index"
	aWriteStream nextPut: 11.
	aWriteStream nextPut: index
]
