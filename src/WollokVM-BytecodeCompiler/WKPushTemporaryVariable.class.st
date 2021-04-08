Class {
	#name : #WKPushTemporaryVariable,
	#superclass : #WKBytecode,
	#instVars : [
		'index'
	],
	#category : #'WollokVM-BytecodeCompiler'
}

{ #category : #'instance creation' }
WKPushTemporaryVariable class >> literal: anInteger [ 
	
	^ self new
		literal: anInteger;
		yourself
]

{ #category : #'as yet unclassified' }
WKPushTemporaryVariable >> bytecodeSize [
	
	^ 2
]

{ #category : #accessing }
WKPushTemporaryVariable >> index [
	^ index
]

{ #category : #accessing }
WKPushTemporaryVariable >> index: anObject [
	index := anObject
]

{ #category : #encoding }
WKPushTemporaryVariable >> writeOn: aWriteStream [ 
	
	"8 is push temporary variable, follow with temporary index"
	aWriteStream nextPut: 8.
	aWriteStream nextPut: index
]
