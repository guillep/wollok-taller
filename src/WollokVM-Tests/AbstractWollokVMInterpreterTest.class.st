Class {
	#name : #AbstractWollokVMInterpreterTest,
	#superclass : #ParametrizedTestCase,
	#instVars : [
		'interpreter',
		'memory',
		'interpreterClass',
		'memoryClass'
	],
	#category : #'WollokVM-Tests-Base'
}

{ #category : #testing }
AbstractWollokVMInterpreterTest class >> isAbstract [ 

	^ self = AbstractWollokVMInterpreterTest
]

{ #category : #'building suites' }
AbstractWollokVMInterpreterTest class >> testParameters [

	^ ParametrizedTestMatrix new
		forSelector: #interpreterClass addOptions: { WollokASTInterpreter . WollokBytecodeInterpreter };
		forSelector: #memoryClass addOptions: { WKPharoHeapMemory . WKSemispaceMemory };
		yourself
]

{ #category : #running }
AbstractWollokVMInterpreterTest >> interpretExpression: aString [

	^ interpreter interpretProgram: (interpreter compile: (self wrapForREPL: aString))
]

{ #category : #accessing }
AbstractWollokVMInterpreterTest >> interpreter [
	^ interpreter
]

{ #category : #accessing }
AbstractWollokVMInterpreterTest >> interpreter: anObject [
	interpreter := anObject
]

{ #category : #accessing }
AbstractWollokVMInterpreterTest >> interpreterClass [
	^ interpreterClass
]

{ #category : #accessing }
AbstractWollokVMInterpreterTest >> interpreterClass: anObject [
	interpreterClass := anObject
]

{ #category : #accessing }
AbstractWollokVMInterpreterTest >> memory [
	^ memory
]

{ #category : #accessing }
AbstractWollokVMInterpreterTest >> memory: anObject [
	memory := anObject
]

{ #category : #accessing }
AbstractWollokVMInterpreterTest >> memoryClass [
	^ memoryClass
]

{ #category : #accessing }
AbstractWollokVMInterpreterTest >> memoryClass: anObject [
	memoryClass := anObject
]

{ #category : #parsing }
AbstractWollokVMInterpreterTest >> parse: aString [ 
	
	| anAST |
	anAST := WollokParser parse: aString.
	anAST attributeNamed: #source put: aString.

	^ anAST
]

{ #category : #running }
AbstractWollokVMInterpreterTest >> setUp [

	super setUp.
	interpreter := interpreterClass new.
	memory := memoryClass new.
	interpreter memory: memory
]

{ #category : #utils }
AbstractWollokVMInterpreterTest >> wrapForREPL: aString [

	^ String streamContents: [ :aStream | 
			aStream 
				nextPutAll:	'program testExpression {'; cr;
				tab; nextPutAll: aString; cr;
	 			nextPutAll: '}'
		 ]
]
