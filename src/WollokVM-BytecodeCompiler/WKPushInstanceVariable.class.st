Class {
	#name : #WKPushInstanceVariable,
	#superclass : #WKBytecode,
	#instVars : [
		'index'
	],
	#category : #'WollokVM-BytecodeCompiler'
}

{ #category : #'as yet unclassified' }
WKPushInstanceVariable >> bytecodeSize [
	
	^ 2
]

{ #category : #accessing }
WKPushInstanceVariable >> index [
	^ index
]

{ #category : #accessing }
WKPushInstanceVariable >> index: anObject [
	index := anObject
]

{ #category : #writing }
WKPushInstanceVariable >> writeOn: aWriteStream [ 
	
	"14 is push instance variable, follow with iv index"
	aWriteStream nextPut: 14.
	aWriteStream nextPut: index
]
