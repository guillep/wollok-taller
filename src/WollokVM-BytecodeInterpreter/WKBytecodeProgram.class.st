Class {
	#name : #WKBytecodeProgram,
	#superclass : #WKBytecodeElement,
	#instVars : [
		'name',
		'method'
	],
	#category : #'WollokVM-BytecodeInterpreter'
}

{ #category : #accessing }
WKBytecodeProgram >> bytecode [
	^ method bytecode
]

{ #category : #decoding }
WKBytecodeProgram >> decodeFrom: aReadStream [ 

	method := self decodeMethodFrom: aReadStream
]

{ #category : #accessing }
WKBytecodeProgram >> exceptionHandlers [
	
	^ method exceptionHandlers
]

{ #category : #loading }
WKBytecodeProgram >> finishLoadingIn: aWollokBytecodeInterpreter [ 
	
	aWollokBytecodeInterpreter program: self
]

{ #category : #accessing }
WKBytecodeProgram >> interpreter: aWollokBytecodeInterpreter [ 
]

{ #category : #accessing }
WKBytecodeProgram >> name: aString [
	
	name := aString
]

{ #category : #accessing }
WKBytecodeProgram >> numberOfParameters [
	
	^ 0
]
