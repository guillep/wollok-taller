Class {
	#name : #WKPushLiteral,
	#superclass : #WKBytecode,
	#instVars : [
		'literal'
	],
	#category : #'WollokVM-BytecodeCompiler'
}

{ #category : #'instance creation' }
WKPushLiteral class >> literal: anInteger [ 
	
	^ self new
		literal: anInteger;
		yourself
]

{ #category : #encoding }
WKPushLiteral >> bytecodeSize [
	
	^ 2
]

{ #category : #accessing }
WKPushLiteral >> literal [
	^ literal
]

{ #category : #accessing }
WKPushLiteral >> literal: anObject [
	literal := anObject
]

{ #category : #encoding }
WKPushLiteral >> writeOn: aWriteStream [ 
	
	"1 is push literal, follow with argument"
	aWriteStream nextPut: 1.
	aWriteStream nextPut: literal.	
]
