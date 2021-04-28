Class {
	#name : #WollowVMInterpreterTemporaryVariablesTest,
	#superclass : #AbstractWollokVMInterpreterTest,
	#category : #'WollokVM-Tests-4.Stack'
}

{ #category : #running }
WollowVMInterpreterTemporaryVariablesTest >> setUp [ 

	super setUp.
	
	interpreter addBindingOfClass: 'MyClass' fromString: '
class	MyClass {  
	method doSomething(){
		var a = 1
		return a + 2
	}
}
'.
]

{ #category : #tests }
WollowVMInterpreterTemporaryVariablesTest >> testAccessToLocalVariablesReturnsCorrectValue [

	| anObject |
	anObject := self interpretExpression: 'new MyClass().doSomething()'.
	
	self assert: (interpreter memory asPharoNumber: anObject) equals: 3
]
