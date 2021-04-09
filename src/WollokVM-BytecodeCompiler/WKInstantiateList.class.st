Class {
	#name : #WKInstantiateList,
	#superclass : #WKBytecode,
	#category : #'WollokVM-BytecodeCompiler'
}

{ #category : #'as yet unclassified' }
WKInstantiateList >> bytecodeSize [

	^ 1
]

{ #category : #encoding }
WKInstantiateList >> writeOn: aWriteStream [ 
	
	aWriteStream nextPut: 17
]
