Class {
	#name : #WKJump,
	#superclass : #WKBytecode,
	#instVars : [
		'jumpTarget'
	],
	#category : #'WollokVM-BytecodeCompiler'
}

{ #category : #'as yet unclassified' }
WKJump >> bytecodeSize [
	
	^ 2
]

{ #category : #accessing }
WKJump >> jumpTarget: anInstruction [ 
	jumpTarget := anInstruction
]

{ #category : #'as yet unclassified' }
WKJump >> offset [
	
	^ jumpTarget position - position
]

{ #category : #encoding }
WKJump >> writeOn: aWriteStream [ 

	"10 is unconditional jump, follow with offset"
	aWriteStream nextPut: 10.
	aWriteStream nextPut: self offset
]
