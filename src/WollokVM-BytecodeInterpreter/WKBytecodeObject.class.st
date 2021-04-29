Class {
	#name : #WKBytecodeObject,
	#superclass : #WKBytecodeClass,
	#category : #'WollokVM-BytecodeInterpreter'
}

{ #category : #loading }
WKBytecodeObject >> decodeFrom: aReadStream [ 
	
	"Read Methods"
	numberOfSlots := aReadStream next.
]

{ #category : #loading }
WKBytecodeObject >> finishLoadingIn: aWollokBytecodeInterpreter [ 

	| framePointerBefore m instance |
	super finishLoadingIn: aWollokBytecodeInterpreter.
	interpreter memory registerClass: self.
	instance := self instantiate.
	interpreter registerGlobal: instance atName: self name.
	
	framePointerBefore := interpreter framePointer.

	interpreter push: instance.
	m := self lookup: '____init'.
	interpreter activateMethod: m.
	interpreter interpretUntilReturn: framePointerBefore.

	interpreter push: instance.
	m := self lookup: 'initialize'.
	interpreter activateMethod: m.
	interpreter interpretUntilReturn: framePointerBefore.
]
