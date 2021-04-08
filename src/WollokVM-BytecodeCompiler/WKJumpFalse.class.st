Class {
	#name : #WKJumpFalse,
	#superclass : #WKJump,
	#category : #'WollokVM-BytecodeCompiler'
}

{ #category : #encoding }
WKJumpFalse >> writeOn: aWriteStream [ 

	"9 is jumpFalse, follow with offset"
	aWriteStream nextPut: 9.
	aWriteStream nextPut: self offset
]
