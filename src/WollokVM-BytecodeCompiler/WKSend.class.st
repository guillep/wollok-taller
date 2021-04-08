Class {
	#name : #WKSend,
	#superclass : #WKBytecode,
	#instVars : [
		'selectorIndex',
		'numberOfArguments'
	],
	#category : #'WollokVM-BytecodeCompiler'
}

{ #category : #'instance creation' }
WKSend class >> selectorIndex: anInteger [
	
	^ self new
		selectorIndex: anInteger;
		yourself
]

{ #category : #encoding }
WKSend >> bytecodeSize [
	
	^ 3
]

{ #category : #accessing }
WKSend >> numberOfArguments [
	^ numberOfArguments
]

{ #category : #accessing }
WKSend >> numberOfArguments: anObject [
	numberOfArguments := anObject
]

{ #category : #accessing }
WKSend >> selectorIndex [
	^ selectorIndex
]

{ #category : #accessing }
WKSend >> selectorIndex: anInteger [ 
	selectorIndex := anInteger
]

{ #category : #encoding }
WKSend >> writeOn: aWriteStream [ 
	
	"2 is send, follow with selector and number of arguments"
	aWriteStream nextPut: 2.
	aWriteStream nextPut: selectorIndex.	
	aWriteStream nextPut: numberOfArguments	
]
