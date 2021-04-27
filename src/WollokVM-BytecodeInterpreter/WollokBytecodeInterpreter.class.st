Class {
	#name : #WollokBytecodeInterpreter,
	#superclass : #WKAbstractInterpreter,
	#instVars : [
		'bindings',
		'stack',
		'stackPointer',
		'programCounter',
		'framePointer',
		'dispatchTable',
		'selectorMappings',
		'program',
		'asts'
	],
	#category : #'WollokVM-BytecodeInterpreter'
}

{ #category : #activation }
WollokBytecodeInterpreter >> activateMethod: aWKBytecodeMethod [ 
	
	aWKBytecodeMethod isNative ifTrue: [ | className |
		className := bindings keyAtValue: aWKBytecodeMethod bytecodeClass.
		^ self executeNativeMethodFrom: className selector: aWKBytecodeMethod selector ].
	
	self push: framePointer.
	self push: programCounter.
	
	self createFrameForMethod: aWKBytecodeMethod.
]

{ #category : #loading }
WollokBytecodeInterpreter >> addBindingOfClass: aName fromString: aString [

	| anAST astclass |
	anAST := WollokParser parse: aString.
	anAST attributeNamed: #source put: aString.
	asts at: aName put: anAST children first.

	astclass := WollokASTVMClass new
		name: aName;
		ast: anAST;
		yourself.
	
	^ self compileAndInstall: astclass
]

{ #category : #'stack-management' }
WollokBytecodeInterpreter >> argumentAt: anInteger [ 

	^ stack at: framePointer "Frame points to current frame"
		- 2 "Skip saved frame pointer and saved instruction pointer"
		- (self currentMethod numberOfParameters - anInteger) "Skip other arguments"
		- 1 "Go back by 1 to some interesting value"
]

{ #category : #'stack-management' }
WollokBytecodeInterpreter >> argumentAt: anInteger put: aValue [

	^ stack at: framePointer "Frame points to current frame"
		- 2 "Skip saved frame pointer and saved instruction pointer"
		- (self currentMethod numberOfParameters - anInteger) "Skip other arguments"
		- 1 "Go back by 1 to some interesting value"
		 put: aValue
]

{ #category : #compiling }
WollokBytecodeInterpreter >> basicCompile: anAST [
	
	^ WollokBytecodeCompiler new
		loader: WollokReducedLoader new;
		asts: asts;
		compile: anAST;
		results
]

{ #category : #'literal-decoding' }
WollokBytecodeInterpreter >> basicDecodeStringFrom: aReadStream [ 
	
	| stringSize |
	stringSize := aReadStream next.
	^ (aReadStream next: stringSize) utf8Decoded
]

{ #category : #bytecode }
WollokBytecodeInterpreter >> bytecodeDup [
	
	| value |
	value := self pop.
	self push: value.
	self push: value 
]

{ #category : #bytecode }
WollokBytecodeInterpreter >> bytecodeJump [
	
	| offset |
	offset := self fetchNextBytecode.

	programCounter := programCounter + offset - 2
]

{ #category : #bytecode }
WollokBytecodeInterpreter >> bytecodeJumpFalse [
	
	| offset boolean |
	boolean := self pop.
	offset := self fetchNextBytecode.

	(self isFalse: boolean) ifTrue: [
		programCounter := programCounter + offset - 2
	]
]

{ #category : #bytecode }
WollokBytecodeInterpreter >> bytecodeNew [
	
	| literalIndex className class |
	literalIndex := self fetchNextBytecode.
	className := self literalAt: literalIndex.
	class := memory resolve: (self memory asPharoString: className).
	self push: class instantiate
]

{ #category : #bytecode }
WollokBytecodeInterpreter >> bytecodeNewList [

	self push: memory instantiateList
]

{ #category : #bytecode }
WollokBytecodeInterpreter >> bytecodePop [
	
	self pop
]

{ #category : #bytecode }
WollokBytecodeInterpreter >> bytecodePopIntoInstanceVariable [
	
	| value instanceVariableIndex |
	value := self pop.
	instanceVariableIndex := self fetchNextBytecode.
	memory storeInstanceVariable: instanceVariableIndex ofObject: self receiver withValue: value
]

{ #category : #bytecode }
WollokBytecodeInterpreter >> bytecodePopIntoTemporary [
	
	| value temporaryIndex |
	value := self pop.
	temporaryIndex := self fetchNextBytecode.
	value := temporaryIndex <= self currentMethod numberOfParameters
		ifTrue: [ self argumentAt: temporaryIndex put: value ]
		ifFalse: [ self halt: 'ivar?' ]
]

{ #category : #bytecode }
WollokBytecodeInterpreter >> bytecodePushGlobal [
	
	| literalIndex globalName |
	literalIndex := self fetchNextBytecode.
	globalName := (self literalAt: literalIndex) literalValue asSymbol.
	
	self push: (bindings at: globalName)
]

{ #category : #bytecode }
WollokBytecodeInterpreter >> bytecodePushInstanceVariable [
	
	self push: (memory fetchInstanceVariable: self fetchNextBytecode ofObject: self receiver)
]

{ #category : #bytecode }
WollokBytecodeInterpreter >> bytecodePushLiteral [
	
	| literalIndex |
	literalIndex := self fetchNextBytecode.
	self push: (self literalAt: literalIndex)
]

{ #category : #bytecode }
WollokBytecodeInterpreter >> bytecodePushSelf [

	self push: self receiver
]

{ #category : #bytecode }
WollokBytecodeInterpreter >> bytecodePushTemporary [
	
	| index value |
	index := self fetchNextBytecode.
	value := index <= self currentMethod numberOfParameters
		ifTrue: [ self argumentAt: index ]
		ifFalse: [ self halt ].
	self push: value
]

{ #category : #bytecode }
WollokBytecodeInterpreter >> bytecodeReturn [
	
	| returnedValue |
	returnedValue := self pop.
	self popFrame.
	self push: returnedValue.
]

{ #category : #bytecode }
WollokBytecodeInterpreter >> bytecodeSend [
	
	| literalIndex selector numberOfArguments receiver method |
	literalIndex := self fetchNextBytecode.
	numberOfArguments := self fetchNextBytecode.
	selector := self literalAt: literalIndex.

	receiver := self stackAt: numberOfArguments + 1.
	method := self lookup: selector withReceiver: receiver.
	self activateMethod: method.
]

{ #category : #bytecode }
WollokBytecodeInterpreter >> bytecodeSendSuper [
	
	| literalIndex selector numberOfArguments receiver method |
	selector := self currentMethod selector.

	receiver := self receiver.
	method := self
		lookup: selector
		fromClass: self currentMethod bytecodeClass superclass.
	self activateMethod: method.
]

{ #category : #bytecode }
WollokBytecodeInterpreter >> bytecodeThrow [
	
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
WollokBytecodeInterpreter >> classOf: anObject [
	
	^ memory classOf: anObject
]

{ #category : #compiling }
WollokBytecodeInterpreter >> compile: aString [
	
	^ self basicCompile: (self parse: aString)
]

{ #category : #'name-resolution' }
WollokBytecodeInterpreter >> compileAndInstall: astclass [

	| results |
	results := self basicCompile: astclass ast.
	results do: [ :e | self load: e ].
	^ bindings at: astclass name
]

{ #category : #frames }
WollokBytecodeInterpreter >> createFrameForMethod: aWKBytecodeProgram [

	framePointer := stackPointer.
	self push: aWKBytecodeProgram.
	programCounter := 1.
]

{ #category : #accessing }
WollokBytecodeInterpreter >> currentMethod [
	
	^ stack at: framePointer
]

{ #category : #'literal-decoding' }
WollokBytecodeInterpreter >> decodeBooleanFrom: aReadStream [
	
	^ (aReadStream next = 1)
		ifTrue: [ memory trueObject ]
		ifFalse: [ memory falseObject ]
]

{ #category : #'literal-decoding' }
WollokBytecodeInterpreter >> decodeLiteralFrom: aReadStream [ 
	
	| literalKind |
	literalKind := aReadStream next.
	literalKind = 1 "boolean"
		ifTrue: [ ^ self decodeBooleanFrom: aReadStream ].
	literalKind = 2 "string"
		ifTrue: [ ^ self decodeStringFrom: aReadStream ].
	literalKind = 3 "number"
		ifTrue: [ ^ self decodeNumberFrom: aReadStream ].
	literalKind = 4 "nil"
		ifTrue: [ ^ self decodeNilFrom: aReadStream ].
	self notYetImplemented
]

{ #category : #'literal-decoding' }
WollokBytecodeInterpreter >> decodeNilFrom: aReadStream [ 
	
	^ memory nullObject
]

{ #category : #'literal-decoding' }
WollokBytecodeInterpreter >> decodeNumberFrom: aReadStream [ 
	
	| numerator denominator scale |
	numerator := aReadStream next: 8.
	denominator := aReadStream next: 8.
	scale := aReadStream next.
	
	^ memory asWollokNumber: (ScaledDecimal
		newFromNumber: (numerator asInteger / denominator asInteger)
		scale: scale)
]

{ #category : #'literal-decoding' }
WollokBytecodeInterpreter >> decodeStringFrom: aReadStream [ 

	^ memory asWollokString: (self basicDecodeStringFrom: aReadStream)
]

{ #category : #interpreting }
WollokBytecodeInterpreter >> dispatchBytecode: anInteger [ 
	
	self perform: (dispatchTable at: anInteger)
]

{ #category : #activation }
WollokBytecodeInterpreter >> executeNativeMethodFrom: aClassName selector: aSelector [
	
	| nativeName mapping |
	
	"Operators are not valid keyword selectors in Pharo, so map them"
	mapping := selectorMappings
		at: (self memory asPharoString: aSelector)
		ifAbsent: [ self memory asPharoString: aSelector ].
	
	nativeName := ((aClassName copyReplaceAll: '.' with: '_'), '__', mapping) asSymbol.
	^ self perform: nativeName
]

{ #category : #interpreting }
WollokBytecodeInterpreter >> fetchNextBytecode [
	
	| bytecode |
	bytecode := self currentMethod bytecode at: programCounter.
	programCounter := programCounter + 1.
	^ bytecode
]

{ #category : #'exception-management' }
WollokBytecodeInterpreter >> frame: aFramePointer ip: frameInstructionPointer handlesException: aWollokException [
	
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
WollokBytecodeInterpreter >> frameCallerFP: anInteger [ 
	
	^ stack at: anInteger - 2
]

{ #category : #frames }
WollokBytecodeInterpreter >> frameCallerIP: aFramePointer [

	^ stack at: aFramePointer - 1
]

{ #category : #frames }
WollokBytecodeInterpreter >> frameMethod: anInteger [ 
	
	^ stack at: anInteger 
]

{ #category : #accessing }
WollokBytecodeInterpreter >> framePointer [
	^ framePointer
]

{ #category : #initialization }
WollokBytecodeInterpreter >> initialize [

	super initialize.
	asts := Dictionary new.
	bindings := Dictionary new.
	
	stack := Array new: 256.
	framePointer := stackPointer := 1.
	programCounter := 1.
	
	dispatchTable := Dictionary new.
	dispatchTable at: 1 put: #bytecodePushLiteral.
	dispatchTable at: 2 put: #bytecodeSend.
	dispatchTable at: 3 put: #bytecodePop.
	dispatchTable at: 4 put: #bytecodeReturn.
	dispatchTable at: 7 put: #bytecodePushSelf.
	dispatchTable at: 8 put: #bytecodePushTemporary.
	dispatchTable at: 9 put: #bytecodeJumpFalse.
	dispatchTable at: 10 put: #bytecodeJump.
	dispatchTable at: 11 put: #bytecodePopIntoTemporary.
	dispatchTable at: 12 put: #bytecodeNew.
	dispatchTable at: 13 put: #bytecodePopIntoInstanceVariable.
	dispatchTable at: 14 put: #bytecodePushInstanceVariable.
	dispatchTable at: 15 put: #bytecodeDup.
	dispatchTable at: 16 put: #bytecodeSendSuper.
	dispatchTable at: 17 put: #bytecodeNewList.
	dispatchTable at: 18 put: #bytecodePushGlobal.
	dispatchTable at: 19 put: #bytecodeThrow.
	
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

{ #category : #instantiation }
WollokBytecodeInterpreter >> instantiateClass: aWKBytecodeClass [

	^ memory instantiateClass: aWKBytecodeClass
]

{ #category : #interpreting }
WollokBytecodeInterpreter >> interpretLoop [
	
	self interpretUntilReturn: -1 "sentinel frame pointer"
]

{ #category : #interpreting }
WollokBytecodeInterpreter >> interpretProgram: bytecodes [
	
	self push: -1 "sentinel receiver".
	self push: -1 "sentinel framePointer".
	self push: -1 "sentinel programCounter".
	
	bytecodes do: [ :e | self load: e ].
	self createFrameForMethod: program.
	self interpretLoop.
	^ self pop
]

{ #category : #interpreting }
WollokBytecodeInterpreter >> interpretUntilReturn: parentFrame [

	[ framePointer > parentFrame ] whileTrue: [ 
		| bytecode |
		bytecode := self fetchNextBytecode.
		self dispatchBytecode: bytecode.
	]
]

{ #category : #accessing }
WollokBytecodeInterpreter >> literalAt: anInteger [ 
	
	^ self currentMethod literalAt: anInteger
]

{ #category : #'name-resolution' }
WollokBytecodeInterpreter >> load: bytecode [

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

{ #category : #loader }
WollokBytecodeInterpreter >> loadBytecode: bytecode in: aWollokElement [
	
	| literals | 
	literals := OrderedCollection new.
	bytecode readStreamDo: [ :stream | | type |
		type := stream next.
		self assert: type <= 3 "program, class or object for now.".
		(1 to: stream next) collect: [ :i | 
			literals add: (self decodeLiteralFrom: stream) ].
		aWollokElement literals: literals.
		aWollokElement decodeFrom: stream.
		aWollokElement finishLoadingIn: self.
	]
]

{ #category : #lookup }
WollokBytecodeInterpreter >> lookup: aString fromClass: aWollokClass [

	^ aWollokClass lookup: (memory asPharoString: aString) asSymbol
]

{ #category : #lookup }
WollokBytecodeInterpreter >> lookup: aString withReceiver: aWollokObject [

	^ (memory classOf: aWollokObject) lookup: (self memory asPharoString: aString) asSymbol
]

{ #category : #accessing }
WollokBytecodeInterpreter >> memory [
	^ memory
]

{ #category : #compiling }
WollokBytecodeInterpreter >> parse: aString [ 
	
	| anAST |
	anAST := WollokParser parse: aString.
	anAST attributeNamed: #source put: aString.
	^ anAST
]

{ #category : #'stack-management' }
WollokBytecodeInterpreter >> pop [
	
	stackPointer := stackPointer - 1.
	^ stack at: stackPointer
	
]

{ #category : #'stack-management' }
WollokBytecodeInterpreter >> pop: anInteger [
	"pop a number of elements"
	
	stackPointer := stackPointer - anInteger
]

{ #category : #bytecode }
WollokBytecodeInterpreter >> popFrame [
	
	programCounter := self frameCallerIP: framePointer.
	stackPointer := framePointer - 2.
	framePointer := self frameCallerFP: framePointer.
]

{ #category : #accessing }
WollokBytecodeInterpreter >> program: aWKBytecodeProgram [ 
	
	program := aWKBytecodeProgram
]

{ #category : #frames }
WollokBytecodeInterpreter >> push: aValue [
self haltIf: [ aValue isNil. ].
	stack at: stackPointer put: aValue.
	stackPointer := stackPointer + 1
]

{ #category : #accessing }
WollokBytecodeInterpreter >> receiver [
	
	^ stack at: framePointer "Frame points to current frame"
		- 2 "Skip saved frame pointer and saved instruction pointer"
		- self currentMethod numberOfParameters "Skip parameters"
		- 1 "Go back by 1 to get the receiver"
]

{ #category : #globals }
WollokBytecodeInterpreter >> registerGlobal: aWollokVMObject atName: aString [ 
	
	bindings at: aString asSymbol put: aWollokVMObject
]

{ #category : #'name-resolution' }
WollokBytecodeInterpreter >> resolve: aString [
	
	| astclass |
	"If already loaded, use it"
	bindings at: aString ifPresent: [ :c | ^ c ].

	"Otherwise, load it"
	astclass := [
		WollokReducedLoader new
			loadClassNamed: aString
			in: self ]
		on: Error do: [ :err |
		WollokReducedLoader new
			loadClassNamed: 'wollok.lang.', aString
			in: self	].
	
	^ self compileAndInstall: astclass
]

{ #category : #'stack-access' }
WollokBytecodeInterpreter >> stackAt: anInteger [ 
	
	^ stack at: stackPointer - anInteger
]

{ #category : #accessing }
WollokBytecodeInterpreter >> wollokClassName: anInteger [ 
	
	^ memory wollokClassName: anInteger
]

{ #category : #'native methods' }
WollokBytecodeInterpreter >> wollok_lang_Boolean__and [
	
	| boolean1 boolean2 |
	boolean1 := self pop.
	boolean2 := self pop.
	self push: (self asWollokBoolean: ((self asPharoBoolean: boolean1) & (self asPharoBoolean: boolean2)))
]

{ #category : #'native methods' }
WollokBytecodeInterpreter >> wollok_lang_Boolean__equals [
	
	self push: (memory asWollokBoolean: self pop == self pop)
]

{ #category : #'native methods' }
WollokBytecodeInterpreter >> wollok_lang_Boolean__or [
	
	| boolean1 boolean2 |
	boolean1 := self pop.
	boolean2 := self pop.
	self push: (self asWollokBoolean: ((self asPharoBoolean: boolean1) | (self asPharoBoolean: boolean2)))
]

{ #category : #'native methods' }
WollokBytecodeInterpreter >> wollok_lang_List__add [
	
	| added receiver |
	added := self pop.
	receiver := self pop.
	
	receiver literalValue add: added.
	self push: added
]

{ #category : #'native methods' }
WollokBytecodeInterpreter >> wollok_lang_List__contains [
	
	| tested list |
	tested := self pop.
	list := self pop.
	
	self push: (self asWollokBoolean: (list literalValue includes: tested))
]

{ #category : #'native methods' }
WollokBytecodeInterpreter >> wollok_lang_List__size [
	
	| list |
	list := self pop.
	self push: (memory asWollokNumber: list literalValue size)
]

{ #category : #'native methods' }
WollokBytecodeInterpreter >> wollok_lang_Number__division [

	| number1 number2 |
	number2 := self pop.
	number1 := self pop.
	self push: (memory asWollokNumber: ((memory asPharoNumber: number1) / (memory asPharoNumber: number2)))
]

{ #category : #'native methods' }
WollokBytecodeInterpreter >> wollok_lang_Number__greater [

	| number1 number2 |
	number2 := self pop.
	number1 := self pop.
	self push: (self asWollokBoolean: ((memory asPharoNumber: number1) > (memory asPharoNumber: number2)))
]

{ #category : #'native methods' }
WollokBytecodeInterpreter >> wollok_lang_Number__identical [
	
	| number1 number2 |
	number1 := self pop.
	number2 := self pop.
	self push: (self asWollokBoolean: ((memory asPharoNumber: number1) = (memory asPharoNumber: number2)))
]

{ #category : #'native methods' }
WollokBytecodeInterpreter >> wollok_lang_Number__invert [

	| number1 |
	number1 := self pop.
	self push: (memory asWollokNumber: (memory asPharoNumber: number1) negated)
]

{ #category : #'native methods' }
WollokBytecodeInterpreter >> wollok_lang_Number__lower [

	| number1 number2 |
	number2 := self pop.
	number1 := self pop.
	self push: (self asWollokBoolean: ((memory asPharoNumber: number1) < (memory asPharoNumber: number2)))
]

{ #category : #'native methods' }
WollokBytecodeInterpreter >> wollok_lang_Number__minus [

	| number1 number2 |
	number2 := self pop.
	number1 := self pop.

	self push: (memory asWollokNumber: ((memory asPharoNumber: number1) - (memory asPharoNumber: number2)))
]

{ #category : #'native methods' }
WollokBytecodeInterpreter >> wollok_lang_Number__modulo [
	
	| number2 number1 |
	number2 := memory asPharoNumber: self pop.
	number1 := memory asPharoNumber: self pop.
	
	self push: (memory asWollokNumber: number1 \\ number2)
]

{ #category : #'native methods' }
WollokBytecodeInterpreter >> wollok_lang_Number__multiplication [

	| number1 number2 |
	number2 := self pop.
	number1 := self pop.
	self push: (memory asWollokNumber: ((memory asPharoNumber: number1) * (memory asPharoNumber: number2)))
]

{ #category : #'native methods' }
WollokBytecodeInterpreter >> wollok_lang_Number__plus [

	| number1 number2 |
	number2 := self pop.
	number1 := self pop.
	self push: (memory asWollokNumber: ((memory asPharoNumber: number1) + (memory asPharoNumber: number2)))
]

{ #category : #'native methods' }
WollokBytecodeInterpreter >> wollok_lang_Number__truncate [

	| truncation number truncatedNumber |
	truncation := memory asPharoNumber: self pop.
	number := memory asPharoNumber: self pop.

	truncatedNumber := number truncateTo: 1 / (10 raisedTo: truncation) asScaledDecimal.
	self push: (memory asWollokNumber: truncatedNumber)
]

{ #category : #'native methods' }
WollokBytecodeInterpreter >> wollok_lang_Object__identity [
	
	| receiver |
	receiver := self pop.
	self push: (memory identityOf: receiver)
]

{ #category : #'native methods' }
WollokBytecodeInterpreter >> wollok_lang_String__concat [
	
	| receiver argument |
	argument := self pop.
	receiver := self pop.
	self push: (memory asWollokString: (self memory asPharoString: receiver), (self memory asPharoString: argument))
]

{ #category : #'native methods' }
WollokBytecodeInterpreter >> wollok_lang_String__toString [
	
	| receiver |
	receiver := self pop.
	self push: (memory asWollokString: (self memory asPharoString: receiver) asString)
]
