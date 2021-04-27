Class {
	#name : #WollokASTVMClass,
	#superclass : #Object,
	#instVars : [
		'name',
		'ast',
		'methods',
		'interpreter'
	],
	#category : #'WollokVM-Interpreter'
}

{ #category : #accessing }
WollokASTVMClass >> allVariables [

	^ self classAST variables collect: [ :e | e variable name value ]
]

{ #category : #accessing }
WollokASTVMClass >> ast [
	^ ast
]

{ #category : #accessing }
WollokASTVMClass >> ast: anObject [
	ast := anObject
]

{ #category : #accessing }
WollokASTVMClass >> classAST [
	
	^ ast elements first
]

{ #category : #accessing }
WollokASTVMClass >> interpreter: aWollokASTInterpreter [	

	interpreter := aWollokASTInterpreter
]

{ #category : #lookup }
WollokASTVMClass >> lookup: aString [

	^ self methods at: aString ifAbsent: [ self superclass lookup: aString ]
]

{ #category : #lookup }
WollokASTVMClass >> methods [
	
	| methodDictionary |
	methods ifNotNil: [ ^ methods ].
	methodDictionary := Dictionary new.
	self classAST methods do: [ :e |
		methodDictionary at: e name value put: e ].
	
	^ methods := methodDictionary
]

{ #category : #accessing }
WollokASTVMClass >> name [
	^ name
]

{ #category : #accessing }
WollokASTVMClass >> name: anObject [
	name := anObject
]

{ #category : #accessing }
WollokASTVMClass >> numberOfSlots [
	
	^ self allVariables size
]

{ #category : #printing }
WollokASTVMClass >> printOn: aStream [

	super printOn: aStream.
	
	aStream
		space;
		nextPut: $(;
		print: name;
		nextPut: $)
		 
]

{ #category : #accessing }
WollokASTVMClass >> superclass [
	
	self name = 'wollok.lang.Object' ifTrue: [ ^ nil ].
	self classAST superclass ifNil: [ 
		^ interpreter resolve: 'wollok.lang.Object' ].
	1halt.
]
