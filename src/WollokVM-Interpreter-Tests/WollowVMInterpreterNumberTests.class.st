Class {
	#name : #WollowVMInterpreterNumberTests,
	#superclass : #AbstractWollokVMInterpreterTest,
	#category : #'WollokVM-Interpreter-Tests-1.Basic Types'
}

{ #category : #'tests - operations' }
WollowVMInterpreterNumberTests >> testComparingGreaterThanTwoNumbersHasCorrectAnswer [

	| maybeANumber |

	maybeANumber := self interpretExpression: '1 > 2.73'.

	self assert: (interpreter isFalse: maybeANumber)
]

{ #category : #'tests - operations' }
WollowVMInterpreterNumberTests >> testComparingLowerThanTwoNumbersHasCorrectAnswer [

	| maybeANumber |

	maybeANumber := self interpretExpression: '1 < 2.73'.

	self assert: (interpreter isTrue: maybeANumber)
]

{ #category : #'tests - operations' }
WollowVMInterpreterNumberTests >> testComparingLowerThanTwoNumbersIsAWollokBoolean [

	| maybeANumber |

	maybeANumber := self interpretExpression: '1 < 2.73'.

	self assert: (interpreter wollokClassName: maybeANumber) equals: 'wollok.lang.Boolean'
]

{ #category : #'tests - operations' }
WollowVMInterpreterNumberTests >> testComparingTwoNumbersIsAWollokBoolean [

	| maybeANumber |

	maybeANumber := self interpretExpression: '1 > 2.73'.

	self assert: (interpreter wollokClassName: maybeANumber) equals: 'wollok.lang.Boolean'
]

{ #category : #'tests - operations' }
WollowVMInterpreterNumberTests >> testDifferenceOfTwoNumbersWithDecimalsHasCorrectValue [

	| maybeANumber |

	maybeANumber := self interpretExpression: '1 - 2.73'.

	self assert: (interpreter memory asPharoNumber: maybeANumber) equals: 1 - 2.73
]

{ #category : #'tests - operations' }
WollowVMInterpreterNumberTests >> testDifferenceOfTwoNumbersWithDecimalsIsAWollokNumber [

	| maybeANumber |

	maybeANumber := self interpretExpression: '1 - 2.73'.

	self assert: (interpreter wollokClassName: maybeANumber) equals: 'wollok.lang.Number'
]

{ #category : #'tests - operations' }
WollowVMInterpreterNumberTests >> testDivisionOfTwoNumbersWithDecimalsIsAWollokNumber [

	| maybeANumber |

	maybeANumber := self interpretExpression: '1 / 2.73'.

	self assert: (interpreter wollokClassName: maybeANumber) equals: 'wollok.lang.Number'
]

{ #category : #'tests - constants' }
WollowVMInterpreterNumberTests >> testLiteralDecimalNumberIsAWollokNumber [

	| maybeANumber |

	maybeANumber := self interpretExpression: '1.73'.

	self assert: (interpreter wollokClassName: maybeANumber) equals: 'wollok.lang.Number'
]

{ #category : #'tests - constants' }
WollowVMInterpreterNumberTests >> testLiteralNegativeDecimalNumberIsAWollokNumber [

	| maybeANumber |

	maybeANumber := self interpretExpression: '-1.73'.

	self assert: (interpreter wollokClassName: maybeANumber) equals: 'wollok.lang.Number'
]

{ #category : #'tests - constants' }
WollowVMInterpreterNumberTests >> testLiteralNegativeNumberIsAWollokNumber [

	| maybeANumber |

	maybeANumber := self interpretExpression: '-2'.

	self assert: (interpreter wollokClassName: maybeANumber) equals: 'wollok.lang.Number'
]

{ #category : #'tests - constants' }
WollowVMInterpreterNumberTests >> testLiteralNumberIsAWollokNumber [

	| maybeANumber |

	maybeANumber := self interpretExpression: '1'.

	self assert: (interpreter wollokClassName: maybeANumber) equals: 'wollok.lang.Number'
]

{ #category : #'tests - constants' }
WollowVMInterpreterNumberTests >> testLiteralNumberIsCorrectNumber [

	| maybeANumber |

	maybeANumber := self interpretExpression: '1'.

	self assert: (interpreter memory asPharoNumber: maybeANumber) equals: 1
]

{ #category : #'tests - operations' }
WollowVMInterpreterNumberTests >> testModOfTwoNumbersWithDecimalsIsAWollokNumber [

	| maybeANumber |

	maybeANumber := self interpretExpression: '1 % 2.73'.

	self assert: (interpreter wollokClassName: maybeANumber) equals: 'wollok.lang.Number'
]

{ #category : #'tests - operations' }
WollowVMInterpreterNumberTests >> testMultiplicationOfTwoNumbersWithDecimalsIsAWollokNumber [

	| maybeANumber |

	maybeANumber := self interpretExpression: '1 * 2.73'.

	self assert: (interpreter wollokClassName: maybeANumber) equals: 'wollok.lang.Number'
]

{ #category : #'tests - operations' }
WollowVMInterpreterNumberTests >> testSumOfTwoNumbersHasCorrectValue [

	| maybeANumber |

	maybeANumber := self interpretExpression: '1 + 2'.

	self assert: (interpreter memory asPharoNumber: maybeANumber) equals: 3
]

{ #category : #'tests - operations' }
WollowVMInterpreterNumberTests >> testSumOfTwoNumbersIsAWollokNumber [

	| maybeANumber |

	maybeANumber := self interpretExpression: '1 + 2'.

	self assert: (interpreter wollokClassName: maybeANumber) equals: 'wollok.lang.Number'
]

{ #category : #'tests - operations' }
WollowVMInterpreterNumberTests >> testSumOfTwoNumbersWithDecimalsHasCorrectValue [

	| maybeANumber |

	maybeANumber := self interpretExpression: '1 + 2.73'.

	self assert: (interpreter memory asPharoNumber: maybeANumber) equals: 1 + 2.73
]

{ #category : #'tests - operations' }
WollowVMInterpreterNumberTests >> testSumOfTwoNumbersWithDecimalsIsAWollokNumber [

	| maybeANumber |

	maybeANumber := self interpretExpression: '1 + 2.73'.

	self assert: (interpreter wollokClassName: maybeANumber) equals: 'wollok.lang.Number'
]

{ #category : #'tests - operations' }
WollowVMInterpreterNumberTests >> testTruncateReturnsCorrectValue [

	| returnValue |
	returnValue := self interpretExpression: '1.223445.truncate(3)'.
	self assert: (interpreter memory asPharoNumber: returnValue) asString equals: 1.223 asScaledDecimal asString.
	
	returnValue := self interpretExpression: '14.6165.truncate(3)'.
	self assert: (interpreter memory asPharoNumber: returnValue) asString equals: 14.616 asScaledDecimal asString.
	
	returnValue := self interpretExpression: '-14.6165.truncate(3)'.
	self assert: (interpreter memory asPharoNumber: returnValue) asString equals: -14.616 asScaledDecimal asString.
	
	returnValue := self interpretExpression: '5.truncate(3)'.
	self assert: (interpreter memory asPharoNumber: returnValue) asString equals: (5 asScaledDecimal: 8) asString.
]
