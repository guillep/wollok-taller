Class {
	#name : #WKBytecodeProgram,
	#superclass : #Object,
	#instVars : [
		'literals',
		'bytecode'
	],
	#category : #'WollokVM-BytecodeInterpreter'
}

{ #category : #accessing }
WKBytecodeProgram >> bytecode [
	^ bytecode
]

{ #category : #accessing }
WKBytecodeProgram >> bytecode: anObject [
	bytecode := anObject
]

{ #category : #decoding }
WKBytecodeProgram >> decodeFrom: aReadStream [ 

	self bytecode: aReadStream upToEnd
]

{ #category : #loading }
WKBytecodeProgram >> finishLoadingIn: aWollokBytecodeInterpreter [ 
	
	"Nothing"
]

{ #category : #accessing }
WKBytecodeProgram >> literalAt: anInteger [

	^ literals at: anInteger
]

{ #category : #accessing }
WKBytecodeProgram >> literals [
	^ literals
]

{ #category : #accessing }
WKBytecodeProgram >> literals: anObject [
	literals := anObject
]

{ #category : #accessing }
WKBytecodeProgram >> numberOfParameters [
	
	^ 0
]
