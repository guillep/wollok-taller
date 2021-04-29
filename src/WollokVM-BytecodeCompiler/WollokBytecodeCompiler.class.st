Class {
	#name : #WollokBytecodeCompiler,
	#superclass : #Object,
	#instVars : [
		'builder',
		'operatorToMessageMapping',
		'temporaryIndexes',
		'loader',
		'compilationClass',
		'results',
		'asts'
	],
	#category : #'WollokVM-BytecodeCompiler'
}

{ #category : #'name-resolution' }
WollokBytecodeCompiler >> allVariablesOf: aWollokClassNode [ 
	
	| superVariables |
	aWollokClassNode ifNil: [ ^ #() ].

	superVariables := self allVariablesOf: (self superClassOf: aWollokClassNode).
	^ superVariables , (self variablesOf: aWollokClassNode)
]

{ #category : #'anonimous-objects' }
WollokBytecodeCompiler >> allocateAnonimousClassName [
	
	^ UUID new asString
]

{ #category : #accessing }
WollokBytecodeCompiler >> asFullyQualifiedName: aString [ 
	
	({#Object. #List. #Exception. #String. #Boolean. #Set. #Collection. #Number}
		includes: aString) ifFalse: [ ^ aString ].
	^ 'wollok.lang.', aString
]

{ #category : #visiting }
WollokBytecodeCompiler >> assign: right toVariable: left [ 
	
	
	| ivIndex |
	right acceptVisitor: self.
	temporaryIndexes
		at: left name value
		ifPresent: [ :index | 
			builder popIntoTemporaryVariable: index.
			builder pushTemporaryVariable: index.
			^ self ].

	ivIndex := self indexOfInstanceVariableNamed: left name value.
	builder popIntoInstanceVariable: ivIndex.
	builder pushInstanceVariable: ivIndex.
]

{ #category : #accessing }
WollokBytecodeCompiler >> asts: aCollection [ 
	
	asts := aCollection
]

{ #category : #visiting }
WollokBytecodeCompiler >> buildBehavior: aWollokBehavior [

	| superclass hasInitializer methodStart |
	"If it is a root class, superclass is nil"
	superclass := (self isRootClass: aWollokBehavior) ifFalse: [
		aWollokBehavior superclass
			ifNil: [ 'Object' ]
			ifNotNil: [ 
				self assert: aWollokBehavior superclass identifiers size = 1.
				aWollokBehavior superclass identifiers first value ] ].
	builder addLiteral: superclass.

	"Initializer of the variable declarations"
	methodStart := builder beginMethod: '____init' native: false numberOfParameters: 0.
	hasInitializer := false.
	aWollokBehavior variables do: [ :e |
		e right ifNotNil: [
			hasInitializer := true.
			self assign: e right toVariable: e variable.
			builder pop. ]
	].
	builder pushSelf.
	builder returnTop.
	builder endMethod: methodStart.
		

	aWollokBehavior methods do: [ :e |
		e acceptVisitor: self ].
	
	results add: builder bytecode
]

{ #category : #visiting }
WollokBytecodeCompiler >> buildClass: aWollokClassNode named: aName [

	compilationClass := aWollokClassNode.
	builder forClass.
	builder numberOfSlots: (self allVariablesOf: aWollokClassNode) size.
	builder addLiteral: aName.
	self buildBehavior: aWollokClassNode
]

{ #category : #accessing }
WollokBytecodeCompiler >> builder [
	^ builder
]

{ #category : #accessing }
WollokBytecodeCompiler >> builder: anObject [
	builder := anObject
]

{ #category : #building }
WollokBytecodeCompiler >> bytecode [
	
	^ builder bytecode
]

{ #category : #accessing }
WollokBytecodeCompiler >> compilationClass [
	
	^ compilationClass
]

{ #category : #accessing }
WollokBytecodeCompiler >> compilationClass: anObject [
	compilationClass := anObject
]

{ #category : #api }
WollokBytecodeCompiler >> compile: aWollokFileNode [ 

	aWollokFileNode acceptVisitor: self
]

{ #category : #'name-resolution' }
WollokBytecodeCompiler >> indexOfInstanceVariableNamed: aString [ 
	
	^ ((self allVariablesOf: self compilationClass)
		collect: [ :e | e variable name value ])
			indexOf: aString
]

{ #category : #api }
WollokBytecodeCompiler >> initialize [

	super initialize.
	results := OrderedCollection new.
	
	temporaryIndexes := Dictionary new.
	builder := WKBytecodeBuilder new.
	
	operatorToMessageMapping := Dictionary new.
	operatorToMessageMapping at: '!' put: 'negate'.
	operatorToMessageMapping at: '-' put: 'invert'
]

{ #category : #testing }
WollokBytecodeCompiler >> isRootClass: aWollokBehavior [ 
	
	^ (aWollokBehavior isKindOf: WollokClassNode)
		and: [ aWollokBehavior name value = 'Object' ]
]

{ #category : #accessing }
WollokBytecodeCompiler >> loader [
	^ loader
]

{ #category : #accessing }
WollokBytecodeCompiler >> loader: anObject [
	loader := anObject
]

{ #category : #accessing }
WollokBytecodeCompiler >> operatorToMessageMapping [
	^ operatorToMessageMapping
]

{ #category : #accessing }
WollokBytecodeCompiler >> operatorToMessageMapping: anObject [
	operatorToMessageMapping := anObject
]

{ #category : #accessing }
WollokBytecodeCompiler >> results [
	
	^ results
]

{ #category : #'name-resolution' }
WollokBytecodeCompiler >> superClassOf: aWollokClassNode [ 
	
	| superclassname |
	(self isRootClass: aWollokClassNode)
		ifTrue: [ ^ nil ].
	superclassname := aWollokClassNode superclass
		ifNil: [ 'Object' ]
		ifNotNil: [ | ids |
			ids := aWollokClassNode superclass identifiers.
			self haltIf: ids size > 1.
			ids first value ].
		
	asts at: superclassname ifPresent: [ :p | ^ p ].
	^ loader astOfClassNamed: superclassname
]

{ #category : #accessing }
WollokBytecodeCompiler >> temporaryIndexes [
	^ temporaryIndexes
]

{ #category : #accessing }
WollokBytecodeCompiler >> temporaryIndexes: anObject [
	temporaryIndexes := anObject
]

{ #category : #'name-resolution' }
WollokBytecodeCompiler >> variablesOf: aWollokClassNode [ 
	
	^ aWollokClassNode variables
]

{ #category : #visiting }
WollokBytecodeCompiler >> visitAssignment: aWollokAssignmentNode [ 
	
	self assign: aWollokAssignmentNode value toVariable: aWollokAssignmentNode variable
]

{ #category : #visiting }
WollokBytecodeCompiler >> visitBinaryOperation: aWollokBinaryOperationNode [ 
	
	| messageName |
	aWollokBinaryOperationNode leftOperand acceptVisitor: self.
	aWollokBinaryOperationNode rightOperand acceptVisitor: self.
	builder send: aWollokBinaryOperationNode operation value numberOfArguments: 1
]

{ #category : #visiting }
WollokBytecodeCompiler >> visitBlockExpression: aWollokBlockExpressionNode [ 
	
	aWollokBlockExpressionNode expressions
		ifEmpty: [ ^ builder pushSelf ].
	
	aWollokBlockExpressionNode expressions
		do: [ :e | e acceptVisitor: self ]
		separatedBy: [ builder pop ]
]

{ #category : #visiting }
WollokBytecodeCompiler >> visitBooleanLiteral: aWollokBooleanLiteralNode [ 
	
	"Nice trick to convert a boolean string to a boolean."
	builder pushLiteral: aWollokBooleanLiteralNode value value = 'true'
]

{ #category : #visiting }
WollokBytecodeCompiler >> visitClass: aWollokClassNode [

	^ self buildClass: aWollokClassNode named: (self asFullyQualifiedName: aWollokClassNode name value)
]

{ #category : #visiting }
WollokBytecodeCompiler >> visitClosure: aWollokClosureNode [ 
	
	"Nothing for now"
]

{ #category : #visiting }
WollokBytecodeCompiler >> visitConstructorCall: aWollokConstructorCallNode [
	
	self haltIf: [ aWollokConstructorCallNode classRef identifiers size > 1 ].
	builder instantiate: aWollokConstructorCallNode classRef identifiers value first value.

	builder dup.
	builder send: '____init' numberOfArguments: 0.
	builder pop.
	
	builder dup.
	builder send: 'initialize' numberOfArguments: 0.
	builder pop.
]

{ #category : #visiting }
WollokBytecodeCompiler >> visitFile: aWollokFileNode [ 
	
	aWollokFileNode children do: [ :e |
		e acceptVisitor: self ]
]

{ #category : #visiting }
WollokBytecodeCompiler >> visitIfExpression: aWollokIfExpressionNode [ 
	
	| jump jumpOver |
	aWollokIfExpressionNode condition acceptVisitor: self.
	jump := builder jumpFalse: nil.
	aWollokIfExpressionNode then acceptVisitor: self.
	aWollokIfExpressionNode else ifNotNil: [ 
		jumpOver := builder jump: nil ].

	"False case"	
	jump jumpTarget: builder label.

	"if we have an else case, the true branch should jump over the false branch"
	aWollokIfExpressionNode else ifNotNil: [ 
		aWollokIfExpressionNode else acceptVisitor: self.
	].

	jumpOver ifNotNil: [ jumpOver jumpTarget: builder label ].

]

{ #category : #visiting }
WollokBytecodeCompiler >> visitListLiteral: aWollokListLiteralNode [ 
	
	builder instantiateList.
	aWollokListLiteralNode elements do: [ :e |
		builder dup.
		e acceptVisitor: self.
		builder send: 'add' numberOfArguments: 1.
		builder pop ].
]

{ #category : #visiting }
WollokBytecodeCompiler >> visitMemberFeatureCall: aWollokMemberFeatureCallNode [ 

	| messageName |
	aWollokMemberFeatureCallNode receiver acceptVisitor: self.
	aWollokMemberFeatureCallNode arguments do: [ :e |
		e acceptVisitor: self ].
	messageName := aWollokMemberFeatureCallNode feature value.
	
	builder send: messageName numberOfArguments: aWollokMemberFeatureCallNode arguments size
]

{ #category : #visiting }
WollokBytecodeCompiler >> visitMethodDeclaration: aWollokMethodDeclarationNode [ 
	
	| native methodStart |

	temporaryIndexes := Dictionary new.
	aWollokMethodDeclarationNode parameters withIndexDo: [ :e :i |
		temporaryIndexes at: e parameter value put: i.
	].
	
	native := aWollokMethodDeclarationNode native notNil.
	
	"Check if method is abstract"
	(native not and: [ aWollokMethodDeclarationNode expression isNil ])
		ifTrue: [ ^ self ].
	
	methodStart := builder
		beginMethod: aWollokMethodDeclarationNode name value
		native: native
		numberOfParameters: aWollokMethodDeclarationNode parameters size.
	native ifTrue: [ ^ self ].

	aWollokMethodDeclarationNode expression acceptVisitor: self.
	builder returnTop.
	builder endMethod: methodStart.
]

{ #category : #visiting }
WollokBytecodeCompiler >> visitNamedObject: aWollokNamedObjectNode [ 

	compilationClass := aWollokNamedObjectNode.
	builder forObject.
	builder numberOfSlots: (self allVariablesOf: aWollokNamedObjectNode) size.
	builder addLiteral: aWollokNamedObjectNode name value.
	self buildBehavior: aWollokNamedObjectNode
]

{ #category : #visiting }
WollokBytecodeCompiler >> visitNullLiteral: aWollokNullLiteralNode [ 
	
	builder pushLiteral: nil
]

{ #category : #visiting }
WollokBytecodeCompiler >> visitNumberLiteral: aWollokNumberLiteralNode [ 
	
	builder pushLiteral: aWollokNumberLiteralNode value value asNumber
]

{ #category : #visiting }
WollokBytecodeCompiler >> visitObjectLiteral: aWollokObjectLiteralNode [ 
	
	| compiler anonimousClassName |
	anonimousClassName := self allocateAnonimousClassName.
	
	compiler := WollokBytecodeCompiler new.
	compiler loader: WollokReducedLoader new.
	results addAll: (compiler
		asts: asts;
		buildClass: aWollokObjectLiteralNode
		named: anonimousClassName) results.

	builder instantiate: anonimousClassName.
	builder dup.
	builder send: '____init' numberOfArguments: 0.
	builder pop.
	builder dup.
	builder send: 'initialize' numberOfArguments: 0.
	builder pop.
]

{ #category : #visiting }
WollokBytecodeCompiler >> visitParenthesizedExpression: aWollokParenthesizedExpressionNode [ 
	
	^ aWollokParenthesizedExpressionNode expression acceptVisitor: self
]

{ #category : #visiting }
WollokBytecodeCompiler >> visitProgram: aWollokProgramNode [ 

	| methodStart |
	builder forProgram.
	builder addLiteral: aWollokProgramNode name value.
	
	methodStart := builder beginMethod: aWollokProgramNode name value native: false numberOfParameters: 0.
	aWollokProgramNode elements
		do: [ :e | e acceptVisitor: self ]
		separatedBy: [ builder pop ].
	builder returnTop.
	builder endMethod: methodStart.
	results add: builder bytecode
]

{ #category : #visiting }
WollokBytecodeCompiler >> visitReturnExpression: aWollokReturnExpressionNode [ 
	
	aWollokReturnExpressionNode expression acceptVisitor: self.
	builder returnTop.
]

{ #category : #visiting }
WollokBytecodeCompiler >> visitSelf: aWollokSelfNode [ 
	
	builder pushSelf
]

{ #category : #visiting }
WollokBytecodeCompiler >> visitSetLiteral: aWollokSetLiteralNode [ 
	
	"Nothing for now?"
]

{ #category : #visiting }
WollokBytecodeCompiler >> visitStringLiteral: aWollokStringLiteralNode [ 
	
	builder pushLiteral: aWollokStringLiteralNode value value allButFirst allButLast
]

{ #category : #visiting }
WollokBytecodeCompiler >> visitSuperInvocation: aWollokSuperInvocationNode [ 

	builder pushSelf.
	aWollokSuperInvocationNode arguments do: [ :e |
		e acceptVisitor: self ].
	
	builder superSend
]

{ #category : #visiting }
WollokBytecodeCompiler >> visitThrow: aWollokThrowNode [ 
	
	aWollokThrowNode exception acceptVisitor: self.
	builder throw
]

{ #category : #visiting }
WollokBytecodeCompiler >> visitTry: aWollokTryNode [

	| exceptionHandler jumpsToEndOfCatchBlocks |

	jumpsToEndOfCatchBlocks := OrderedCollection new.

	exceptionHandler := builder newExceptionHandlerDuring: [
		"Do not compile this as a closure. Inline the children statements directly"
		aWollokTryNode expression expression acceptVisitor: self.
		"Jump after the exception management code"
		jumpsToEndOfCatchBlocks add: (builder jump: nil).
	].

	aWollokTryNode catchBlocks do: [ :e | | exceptionName |
		exceptionName := self asFullyQualifiedName: e exceptionType identifiers first value.
		exceptionHandler addCaseFor: exceptionName startingAt: builder label.
		"Do not compile this as a closure. Inline the children statements directly"
		e expression expression acceptVisitor: self.
		jumpsToEndOfCatchBlocks add: (builder jump: nil).
	].

	jumpsToEndOfCatchBlocks do: [ :e |
		e jumpTarget: builder label ].

	"Do not compile this as a closure. Inline the children statements directly"
	aWollokTryNode alwaysExpression ifNotNil: [ :exp |
		exp expression acceptVisitor: self ].
]

{ #category : #visiting }
WollokBytecodeCompiler >> visitUnaryOperation: aWollokUnaryOperationNode [ 

	| messageName |
	aWollokUnaryOperationNode rightOperand acceptVisitor: self.
	
	"Some operators do not exist as such and are mapped to other messages.
	Inconsistency?"
	messageName := operatorToMessageMapping
		at: aWollokUnaryOperationNode operation value
		ifAbsent: [ aWollokUnaryOperationNode operation value ].
	builder send: messageName numberOfArguments: 0
]

{ #category : #visiting }
WollokBytecodeCompiler >> visitVariable: aWollokVariableNode [
	
	| ivIndex |
	temporaryIndexes
		at: aWollokVariableNode name value
		ifPresent: [ :tempIndex | ^ builder pushTemporaryVariable: tempIndex ].
	
	ivIndex := self indexOfInstanceVariableNamed: aWollokVariableNode name value.
	ivIndex > 0 ifTrue: [ ^ builder pushInstanceVariable: ivIndex ].
	
	builder pushGlobalNamed: aWollokVariableNode name value

]

{ #category : #visiting }
WollokBytecodeCompiler >> visitVariableDeclaration: aWollokVariableDeclarationNode [

	"define the variable"
	temporaryIndexes at: aWollokVariableDeclarationNode variable name value put: temporaryIndexes size.

	self
		assign: aWollokVariableDeclarationNode right
		toVariable: aWollokVariableDeclarationNode variable
]
