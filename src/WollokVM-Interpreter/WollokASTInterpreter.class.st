Class {
	#name : #WollokASTInterpreter,
	#superclass : #WKAbstractInterpreter,
	#instVars : [
		'bindings',
		'selectorMappings'
	],
	#category : #'WollokVM-Interpreter'
}

{ #category : #visiting }
WollokASTInterpreter >> activateMethod: method withReceiver: receiver withArguments: arguments [

	method	 native ifNotNil: [
		^ self
			executeNativeMethod: method
			withReceiver: receiver
			withArguments: arguments.
	].

	"Manejar el caso de la ejecución normal con manejo de pila"
	^ method acceptVisitor: self
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
	aClassName := self wollokClassName: aReceiver.
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
	method := self lookup: aWollokMemberFeatureCallNode feature value in: receiver wollokClass.
	^ self activateMethod: method withReceiver: receiver withArguments: arguments
]

{ #category : #visiting }
WollokASTInterpreter >> visitNumberLiteral: aWollokNumberLiteralNode [ 

	^ self asWollokNumber: aWollokNumberLiteralNode numberValue
]

{ #category : #'native methods' }
WollokASTInterpreter >> wollok_lang_Number__plus: aWollokVMLiteral with: aCollection [ 
	
	^ memory asWollokNumber: (memory asPharoNumber: aWollokVMLiteral) +
		(memory asPharoNumber: aCollection first)
]
