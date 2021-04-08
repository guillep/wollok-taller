Class {
	#name : #WKInstantiate,
	#superclass : #WKBytecode,
	#instVars : [
		'classNameIndex'
	],
	#category : #'WollokVM-BytecodeCompiler'
}

{ #category : #'as yet unclassified' }
WKInstantiate >> bytecodeSize [
	
	^ 2
]

{ #category : #accessing }
WKInstantiate >> classNameIndex [
	^ classNameIndex
]

{ #category : #accessing }
WKInstantiate >> classNameIndex: anObject [
	classNameIndex := anObject
]

{ #category : #encoding }
WKInstantiate >> writeOn: aWriteStream [ 

	"12 is instantiation, follow with class name index in the literal frame"
	aWriteStream nextPut: 12.
	aWriteStream nextPut: classNameIndex
]
