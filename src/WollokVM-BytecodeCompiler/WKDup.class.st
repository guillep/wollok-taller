Class {
	#name : #WKDup,
	#superclass : #WKBytecode,
	#category : #'WollokVM-BytecodeCompiler'
}

{ #category : #'as yet unclassified' }
WKDup >> bytecodeSize [
	
	^ 1
]

{ #category : #'as yet unclassified' }
WKDup >> writeOn: aWriteStream [ 
	
	"15 is dup"
	aWriteStream nextPut: 15.
]
