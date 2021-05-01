Class {
	#name : #WollokMLBytecodeInterpreter,
	#superclass : #MLAbstractInterpreter,
	#instVars : [
		'bindings',
		'selectorMappings',
		'program',
		'stack',
		'loader'
	],
	#category : #'WollokVM-BytecodeInterpreter'
}

{ #category : #accessing }
WollokMLBytecodeInterpreter class >> bytecodeMappings [

	^ #(
		(0  0) "unused"
		(1  bytecodePushLiteral)
		(2  bytecodeSend)
		(3  bytecodePop)
		(4  bytecodeReturn)
		(5  0) "unused"
		(6  0) "unused"
		(7  bytecodePushSelf)
		(8  bytecodePushTemporary)
		(9  bytecodeJumpFalse)
		(10 bytecodeJump)
		(11 bytecodePopIntoTemporary)
		(12 bytecodeNew)
		(13 bytecodePopIntoInstanceVariable)
		(14 bytecodePushInstanceVariable)
		(15 bytecodeDup)
		(16 bytecodeSendSuper)
		(17 bytecodeNewList)
		(18 bytecodePushGlobal)
		(19 bytecodeThrow)
	)
]

{ #category : #accessing }
WollokMLBytecodeInterpreter class >> numberOfBytecodes [
	
	^ 20
]

{ #category : #activation }
WollokMLBytecodeInterpreter >> activateMethod: aWKBytecodeMethod [ 
	
	| programCounter |
	aWKBytecodeMethod isNative ifTrue: [ | className |
		className := aWKBytecodeMethod bytecodeClass name.
		^ self executeNativeMethodFrom: className selector: aWKBytecodeMethod selector ].
	
	self push: framePointer.
	self push: programCounter.
	
	self createFrameForMethod: aWKBytecodeMethod.
]

{ #category : #loading }
WollokMLBytecodeInterpreter >> addBindingOfClass: aName fromString: aString [

	^ loader addBindingOfClass: aName fromString: aString
]

{ #category : #'stack-access' }
WollokMLBytecodeInterpreter >> argumentAt: anInteger [ 

	^ stack at: framePointer "Frame points to current frame"
		- 2 "Skip saved frame pointer and saved instruction pointer"
		- (self currentMethod numberOfParameters - anInteger) "Skip other arguments"
		- 1 "Go back by 1 to some interesting value"
]

{ #category : #'stack-access' }
WollokMLBytecodeInterpreter >> argumentAt: anInteger put: aValue [

	^ stack at: framePointer "Frame points to current frame"
		- 2 "Skip saved frame pointer and saved instruction pointer"
		- (self currentMethod numberOfParameters - anInteger) "Skip other arguments"
		- 1 "Go back by 1 to some interesting value"
		 put: aValue
]

{ #category : #bytecode }
WollokMLBytecodeInterpreter >> bytecodeDup [
	
	| value |
	value := self pop.
	self push: value.
	self push: value 
]

{ #category : #bytecode }
WollokMLBytecodeInterpreter >> bytecodeJump [
	
	| offset |
	offset := self fetchNextBytecode.

	programCounter := programCounter + offset - 2
]

{ #category : #bytecode }
WollokMLBytecodeInterpreter >> bytecodeJumpFalse [
	
	| offset boolean |
	boolean := self pop.
	offset := self fetchNextBytecode.

	(self isFalse: boolean) ifTrue: [
		programCounter := programCounter + offset - 2
	]
]

{ #category : #bytecode }
WollokMLBytecodeInterpreter >> bytecodeNew [
	
	| literalIndex className class |
	literalIndex := self fetchNextBytecode.
	className := self literalAt: literalIndex.
	class := memory resolve: (self memory asPharoString: className).
	self push: class instantiate
]

{ #category : #bytecode }
WollokMLBytecodeInterpreter >> bytecodeNewList [

	self push: memory instantiateList
]

{ #category : #bytecode }
WollokMLBytecodeInterpreter >> bytecodePop [
	
	self pop
]

{ #category : #bytecode }
WollokMLBytecodeInterpreter >> bytecodePopIntoInstanceVariable [
	
	| value instanceVariableIndex |
	value := self pop.
	instanceVariableIndex := self fetchNextBytecode.
	memory storeInstanceVariable: instanceVariableIndex ofObject: self receiver withValue: value
]

{ #category : #bytecode }
WollokMLBytecodeInterpreter >> bytecodePopIntoTemporary [
	
	| value temporaryIndex |
	value := self pop.
	temporaryIndex := self fetchNextBytecode.
	value := temporaryIndex <= self currentMethod numberOfParameters
		ifTrue: [ self argumentAt: temporaryIndex put: value ]
		ifFalse: [ self halt: 'ivar?' ]
]

{ #category : #bytecode }
WollokMLBytecodeInterpreter >> bytecodePushGlobal [
	
	| literalIndex globalName |
	literalIndex := self fetchNextBytecode.
	globalName := (memory asPharoString: (self literalAt: literalIndex)) asSymbol.
	
	self push: (bindings at: globalName)
]

{ #category : #bytecode }
WollokMLBytecodeInterpreter >> bytecodePushInstanceVariable [
	
	self push: (memory fetchInstanceVariable: self fetchNextBytecode ofObject: self receiver)
]

{ #category : #bytecode }
WollokMLBytecodeInterpreter >> bytecodePushLiteral [
	
	| literalIndex |
	literalIndex := self fetchNextBytecode.
	self push: (self literalAt: literalIndex)
]

{ #category : #bytecode }
WollokMLBytecodeInterpreter >> bytecodePushSelf [

	self push: self receiver
]

{ #category : #bytecode }
WollokMLBytecodeInterpreter >> bytecodePushTemporary [
	
	| index value |
	index := self fetchNextBytecode.
	value := index <= self currentMethod numberOfParameters
		ifTrue: [ self argumentAt: index ]
		ifFalse: [ self halt ].
	self push: value
]

{ #category : #bytecode }
WollokMLBytecodeInterpreter >> bytecodeReturn [
	
	| returnedValue |
	returnedValue := self pop.
	self popFrame.
	self push: returnedValue.
]

{ #category : #bytecode }
WollokMLBytecodeInterpreter >> bytecodeSend [
	
	| literalIndex selector numberOfArguments receiver method |
	literalIndex := self fetchNextBytecode.
	numberOfArguments := self fetchNextBytecode.
	selector := self literalAt: literalIndex.

	receiver := self stackAt: numberOfArguments + 1.
	method := self lookup: selector withReceiver: receiver.
	self activateMethod: method.
]

{ #category : #bytecode }
WollokMLBytecodeInterpreter >> bytecodeSendSuper [
	
	| literalIndex selector numberOfArguments receiver method |
	selector := self currentMethod selector.

	receiver := self receiver.
	method := self
		lookup: selector
		fromClass: self currentMethod bytecodeClass superclass.
	self activateMethod: method.
]

{ #category : #bytecode }
WollokMLBytecodeInterpreter >> bytecodeThrow [
	
	| exception currentFrame currentIP |
	exception := self stackAt: 0.
	[framePointer = -1 "At end"] whileFalse: [
		(self frame: framePointer ip: programCounter handlesException: exception)
			ifTrue: [ ^ self ].
		self popFrame.		
	].

	"Unhandled exception"
	WollokError new
		wollokException: exception;
		signal
]

{ #category : #accessing }
WollokMLBytecodeInterpreter >> classOf: anObject [
	
	^ memory classOf: anObject
]

{ #category : #compiling }
WollokMLBytecodeInterpreter >> compile: aString [
	
	^ loader basicCompile: (self parse: aString)
]

{ #category : #frames }
WollokMLBytecodeInterpreter >> createFrameForMethod: aWKBytecodeProgram [

	framePointer := stackPointer.
	self push: aWKBytecodeProgram.
	programCounter := 1.
]

{ #category : #accessing }
WollokMLBytecodeInterpreter >> currentMethod [
	
	^ stack at: framePointer
]

{ #category : #interpreting }
WollokMLBytecodeInterpreter >> dispatchBytecode: anInteger [ 
	
	self perform: (dispatchTable at: anInteger)
]

{ #category : #activation }
WollokMLBytecodeInterpreter >> executeNativeMethodFrom: aClassName selector: aSelector [
	
	| nativeName mapping |
	
	"Operators are not valid keyword selectors in Pharo, so map them"
	mapping := selectorMappings
		at: (self memory asPharoString: aSelector)
		ifAbsent: [ self memory asPharoString: aSelector ].
	
	nativeName := ((aClassName copyReplaceAll: '.' with: '_'), '__', mapping) asSymbol.
	^ self perform: nativeName
]

{ #category : #interpreting }
WollokMLBytecodeInterpreter >> fetchNextBytecode [
	
	| bytecode |
	bytecode := self currentMethod bytecode at: programCounter.
	programCounter := programCounter + 1.
	^ bytecode
]

{ #category : #'exception-management' }
WollokMLBytecodeInterpreter >> frame: aFramePointer ip: frameInstructionPointer handlesException: aWollokException [
	
	| method |
	method := self frameMethod: aFramePointer.
	method exceptionHandlers do: [ :e |
		(e includesBytecode: frameInstructionPointer)
			ifTrue: [
				programCounter := e handlerStart.
				^ true ] ].
	^ false
]

{ #category : #frame }
WollokMLBytecodeInterpreter >> frameCallerFP: anInteger [ 
	
	^ stack at: anInteger - 2
]

{ #category : #frames }
WollokMLBytecodeInterpreter >> frameCallerIP: aFramePointer [

	^ stack at: aFramePointer - 1
]

{ #category : #frames }
WollokMLBytecodeInterpreter >> frameMethod: anInteger [ 
	
	^ stack at: anInteger 
]

{ #category : #accessing }
WollokMLBytecodeInterpreter >> framePointer [
	^ framePointer
]

{ #category : #initialization }
WollokMLBytecodeInterpreter >> initialize [

	super initialize.
	loader := WKBytecodeLoader new.
	loader interpreter: self.
	
	stack := WKSingleContiguousStack new.
	stack interpreter: self.
	
	framePointer := stackPointer := 1.
	instructionPointer := 1.
	
	selectorMappings := Dictionary new.
	selectorMappings at: '-' put: 'minus'.
	selectorMappings at: '+' put: 'plus'.
	selectorMappings at: '/' put: 'division'.
	selectorMappings at: '*' put: 'multiplication'.
	selectorMappings at: '%' put: 'modulo'.
	selectorMappings at: '==' put: 'equals'.
	selectorMappings at: '>' put: 'greater'.
	selectorMappings at: '<' put: 'lower'.
	selectorMappings at: '||' put: 'or'.
	selectorMappings at: '&&' put: 'and'.
	selectorMappings at: '===' put: 'identical'
]

{ #category : #'stack-initialization' }
WollokMLBytecodeInterpreter >> initializeBaseFrame [
	
	self push: -1 "sentinel receiver".
	self push: -1 "sentinel framePointer".
	self push: -1 "sentinel programCounter".
	
	self createFrameForMethod: program.
]

{ #category : #simulating }
WollokMLBytecodeInterpreter >> initializeStackAndInterpret [

	<var: #theStackMemory type: #'void *'>
	| stackSize |
	stackSize := 1024 * self memory wordSize.
	stack allocateBytes: stackSize.
	self cCode: [self me: stack ms: 0 et: stackSize].
	stackPointer := stack initialStackAddress + stackSize - self memory wordSize.
	self initializeBaseFrame.
	self interpret
]

{ #category : #instantiation }
WollokMLBytecodeInterpreter >> instantiateClass: aWKBytecodeClass [

	^ objectMemory instantiateClass: aWKBytecodeClass
]

{ #category : #interpreting }
WollokMLBytecodeInterpreter >> interpretLoop [
	
	self interpretUntilReturn: -1 "sentinel frame pointer"
]

{ #category : #interpreting }
WollokMLBytecodeInterpreter >> interpretProgram: bytecodes [

	bytecodes do: [ :e | loader load: e ].
	self initializeStackAndInterpret.
	^ self pop
]

{ #category : #interpreting }
WollokMLBytecodeInterpreter >> interpretUntilReturn: parentFrame [

	[ framePointer > parentFrame ] whileTrue: [ 
		| bytecode |
		bytecode := self fetchNextBytecode.
		self dispatchBytecode: bytecode.
	]
]

{ #category : #accessing }
WollokMLBytecodeInterpreter >> literalAt: anInteger [ 
	
	^ self currentMethod literalAt: anInteger
]

{ #category : #'name-resolution' }
WollokMLBytecodeInterpreter >> load: bytecode [

	| behaviourClass wollokBytecodeClass stream name |
	behaviourClass := bytecode first = 1
		ifTrue: [ WKBytecodeProgram ]
		ifFalse: [ bytecode first = 2
			ifTrue: [ WKBytecodeClass ]
			ifFalse: [ WKBytecodeObject ] ].
	
	"Decode the name first, to be able to register it"
	stream := bytecode readStream.
	stream next: 3 "skip type and number of literals and type of literal".
	name := self basicDecodeStringFrom: stream.
	
	wollokBytecodeClass := behaviourClass new.
	wollokBytecodeClass interpreter: self.
	wollokBytecodeClass name: name.
	
	"Registering before loading to cut potential recursions"
	bindings at: name put: wollokBytecodeClass.
	
	self loadBytecode: bytecode in: wollokBytecodeClass.
	^ wollokBytecodeClass
]

{ #category : #lookup }
WollokMLBytecodeInterpreter >> lookup: aString fromClass: aWollokClass [

	^ aWollokClass lookup: (objectMemory asPharoString: aString) asSymbol
]

{ #category : #lookup }
WollokMLBytecodeInterpreter >> lookup: aString withReceiver: aWollokObject [

	^ (objectMemory classOf: aWollokObject) lookup: (self memory asPharoString: aString) asSymbol
]

{ #category : #accessing }
WollokMLBytecodeInterpreter >> memory [
	^ objectMemory
]

{ #category : #accessing }
WollokMLBytecodeInterpreter >> memory: aMemory [

	objectMemory := aMemory.
	objectMemory interpreter: self.
]

{ #category : #compiling }
WollokMLBytecodeInterpreter >> parse: aString [ 
	
	| anAST |
	anAST := WollokParser parse: aString.
	anAST attributeNamed: #source put: aString.
	^ anAST
]

{ #category : #'stack-access' }
WollokMLBytecodeInterpreter >> pop [
	
	stackPointer := stackPointer - 1.
	^ stack at: stackPointer
	
]

{ #category : #'stack-access' }
WollokMLBytecodeInterpreter >> pop: anInteger [
	"pop a number of elements"
	
	stackPointer := stackPointer - anInteger
]

{ #category : #bytecode }
WollokMLBytecodeInterpreter >> popFrame [
	
	programCounter := self frameCallerIP: framePointer.
	stackPointer := framePointer - 2.
	framePointer := self frameCallerFP: framePointer.
]

{ #category : #accessing }
WollokMLBytecodeInterpreter >> program: aWKBytecodeProgram [ 
	
	program := aWKBytecodeProgram
]

{ #category : #frames }
WollokMLBytecodeInterpreter >> push: aValue [
	"In the StackInterpreter stacks grow down."
	| sp |
	<inline: true>
	<var: #sp type: #'char *'>
	stack longAt: (sp := stackPointer - objectMemory wordSize) put: aValue.
	stackPointer := sp
]

{ #category : #accessing }
WollokMLBytecodeInterpreter >> receiver [
	
	^ stack at: framePointer "Frame points to current frame"
		- 2 "Skip saved frame pointer and saved instruction pointer"
		- self currentMethod numberOfParameters "Skip parameters"
		- 1 "Go back by 1 to get the receiver"
]

{ #category : #globals }
WollokMLBytecodeInterpreter >> registerGlobal: aWollokVMObject atName: aString [ 
	
	bindings at: aString asSymbol put: aWollokVMObject
]

{ #category : #'name-resolution' }
WollokMLBytecodeInterpreter >> resolve: aString [
	
	^ loader loadName: aString.
]

{ #category : #'stack-access' }
WollokMLBytecodeInterpreter >> stackAt: anInteger [ 
	
	^ stack at: stackPointer - anInteger
]

{ #category : #accessing }
WollokMLBytecodeInterpreter >> wollokClassName: anInteger [ 
	
	^ objectMemory wollokClassName: anInteger
]

{ #category : #'native methods' }
WollokMLBytecodeInterpreter >> wollok_lang_Boolean__and [
	
	| boolean1 boolean2 |
	boolean1 := self pop.
	boolean2 := self pop.
	self push: (self asWollokBoolean: ((self asPharoBoolean: boolean1) & (self asPharoBoolean: boolean2)))
]

{ #category : #'native methods' }
WollokMLBytecodeInterpreter >> wollok_lang_Boolean__equals [
	
	self push: (objectMemory asWollokBoolean: self pop == self pop)
]

{ #category : #'native methods' }
WollokMLBytecodeInterpreter >> wollok_lang_Boolean__or [
	
	| boolean1 boolean2 |
	boolean1 := self pop.
	boolean2 := self pop.
	self push: (self asWollokBoolean: ((self asPharoBoolean: boolean1) | (self asPharoBoolean: boolean2)))
]

{ #category : #'native methods' }
WollokMLBytecodeInterpreter >> wollok_lang_List__add [
	
	| added receiver |
	added := self pop.
	receiver := self pop.
	
	receiver literalValue add: added.
	self push: added
]

{ #category : #'native methods' }
WollokMLBytecodeInterpreter >> wollok_lang_List__contains [
	
	| tested list |
	tested := self pop.
	list := self pop.
	
	self push: (self asWollokBoolean: (list literalValue includes: tested))
]

{ #category : #'native methods' }
WollokMLBytecodeInterpreter >> wollok_lang_List__size [
	
	| list |
	list := self pop.
	self push: (objectMemory asWollokNumber: list literalValue size)
]

{ #category : #'native methods' }
WollokMLBytecodeInterpreter >> wollok_lang_Number__division [

	| number1 number2 |
	number2 := self pop.
	number1 := self pop.
	self push: (objectMemory asWollokNumber: ((objectMemory asPharoNumber: number1) / (objectMemory asPharoNumber: number2)))
]

{ #category : #'native methods' }
WollokMLBytecodeInterpreter >> wollok_lang_Number__greater [

	| number1 number2 |
	number2 := self pop.
	number1 := self pop.
	self push: (objectMemory asWollokBoolean: ((objectMemory asPharoNumber: number1) > (objectMemory asPharoNumber: number2)))
]

{ #category : #'native methods' }
WollokMLBytecodeInterpreter >> wollok_lang_Number__identical [
	
	| number1 number2 |
	number1 := self pop.
	number2 := self pop.
	self push: (objectMemory asWollokBoolean: ((objectMemory asPharoNumber: number1) = (objectMemory asPharoNumber: number2)))
]

{ #category : #'native methods' }
WollokMLBytecodeInterpreter >> wollok_lang_Number__invert [

	| number1 |
	number1 := self pop.
	self push: (objectMemory asWollokNumber: (objectMemory asPharoNumber: number1) negated)
]

{ #category : #'native methods' }
WollokMLBytecodeInterpreter >> wollok_lang_Number__lower [

	| number1 number2 |
	number2 := self pop.
	number1 := self pop.
	self push: (objectMemory asWollokBoolean: ((objectMemory asPharoNumber: number1) < (objectMemory asPharoNumber: number2)))
]

{ #category : #'native methods' }
WollokMLBytecodeInterpreter >> wollok_lang_Number__minus [

	| number1 number2 |
	number2 := self pop.
	number1 := self pop.

	self push: (objectMemory asWollokNumber: ((objectMemory asPharoNumber: number1) - (objectMemory asPharoNumber: number2)))
]

{ #category : #'native methods' }
WollokMLBytecodeInterpreter >> wollok_lang_Number__modulo [
	
	| number2 number1 |
	number2 := objectMemory asPharoNumber: self pop.
	number1 := objectMemory asPharoNumber: self pop.
	
	self push: (objectMemory asWollokNumber: number1 \\ number2)
]

{ #category : #'native methods' }
WollokMLBytecodeInterpreter >> wollok_lang_Number__multiplication [

	| number1 number2 |
	number2 := self pop.
	number1 := self pop.
	self push: (objectMemory asWollokNumber: ((objectMemory asPharoNumber: number1) * (objectMemory asPharoNumber: number2)))
]

{ #category : #'native methods' }
WollokMLBytecodeInterpreter >> wollok_lang_Number__plus [

	| number1 number2 |
	number2 := self pop.
	number1 := self pop.
	self push: (objectMemory asWollokNumber: ((objectMemory asPharoNumber: number1) + (objectMemory asPharoNumber: number2)))
]

{ #category : #'native methods' }
WollokMLBytecodeInterpreter >> wollok_lang_Number__truncate [

	| truncation number truncatedNumber |
	truncation := objectMemory asPharoNumber: self pop.
	number := objectMemory asPharoNumber: self pop.

	truncatedNumber := number truncateTo: 1 / (10 raisedTo: truncation) asScaledDecimal.
	self push: (objectMemory asWollokNumber: truncatedNumber)
]

{ #category : #'native methods' }
WollokMLBytecodeInterpreter >> wollok_lang_Object__identity [
	
	| receiver |
	receiver := self pop.
	self push: (objectMemory identityOf: receiver)
]

{ #category : #'native methods' }
WollokMLBytecodeInterpreter >> wollok_lang_String__concat [
	
	| receiver argument |
	argument := self pop.
	receiver := self pop.
	self push: (objectMemory asWollokString: (self memory asPharoString: receiver), (self memory asPharoString: argument))
]

{ #category : #'native methods' }
WollokMLBytecodeInterpreter >> wollok_lang_String__toString [
	
	"Do nothing, this would just pop the receiver and push it back..."
]
