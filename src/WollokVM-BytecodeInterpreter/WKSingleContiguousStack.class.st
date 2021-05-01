Class {
	#name : #WKSingleContiguousStack,
	#superclass : #VMClass,
	#instVars : [
		'interpreter',
		'stackMemory'
	],
	#category : #'WollokVM-BytecodeInterpreter'
}

{ #category : #allocation }
WKSingleContiguousStack >> allocateBytes: stackSize [
	
	stackMemory := self alloca: stackSize
]

{ #category : #accessing }
WKSingleContiguousStack >> initialStackAddress [
	
	^ stackMemory
]

{ #category : #accessing }
WKSingleContiguousStack >> interpreter: aWollokMLBytecodeInterpreter [ 
	interpreter := aWollokMLBytecodeInterpreter
]

{ #category : #'memory-access' }
WKSingleContiguousStack >> longAt: byteAddress put: aValue [ 
	
	^ self objectMemory longAt: byteAddress put: aValue
]
