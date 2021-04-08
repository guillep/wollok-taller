Class {
	#name : #WKPop,
	#superclass : #WKBytecode,
	#category : #'WollokVM-BytecodeCompiler'
}

{ #category : #'as yet unclassified' }
WKPop >> bytecodeSize [
	
	^ 1
]

{ #category : #'as yet unclassified' }
WKPop >> writeOn: aWriteStream [ 
	
	"3 is pop"
	aWriteStream nextPut: 3.
]
