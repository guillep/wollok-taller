Class {
	#name : #WKEndMethod,
	#superclass : #WKBytecode,
	#category : #'WollokVM-BytecodeCompiler'
}

{ #category : #encoding }
WKEndMethod >> bytecodeSize [
	
	^ 1
]

{ #category : #encoding }
WKEndMethod >> writeOn: aWriteStream [ 

	"Encode End of method"
	aWriteStream nextPut: 255
]
