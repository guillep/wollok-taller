Class {
	#name : #WKThrow,
	#superclass : #WKBytecode,
	#category : #'WollokVM-BytecodeCompiler'
}

{ #category : #'as yet unclassified' }
WKThrow >> bytecodeSize [
	
	^ 1
]

{ #category : #encoding }
WKThrow >> writeOn: aWriteStream [ 
	
	aWriteStream nextPut: 19
]
