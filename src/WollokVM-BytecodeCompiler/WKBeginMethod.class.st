Class {
	#name : #WKBeginMethod,
	#superclass : #WKBytecode,
	#instVars : [
		'nameIndex',
		'native',
		'numberOfParameters'
	],
	#category : #'WollokVM-BytecodeCompiler'
}

{ #category : #'as yet unclassified' }
WKBeginMethod >> bytecodeSize [
	
	^ 4
]

{ #category : #accessing }
WKBeginMethod >> nameIndex [
	^ nameIndex
]

{ #category : #accessing }
WKBeginMethod >> nameIndex: anInteger [ 
	nameIndex := anInteger
]

{ #category : #accessing }
WKBeginMethod >> native [
	^ native
]

{ #category : #accessing }
WKBeginMethod >> native: isNative [
	
	native := isNative
]

{ #category : #accessing }
WKBeginMethod >> numberOfParameters [
	^ numberOfParameters
]

{ #category : #accessing }
WKBeginMethod >> numberOfParameters: anObject [
	numberOfParameters := anObject
]

{ #category : #encoding }
WKBeginMethod >> writeOn: aWriteStream [ 
	
	"Encode Start of method, followed by selector index, followed by isNative flag"
	aWriteStream nextPut: 5.
	aWriteStream nextPut: nameIndex.
	aWriteStream nextPut: native asBit.
	aWriteStream nextPut: numberOfParameters.
]
