Class {
	#name : #WKGlobalVariable,
	#superclass : #WKBytecode,
	#instVars : [
		'index'
	],
	#category : #'WollokVM-BytecodeCompiler'
}

{ #category : #'instance creation' }
WKGlobalVariable class >> literal: anInteger [ 
	
	^ self new
		literal: anInteger;
		yourself
]

{ #category : #'as yet unclassified' }
WKGlobalVariable >> bytecodeSize [
	
	^ 2
]

{ #category : #accessing }
WKGlobalVariable >> index [
	^ index
]

{ #category : #accessing }
WKGlobalVariable >> index: anObject [
	index := anObject
]

{ #category : #encoding }
WKGlobalVariable >> writeOn: aWriteStream [ 
	
	"8 is push temporary variable, follow with temporary index"
	aWriteStream nextPut: 8.
	aWriteStream nextPut: index
]
