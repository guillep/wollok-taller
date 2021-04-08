Class {
	#name : #WollokVMObject,
	#superclass : #Object,
	#instVars : [
		'wollokClass',
		'interpreter',
		'instanceVariables'
	],
	#category : #'WollokVM-Interpreter'
}

{ #category : #UI }
WollokVMObject >> gtInspectorVariablesIn: composite [
	<gtInspectorPresentationOrder: 1> 

	^ composite fastTable
		title: 'Wollok Inspector';
		display: [ self valueCollection ];
		column: 'Name' evaluated: [ :each | GTObjectPrinter asTruncatedTextFrom: each key ];
		column: 'Value' evaluated: [ :each | GTObjectPrinter asTruncatedTextFrom: each value ];
		send: [ :selection | 
			selection
				ifNil: [ nil ]
				ifNotNil: [ selection value ] ]
]

{ #category : #accessing }
WollokVMObject >> initialize [

	super initialize.
	instanceVariables := Dictionary new.
]

{ #category : #accessing }
WollokVMObject >> instanceVariablesValues [

	^ instanceVariables values
]

{ #category : #accessing }
WollokVMObject >> interpreter [
	^ interpreter
]

{ #category : #accessing }
WollokVMObject >> interpreter: anObject [
	interpreter := anObject
]

{ #category : #printing }
WollokVMObject >> printOn: aStream [

	super printOn: aStream.
	
	aStream
		space;
		nextPut: $(;
		print: wollokClass;
		nextPut: $)

		 
]

{ #category : #accessing }
WollokVMObject >> valueCollection [

	^ { 'self' -> self }, 
			(self wollokClass allVariables
				with: self instanceVariablesValues
				collect: [ :n :v | n key variable name value -> v ])
]

{ #category : #accessing }
WollokVMObject >> wollokClass [
	^ wollokClass
]

{ #category : #accessing }
WollokVMObject >> wollokClass: anObject [
	wollokClass := anObject
]

{ #category : #accessing }
WollokVMObject >> wollokClassName [
	
	^ wollokClass name
]

{ #category : #native }
WollokVMObject >> wollokIdentity [
	
	self subclassResponsibility
]

{ #category : #'object-access' }
WollokVMObject >> wollokInstanceVariableAt: anIndex [ 
	
	^ instanceVariables at: anIndex ifAbsent: [ interpreter nullObject ]
]

{ #category : #'object-access' }
WollokVMObject >> wollokInstanceVariableAt: anIndex put: aValue [
	
	instanceVariables at: anIndex put: aValue
]
