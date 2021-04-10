Class {
	#name : #WKBytecodeProgram,
	#superclass : #Object,
	#instVars : [
		'literals',
		'bytecode',
		'name'
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
	
	aWollokBytecodeInterpreter program: self
]

{ #category : #accessing }
WKBytecodeProgram >> interpreter: aWollokBytecodeInterpreter [ 

	| interpreter |
	interpreter := aWollokBytecodeInterpreter
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
WKBytecodeProgram >> name: aString [
	
	name := aString
]

{ #category : #accessing }
WKBytecodeProgram >> numberOfParameters [
	
	^ 0
]
