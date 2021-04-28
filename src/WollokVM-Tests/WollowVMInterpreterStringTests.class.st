Class {
	#name : #WollowVMInterpreterStringTests,
	#superclass : #AbstractWollokVMInterpreterTest,
	#category : #'WollokVM-Tests-1.Basic Types'
}

{ #category : #tests }
WollowVMInterpreterStringTests >> testConcatenationOfStringsHasCorrectValue [

	| object |
	
	object := self interpretExpression: '"abc" + "123"'.
	self assert: (interpreter memory asPharoString: object) equals: 'abc123'
]

{ #category : #tests }
WollowVMInterpreterStringTests >> testConcatenationOfStringsIsAWollokString [

	| object |
	
	object := self interpretExpression: '"abc" + "123"'.
	self assert: (interpreter wollokClassName: object) equals: 'wollok.lang.String'
]

{ #category : #tests }
WollowVMInterpreterStringTests >> testConstantStringHasCorrectValue [

	| object |
	
	object := self interpretExpression: '"abc"'.
	self assert: (interpreter memory asPharoString: object) equals: 'abc'
]

{ #category : #tests }
WollowVMInterpreterStringTests >> testConstantStringIsAWollokString [

	| object |
	
	object := self interpretExpression: '"abc"'.
	self assert: (interpreter wollokClassName: object) equals: 'wollok.lang.String'
]
