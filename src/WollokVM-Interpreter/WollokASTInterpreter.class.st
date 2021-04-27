Class {
	#name : #WollokASTInterpreter,
	#superclass : #WKAbstractInterpreter,
	#instVars : [
		'bindings',
		'selectorMappings',
		'stack'
	],
	#category : #'WollokVM-Interpreter'
}

{ #category : #visiting }
WollokASTInterpreter >> activateMethod: method withReceiver: receiver withArguments: arguments [

	| result |
	method	 native ifNotNil: [
		^ self
			executeNativeMethod: method
			withReceiver: receiver
			withArguments: arguments.
	].

	"Manejar el caso de la ejecución normal con manejo de pila"
	self
		pushFrameForMethod: method
		receiver: receiver
		arguments: arguments.
	result := method acceptVisitor: self.
	self popFrame.
	^ result
]

{ #category : #bindings }
WollokASTInterpreter >> addBinding: aName value: aWollokVMClass [ 
	
	bindings at: aName put: aWollokVMClass
]

{ #category : #bindings }
WollokASTInterpreter >> addBindingOfClass: aName fromString: aString [

	| anAST astclass |
	anAST := WollokParser parse: aString.
	anAST attributeNamed: #source put: aString.

	astclass := WollokASTVMClass new
		name: aName;
		ast: anAST;
		interpreter: self;
		yourself.
	self addBinding: aName value: astclass.
	^ astclass
]

{ #category : #compiling }
WollokASTInterpreter >> compile: aString [ 
	
	^ self parse: aString
]

{ #category : #'native methods' }
WollokASTInterpreter >> executeNativeMethod: aMethod withReceiver: aReceiver withArguments: arguments [
	
	| nativeName selector mapping aClassName |
	"Operators are not valid keyword selectors in Pharo, so map them"
	aClassName := 'wollok.lang.', aMethod parent name value.
	selector := aMethod name value.
	mapping := selectorMappings
		at: selector
		ifAbsent: [ selector ].
	
	nativeName := ((aClassName copyReplaceAll: '.' with: '_'), '__', mapping) asSymbol.
	^ self
		perform: nativeName asMutator , 'with:'
		with: aReceiver
		with: arguments
]

{ #category : #interpreting }
WollokASTInterpreter >> initialize [

	super initialize.

	stack := Stack new.
	bindings := Dictionary new.
	
	WollokReducedLoader new loadInto: self.
	
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

{ #category : #interpreting }
WollokASTInterpreter >> interpretProgram: aFileNode [ 

	| lastValue |

	aFileNode main elements do: [ :e | lastValue := e acceptVisitor: self ].

	^ lastValue	
]

{ #category : #lookup }
WollokASTInterpreter >> lookup: aString in: aWollokVMClass [ 
	
	^ aWollokVMClass lookup: aString asSymbol
]

{ #category : #compiling }
WollokASTInterpreter >> parse: aString [ 
	
	| anAST |
	anAST := WollokParser parse: aString.
	anAST attributeNamed: #source put: aString.
	^ anAST
]

{ #category : #'stack-management' }
WollokASTInterpreter >> popFrame [
	
	^ stack pop
]

{ #category : #stack }
WollokASTInterpreter >> pushFrameForMethod: aWollokMethodDeclarationNode receiver: aReceiver arguments: aCollection [ 
	
	| context |
	context := WKASTContext new.
	context method: aWollokMethodDeclarationNode.
	context receiver: aReceiver.
	context arguments: aCollection.
	stack push: context
]

{ #category : #bindings }
WollokASTInterpreter >> resolve: aString [ 
	
	^ bindings at: aString
]

{ #category : #visiting }
WollokASTInterpreter >> visitBinaryOperation: aBinaryOperation [

	| leftResult rightResult receiver argument method |
	receiver := aBinaryOperation leftOperand acceptVisitor: self.
	argument := aBinaryOperation rightOperand acceptVisitor: self.
	method := self lookup: aBinaryOperation operation value in: (memory classOf: receiver).
	^ self activateMethod: method withReceiver: receiver withArguments: {argument}
]

{ #category : #visiting }
WollokASTInterpreter >> visitBooleanLiteral: aWollokBooleanLiteralNode [
	
	^ memory asWollokBoolean: aWollokBooleanLiteralNode value value = 'true'
]

{ #category : #visiting }
WollokASTInterpreter >> visitMemberFeatureCall: aWollokMemberFeatureCallNode [ 
	
	| receiver arguments method |
	receiver := aWollokMemberFeatureCallNode receiver acceptVisitor: self.
	arguments := aWollokMemberFeatureCallNode arguments collect: [ :each |
		each acceptVisitor: self ].
	method := self lookup: aWollokMemberFeatureCallNode feature value in: (memory classOf: receiver).
	^ self activateMethod: method withReceiver: receiver withArguments: arguments
]

{ #category : #visiting }
WollokASTInterpreter >> visitMethodDeclaration: aWollokMethodDeclarationNode [ 
	
	^ aWollokMethodDeclarationNode expression acceptVisitor: self
]

{ #category : #visiting }
WollokASTInterpreter >> visitNumberLiteral: aWollokNumberLiteralNode [ 

	^ self asWollokNumber: aWollokNumberLiteralNode numberValue
]

{ #category : #visiting }
WollokASTInterpreter >> visitSelf: aWollokSelfNode [ 
	
	^ stack top receiver
]

{ #category : #visiting }
WollokASTInterpreter >> visitStringLiteral: aWollokStringLiteralNode [ 
	
	^ memory asWollokString: aWollokStringLiteralNode value value
]

{ #category : #visiting }
WollokASTInterpreter >> visitVariable: aWollokVariableNode [ 
	
	^ stack top readVariable: aWollokVariableNode name value
]

{ #category : #'native methods' }
WollokASTInterpreter >> wollok_lang_Boolean__and: receiver with: aCollection [ 
	
	^ memory asWollokBoolean: (memory asPharoBoolean: receiver) &
		(memory asPharoBoolean: aCollection first)
]

{ #category : #'native methods' }
WollokASTInterpreter >> wollok_lang_Boolean__or: receiver with: aCollection [ 
	
	^ memory asWollokBoolean: (memory asPharoBoolean: receiver) |
		(memory asPharoBoolean: aCollection first)
]

{ #category : #'native methods' }
WollokASTInterpreter >> wollok_lang_Number__identical: anInteger with: aCollection [ 

	^ memory asWollokBoolean: (memory asPharoNumber: anInteger) = (memory asPharoNumber: aCollection first)
]

{ #category : #'native methods' }
WollokASTInterpreter >> wollok_lang_Number__modulo: aReceiver with: aCollection [ 

	^ memory asWollokNumber: (memory asPharoNumber: aReceiver) \\
		(memory asPharoNumber: aCollection first)
]

{ #category : #'native methods' }
WollokASTInterpreter >> wollok_lang_Number__multiplication: aReceiver with: aCollection [ 

	^ memory asWollokNumber: (memory asPharoNumber: aReceiver) *
		(memory asPharoNumber: aCollection first)
]

{ #category : #'native methods' }
WollokASTInterpreter >> wollok_lang_Number__plus: aWollokVMLiteral with: aCollection [ 
	
	^ memory asWollokNumber: (memory asPharoNumber: aWollokVMLiteral) +
		(memory asPharoNumber: aCollection first)
]

{ #category : #'native methods' }
WollokASTInterpreter >> wollok_lang_Object__identity: receiver with: aCollection [ 
	
	^ (memory identityOf: receiver)
]
