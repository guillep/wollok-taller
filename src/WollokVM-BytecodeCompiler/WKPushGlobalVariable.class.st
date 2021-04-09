Class {
	#name : #WKPushGlobalVariable,
	#superclass : #WKBytecode,
	#instVars : [
		'index'
	],
	#category : #'WollokVM-BytecodeCompiler'
}

{ #category : #'instance creation' }
WKPushGlobalVariable class >> literal: anInteger [ 
	
	^ self new
		literal: anInteger;
		yourself
]

{ #category : #'as yet unclassified' }
WKPushGlobalVariable >> bytecodeSize [
	
	^ 2
]

{ #category : #accessing }
WKPushGlobalVariable >> index [
	^ index
]

{ #category : #accessing }
WKPushGlobalVariable >> index: anObject [
	index := anObject
]

{ #category : #encoding }
WKPushGlobalVariable >> writeOn: aWriteStream [ 
	
	"18 is push global variable, follow with index of literal with global name"
	aWriteStream nextPut: 18.
	aWriteStream nextPut: index
]
