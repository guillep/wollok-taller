Class {
	#name : #WollokBytecodeCompiler,
	#superclass : #Object,
	#instVars : [
		'builder',
		'operatorToMessageMapping',
		'temporaryIndexes',
		'loader',
		'compilationClass'
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
WollokBytecodeCompiler >> builder [
	^ builder
]

{ #category : #accessing }
WollokBytecodeCompiler >> builder: anObject [
	builder := anObject
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
	
	builder := WKBytecodeBuilder new.
	aWollokFileNode acceptVisitor: self.
	^ builder bytecode
]

{ #category : #'name-resolution' }
WollokBytecodeCompiler >> indexOfInstanceVariableNamed: aString [ 
	
	^ ((self allVariablesOf: self compilationClass)
		collect: [ :e | e variable name value ])
			indexOf: aString
]

{ #category : #visiting }
WollokBytecodeCompiler >> initialize [

	super initialize.
	temporaryIndexes := Dictionary new.
	
	operatorToMessageMapping := Dictionary new.
	operatorToMessageMapping at: '!' put: 'negate'.
	operatorToMessageMapping at: '-' put: 'invert'
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

{ #category : #'name-resolution' }
WollokBytecodeCompiler >> superClassOf: aWollokClassNode [ 
	
	| superclassname |
	aWollokClassNode name value = 'Object'
		ifTrue: [ ^ nil ].
	superclassname := aWollokClassNode superclass
		ifNil: [ 'Object' ]
		ifNotNil: [ aWollokClassNode superclass halt ].
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
	
	| superclass hasInitializer |
	compilationClass := aWollokClassNode.

	builder forClass.

	superclass := aWollokClassNode name value ~= 'Object' ifTrue: [
		aWollokClassNode superclass
			ifNil: [ 'Object' ]
			ifNotNil: [ 
				self assert: aWollokClassNode superclass identifiers size = 1.
				aWollokClassNode superclass identifiers first value ] ].
	builder addLiteral: superclass.

	"Initializer of the variable declarations"
	builder beginMethod: '____init' native: false numberOfParameters: 0.
	hasInitializer := false.
	aWollokClassNode variables do: [ :e |
		e right ifNotNil: [
			hasInitializer := true.
			self assign: e right toVariable: e variable ]
	].
	hasInitializer ifFalse: [ builder pushSelf ].
	builder returnTop.
	builder endMethod.
		

	aWollokClassNode members do: [ :e |
		e acceptVisitor: self ].
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
	
	"Do nothing"
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
	
	| native |

	temporaryIndexes := Dictionary new.
	aWollokMethodDeclarationNode parameters withIndexDo: [ :e :i |
		temporaryIndexes at: e parameter value put: i.
	].
	
	native := aWollokMethodDeclarationNode native notNil.
		
	builder
		beginMethod: aWollokMethodDeclarationNode name value
		native: native
		numberOfParameters: aWollokMethodDeclarationNode parameters size.
	native ifTrue: [ ^ self ].

	aWollokMethodDeclarationNode expression acceptVisitor: self.
	builder returnTop.
	builder endMethod.
]

{ #category : #visiting }
WollokBytecodeCompiler >> visitNumberLiteral: aWollokNumberLiteralNode [ 
	
	builder pushLiteral: aWollokNumberLiteralNode value value asNumber
]

{ #category : #visiting }
WollokBytecodeCompiler >> visitParenthesizedExpression: aWollokParenthesizedExpressionNode [ 
	
	^ aWollokParenthesizedExpressionNode expression acceptVisitor: self
]

{ #category : #visiting }
WollokBytecodeCompiler >> visitProgram: aWollokProgramNode [ 

	builder forProgram.
	aWollokProgramNode elements
		do: [ :e | e acceptVisitor: self ]
		separatedBy: [ builder pop ].
	builder returnTop.
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
WollokBytecodeCompiler >> visitStringLiteral: aWollokStringLiteralNode [ 
	
	builder pushLiteral: aWollokStringLiteralNode value value allButFirst allButLast
]

{ #category : #visiting }
WollokBytecodeCompiler >> visitSuperInvocation: aWollokSuperInvocationNode [ 
	
	| messageName |
	builder pushSelf.
	aWollokSuperInvocationNode arguments do: [ :e |
		e acceptVisitor: self ].
	
	builder superSend
]

{ #category : #visiting }
WollokBytecodeCompiler >> visitThrow: aWollokThrowNode [ 
	
	"Nothing for now"
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
	builder pushInstanceVariable: ivIndex.

]

{ #category : #visiting }
WollokBytecodeCompiler >> visitVariableDeclaration: aWollokVariableDeclarationNode [

	"define the variable"
	temporaryIndexes at: aWollokVariableDeclarationNode variable name value put: temporaryIndexes size.

	self
		assign: aWollokVariableDeclarationNode right
		toVariable: aWollokVariableDeclarationNode variable
]
