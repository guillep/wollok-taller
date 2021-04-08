Class {
	#name : #WKReturnTop,
	#superclass : #WKBytecode,
	#category : #'WollokVM-BytecodeCompiler'
}

{ #category : #encoding }
WKReturnTop >> bytecodeSize [
	
	^ 1
]

{ #category : #encoding }
WKReturnTop >> writeOn: aWriteStream [ 

	"4 is return"
	aWriteStream nextPut: 4.
]
