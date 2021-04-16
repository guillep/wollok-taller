Class {
	#name : #WKBytecodeBuilder,
	#superclass : #Object,
	#instVars : [
		'bytecode',
		'literals',
		'instructions',
		'type'
	],
	#category : #'WollokVM-BytecodeCompiler'
}

{ #category : #literals }
WKBytecodeBuilder >> addLiteral: anObject [
	
	"Records a literal and returns its index in the literal frame.
	Do not add repeated literals"
	
	"literals is a 1-indexed ordered collection"
	(literals includes: anObject)
		ifFalse: [ literals add: anObject ].
	^ literals indexOf: anObject
]

{ #category : #instructions }
WKBytecodeBuilder >> beginMethod: aString native: isNative numberOfParameters: numberOfParameters [

	| literalIndex |
	literalIndex := self addLiteral: aString.
	instructions add: (WKBeginMethod new
		nameIndex: literalIndex;
		native: isNative;
		numberOfParameters: numberOfParameters;
		yourself)
]

{ #category : #building }
WKBytecodeBuilder >> bytecode [

	"Bytecode format:
	
	Type (1=program, 2=module, 3=object)
	# of Literals, variable sized literals, encoding each its size
	Literal1
	...
	LiteralN
	Bytecode1
	...
	BytecodeN
	
	Supports max 256 literals per file :)
	"

	| header bytecodeStart |
	header := ByteArray streamContents: [ :stream |
		stream nextPut: type.
		stream nextPut: literals size.
		literals do: [ :e | self encodeLiteral: e inStream: stream ].
	].

	bytecodeStart := header size.
	instructions do: [ :e | 
		e position: bytecodeStart.
		bytecodeStart := bytecodeStart + e bytecodeSize ].
	
	bytecode := ByteArray streamContents: [ :stream |
		instructions do: [ :e | e writeOn: stream ].
	].

	^ header , bytecode
]

{ #category : #instructions }
WKBytecodeBuilder >> dup [
	
	instructions add: WKDup new
]

{ #category : #encoding }
WKBytecodeBuilder >> encodeBoolean: aBoolean inStream: aWriteStream [ 
	
	"Type: 1.
	Booleans take 1 byte, 1 is true, 0 is false"
	
	aWriteStream nextPut: 1.
	aWriteStream nextPut: aBoolean asBit.
]

{ #category : #encoding }
WKBytecodeBuilder >> encodeLiteral: anObject inStream: aWriteStream [ 
	
	"Each literal is encoded as follows:
	1 byte type identifier (e.g., boolean, number, ...)
	The literal itself (could encode its size)"
	
	(#(true false) includes: anObject)
		ifTrue: [ ^ self encodeBoolean: anObject inStream: aWriteStream ].
	anObject isString
		ifTrue: [ ^ self encodeString: anObject inStream: aWriteStream ].
	anObject isNumber
		ifTrue: [ ^ self encodeNumber: anObject inStream: aWriteStream ].
	anObject isNil
		ifTrue: [ ^ self encodeNilInStream: aWriteStream ].
	self notYetImplemented
]

{ #category : #encoding }
WKBytecodeBuilder >> encodeNilInStream: aWriteStream [ 

	"Type: 4.
	nil takes no extra place"
	
	aWriteStream nextPut: 4
]

{ #category : #encoding }
WKBytecodeBuilder >> encodeNumber: anInteger inStream: aWriteStream [ 
	
	"Type: 3.
	Integers are stored as scaled decimals.
	8 bytes for numerator.
	8 bytes for denominator.
	1 byte for scale"

	| decimal |
	decimal := anInteger asScaledDecimal.
	aWriteStream nextPut: 3.
	aWriteStream nextPutAll: (decimal numerator asByteArrayOfSize: 8).
	aWriteStream nextPutAll: (decimal denominator asByteArrayOfSize: 8).
	aWriteStream nextPut: decimal scale.
]

{ #category : #encoding }
WKBytecodeBuilder >> encodeString: aString inStream: aWriteStream [ 
	
	"Type: 2.
	Strings are utf-8 encoded.
	We set first their size, then their contents."

	| utf8encoded |
	utf8encoded := aString utf8Encoded.
	aWriteStream nextPut: 2.
	aWriteStream nextPut: utf8encoded size.
	aWriteStream nextPutAll: utf8encoded
]

{ #category : #instructions }
WKBytecodeBuilder >> endMethod [
	
	instructions add: WKEndMethod new
]

{ #category : #building }
WKBytecodeBuilder >> forClass [

	"Check I have not been called"
	self assert: type isNil.
	
	"We are building a module (and not a program or a test)"
	type := 2.
]

{ #category : #building }
WKBytecodeBuilder >> forObject [

	"Check I have not been called"
	self assert: type isNil.
	
	"We are building an object (and not a program or class)"
	type := 3
]

{ #category : #building }
WKBytecodeBuilder >> forProgram [

	"Check I have not been called"
	self assert: type isNil.
	
	"We are building a program (and not a class or a test)"
	type := 1.
]

{ #category : #literals }
WKBytecodeBuilder >> initialize [
	super initialize.
	literals := OrderedCollection new.
	instructions := OrderedCollection new.
]

{ #category : #instructions }
WKBytecodeBuilder >> instantiate: aName [
	
	| literalIndex |
	literalIndex := self addLiteral: aName.
	^ instructions add: (WKInstantiate new
		classNameIndex: literalIndex;
		yourself)
]

{ #category : #instructions }
WKBytecodeBuilder >> instantiateList [
	
	instructions add: WKInstantiateList new
]

{ #category : #'instructions-control flow' }
WKBytecodeBuilder >> jump: jumpTarget [
	
	^ instructions add: (WKJump new
		jumpTarget: jumpTarget;
		yourself)
]

{ #category : #'instructions-control flow' }
WKBytecodeBuilder >> jumpFalse: target [
	
	^ instructions add: (WKJumpFalse new
		jumpTarget: target;
		yourself)
]

{ #category : #visiting }
WKBytecodeBuilder >> label [
	
	^ instructions add: WKLabel new
]

{ #category : #instructions }
WKBytecodeBuilder >> pop [
	
	instructions add: WKPop new
]

{ #category : #instructions }
WKBytecodeBuilder >> popIntoInstanceVariable: anInteger [ 

	instructions add: (WKPopIntoInstanceVariable new index: anInteger; yourself)
]

{ #category : #instructions }
WKBytecodeBuilder >> popIntoTemporaryVariable: anInteger [ 
	
	instructions add: (WKPopIntoTemporaryVariable new index: anInteger; yourself)
]

{ #category : #instructions }
WKBytecodeBuilder >> pushGlobalNamed: aString [ 
	
	| literalIndex |
	literalIndex := self addLiteral: aString.
	instructions add: (WKPushGlobalVariable new
		index: literalIndex;
		yourself)
]

{ #category : #instructions }
WKBytecodeBuilder >> pushInstanceVariable: anInteger [ 

	instructions add: (WKPushInstanceVariable new index: anInteger; yourself)
]

{ #category : #instructions }
WKBytecodeBuilder >> pushLiteral: aLiteral [
	
	| literalIndex |
	literalIndex := self addLiteral: aLiteral.
	self pushLiteralIndex: literalIndex
]

{ #category : #instructions }
WKBytecodeBuilder >> pushLiteralIndex: anInteger [ 
	
	"Add an instruction encoding the push of a literal"
	instructions add: (WKPushLiteral literal: anInteger)
]

{ #category : #visiting }
WKBytecodeBuilder >> pushSelf [
	
	instructions add: WKPushSelf new
]

{ #category : #instructions }
WKBytecodeBuilder >> pushTemporaryVariable: anInteger [ 
	
	instructions add: (WKPushTemporaryVariable new index: anInteger; yourself)
]

{ #category : #instructions }
WKBytecodeBuilder >> returnTop [
	
	instructions add: WKReturnTop new
]

{ #category : #instructions }
WKBytecodeBuilder >> send: aString numberOfArguments: numberOfArguments [
	
	| index |
	index := self addLiteral: aString.
	instructions add: (WKSend new
		selectorIndex: index;
		numberOfArguments: numberOfArguments;
		yourself)
]

{ #category : #instructions }
WKBytecodeBuilder >> superSend [

	instructions add: WKSuperSend new
]

{ #category : #instructions }
WKBytecodeBuilder >> throw [
	
	instructions add: WKThrow new.
]
