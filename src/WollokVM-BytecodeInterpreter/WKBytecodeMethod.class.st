Class {
	#name : #WKBytecodeMethod,
	#superclass : #Object,
	#instVars : [
		'selector',
		'isNative',
		'methodBytecode',
		'numberOfParameters',
		'bytecodeClass'
	],
	#category : #'WollokVM-BytecodeInterpreter'
}

{ #category : #accessing }
WKBytecodeMethod >> bytecode [
	
	^ methodBytecode
]

{ #category : #accessing }
WKBytecodeMethod >> bytecodeClass [
	^ bytecodeClass
]

{ #category : #accessing }
WKBytecodeMethod >> bytecodeClass: anObject [
	bytecodeClass := anObject
]

{ #category : #accessing }
WKBytecodeMethod >> isNative [
	^ isNative
]

{ #category : #accessing }
WKBytecodeMethod >> isNative: anObject [
	isNative := anObject
]

{ #category : #accessing }
WKBytecodeMethod >> literalAt: anInteger [
	
	^ bytecodeClass literalAt: anInteger
]

{ #category : #accessing }
WKBytecodeMethod >> methodBytecode: bytecode [ 
	
	methodBytecode := bytecode
]

{ #category : #accessing }
WKBytecodeMethod >> numberOfParameters [
	
	^ numberOfParameters
]

{ #category : #accessing }
WKBytecodeMethod >> numberOfParameters: anObject [
	numberOfParameters := anObject
]

{ #category : #accessing }
WKBytecodeMethod >> selector [
	^ selector
]

{ #category : #accessing }
WKBytecodeMethod >> selector: anObject [
	selector := anObject
]
