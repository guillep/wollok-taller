Class {
	#name : #WKPushSelf,
	#superclass : #WKBytecode,
	#category : #'WollokVM-BytecodeCompiler'
}

{ #category : #'as yet unclassified' }
WKPushSelf >> bytecodeSize [
	
	^ 1
]

{ #category : #encoding }
WKPushSelf >> writeOn: aWriteStream [ 

	aWriteStream nextPut: 7
]
