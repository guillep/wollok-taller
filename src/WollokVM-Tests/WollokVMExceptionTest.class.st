Class {
	#name : #WollokVMExceptionTest,
	#superclass : #AbstractWollokVMInterpreterTest,
	#category : #'WollokVM-Tests-7.Exceptions'
}

{ #category : #tests }
WollokVMExceptionTest >> testAllObjectsUnderstandErrorMessage [

	[self interpretExpression: 'throw new Exception()'] 
		on: WollokError 
		do: [ :e |
			self assert: e wollokException isNotNil.
			^ self
		].
		
	self fail
]

{ #category : #tests }
WollokVMExceptionTest >> testFinallyExecutesWithException [

	| returnObject |
	interpreter addBindingOfClass: 'MyFaillingClass' fromString: '
class MyFaillingClass { 
	var a = 7
	
	method boom(){
		throw new Exception()
	}
	
	method noboom() {  }
}'.

	returnObject := self interpretExpression: '
		var x = 6
		try {new MyFaillingClass().boom()}
			catch e:Exception { x = 7}
			then always { x = 99}
		x'.
		
	self assert: (interpreter memory asPharoNumber: returnObject) equals: 99

]

{ #category : #tests }
WollokVMExceptionTest >> testFinallyExecutesWithoutException [

	| returnObject |
	interpreter addBindingOfClass: 'MyFaillingClass' fromString: '
class MyFaillingClass { 
	var a = 7
	
	method boom(){
		self.error("Boom!")
	}
	
	method noboom() {  }
}'.

	returnObject := self interpretExpression: '
		var x = 6
		try {new MyFaillingClass().noboom()}
			catch e:Exception {return 7}
			then always { x = 99}
		x'.
		
	self assert: (interpreter memory asPharoNumber: returnObject) equals: 99

]

{ #category : #tests }
WollokVMExceptionTest >> testMethodCanThrowException [

	interpreter addBindingOfClass: 'MyFaillingClass' fromString: '
class MyFaillingClass { 
	var a = 7
	
	method boom(){
		throw new Exception()
	}
}'.

	[self interpretExpression: 'new MyFaillingClass().boom()'] 
		on: WollokError 
		do: [ :e |
			self assert: e wollokException isNotNil.
			^ self
		].
	

]

{ #category : #tests }
WollokVMExceptionTest >> testTryCatchesTheException [

	| returnObject |
	interpreter addBindingOfClass: 'MyFaillingClass' fromString: '
class MyFaillingClass { 
	var a = 7
	
	method boom(){
		throw new Exception()
	}
}'.

	returnObject := self interpretExpression: 'try {new MyFaillingClass().boom()}
		catch e:Exception {return 7}'.
		
	self assert: (interpreter memory asPharoNumber: returnObject) equals: 7
	

]

{ #category : #tests }
WollokVMExceptionTest >> testWollokExceptionReachingEndOfStackPopsAsAWollokError [

	[self interpretExpression: 'throw new Exception()'] 
		on: WollokError 
		do: [ :e |
			self assert: e wollokException isNotNil.
			^ self
		].
		
	self fail
]
