Class {
	#name : #WKSuperSend,
	#superclass : #WKBytecode,
	#category : #'WollokVM-BytecodeCompiler'
}

{ #category : #'as yet unclassified' }
WKSuperSend >> bytecodeSize [

	^ 1
]

{ #category : #encoding }
WKSuperSend >> writeOn: aWriteStream [ 
	
	aWriteStream nextPut: 16.
]
