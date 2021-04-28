Class {
	#name : #WKSemispaceMemory,
	#superclass : #Object,
	#instVars : [
		'trueObject',
		'falseObject',
		'nullObject',
		'interpreter',
		'memory',
		'present',
		'future',
		'nextFree',
		'classTable',
		'nextFreeClass',
		'nextIdentityHash',
		'limit',
		'spaceSize'
	],
	#category : #'WollokVM-Memory'
}

{ #category : #allocating }
WKSemispaceMemory >> allocateSlots: anInteger [ 
	
	| allocatedOop maybeNextFree |
	allocatedOop := nextFree.
	maybeNextFree := nextFree + (anInteger * 8).
	maybeNextFree > limit ifTrue: [ 
		self garbageCollect ].
	nextFree := maybeNextFree.
	^ allocatedOop
]

{ #category : #accessing }
WKSemispaceMemory >> asPharoBoolean: oop [
	
	oop = trueObject ifTrue: [ ^ true ].
	oop = falseObject ifTrue: [ ^ false ].
	self error: 'invalid boolean'
]

{ #category : #converting }
WKSemispaceMemory >> asPharoNumber: oop [
	
	| numerator denominator scale |
	numerator := self pharoRepresentationOfInteger: (self slotAt: oop + 24).
	denominator := self pharoRepresentationOfInteger: (self slotAt: oop + 32).
	scale := self pharoRepresentationOfInteger: (self slotAt: oop + 40).
	
	^ ScaledDecimal newFromNumber: numerator / denominator scale: (scale max: 8)
]

{ #category : #converting }
WKSemispaceMemory >> asPharoString: anOop [ 

	| size |
	size := self slotAt: anOop + 24.

	^ (ByteArray streamContents: [ :stream |
		0 to: size - 1 do: [ :i |
			stream nextPut: (self byteAt: anOop + 32 + i) ] ])
				utf8Decoded
]

{ #category : #visiting }
WKSemispaceMemory >> asWollokBoolean: aPharoBoolean [
	
	^ aPharoBoolean
		ifTrue: [ trueObject ]
		ifFalse: [ falseObject ]
]

{ #category : #literals }
WKSemispaceMemory >> asWollokNumber: aPharoNumber [

	| oop class scaledDecimal |
	scaledDecimal := aPharoNumber asScaledDecimal.
	class := self resolve: 'wollok.lang.Number'.
	
	oop := self allocateSlots: 3 "numerator, denominator, scale" + 2 "for the header and identity hash".
	self haltIf: (classTable indexOf: class) = 0.
	self slotAt: oop put: (classTable indexOf: class).
	self slotAt: oop + 8 put: nextIdentityHash.
	nextIdentityHash := nextIdentityHash + 1.
	self slotAt: oop + 16 put: 3 + 3 "size".
	
	self slotAt: oop + 24 put: (self binaryRepresentationOfInteger: scaledDecimal numerator).
	self slotAt: oop + 32 put: (self binaryRepresentationOfInteger: scaledDecimal denominator).
	self slotAt: oop + 40 put: (self binaryRepresentationOfInteger: scaledDecimal scale).
	^ oop
]

{ #category : #converting }
WKSemispaceMemory >> asWollokString: aString [ 

	| oop class utf8String slotsForBytes |
	utf8String := aString utf8Encoded.
	class := self resolve: 'wollok.lang.String'.
	slotsForBytes := (utf8String size alignedTo: 8) // 8.
	oop := self allocateSlots: 4 "class index, hash, size" + slotsForBytes.

	self slotAt: oop put: (classTable indexOf: class).
		self haltIf: (classTable indexOf: class) = 0.
	self slotAt: oop + 8 put: nextIdentityHash.
	nextIdentityHash := nextIdentityHash + 1.
	self slotAt: oop + 16 put: 3 + 1 +  slotsForBytes "size".
	self slotAt: oop + 24 put: utf8String size.

	utf8String withIndexDo: [ :byte : index |
		self byteAt: oop + 32 + index - 1 put: byte ].
	^ oop
]

{ #category : #integers }
WKSemispaceMemory >> binaryRepresentationOfInteger: anInteger [ 
	
	anInteger >= 0 ifTrue: [ ^ anInteger ].
	
	"If its negative get its 64bit two complement"
	^ (anInteger abs bitXor: 16rFFFFFFFFFFFFFFFF) + 1
]

{ #category : #'memory-access' }
WKSemispaceMemory >> byteAt: address [

	^ memory integerAt: address + 1 size: 1 signed: false.
]

{ #category : #'memory-access' }
WKSemispaceMemory >> byteAt: address put: aValue [

	memory integerAt: address + 1 put: aValue size: 1 signed: false.
]

{ #category : #accessing }
WKSemispaceMemory >> classOf: anOop [
	
	| classIndex |
	classIndex := self slotAt: anOop.
	^ classTable at: classIndex
]

{ #category : #'garbage collection' }
WKSemispaceMemory >> copyAndForward: anOop [ 
	
	| slots newOop |
	newOop := nextFree.
	slots := self slotAt: anOop + 16.

	"Copy the slots"
	0 to: slots - 1 do: [ :i |
		self slotAt: newOop + (i * 8) put: (self slotAt: anOop + (i * 8))
	].

	"Forward the present object to the future object"
	self slotAt: anOop put: self copyMark.
	self slotAt: anOop + 16 put: newOop.

	"Advance the free pointer"
	nextFree := nextFree + (slots * 8).
	
	^ newOop
]

{ #category : #'garbage collection' }
WKSemispaceMemory >> copyMark [

	^ 16rFFFFFFFFFFFFFFFF "Marker?"
]

{ #category : #accessing }
WKSemispaceMemory >> falseObject [
	^ falseObject
]

{ #category : #accessing }
WKSemispaceMemory >> falseObject: anObject [
	falseObject := anObject
]

{ #category : #accessing }
WKSemispaceMemory >> fetchClassOf: anOop [

	^ self slotAt: anOop
]

{ #category : #'object-format' }
WKSemispaceMemory >> fetchInstanceVariable: instanceVariableIndex ofObject: anObject [
	
	^ self slotAt: anObject + (instanceVariableIndex * 8)
]

{ #category : #'garbage collection' }
WKSemispaceMemory >> garbageCollect [
	
	| oldFuture |
	nextFree := future.
	
	trueObject := self copyAndForward: trueObject.
	falseObject := self copyAndForward: falseObject.
	classTable do: [ :e |
		e ifNotNil: [
			e literals do: [ :l | 
				l ifNotNil: [ :el | self copyAndForward: el ] ] ] ].
	
	self scanFuture.

	"Swap!"
	oldFuture := future.
	future := present.
	present := oldFuture.
	limit := present + spaceSize - 1.
]

{ #category : #identity }
WKSemispaceMemory >> identityOf: anOop [

	^ self asWollokNumber: (self slotAt: anOop + 8)
]

{ #category : #initialization }
WKSemispaceMemory >> initializeHeap [

	classTable := Array new: 100.
	nextFreeClass := 1.
	nextIdentityHash := 0.

	"0 is a special address... We start at 8"
	present := 8.
	spaceSize := 1024 * 8.
	memory := ByteArray new: (spaceSize * 2) + present.
	future := spaceSize.
	
	limit := present + spaceSize - 1.
	nextFree := present.

	nullObject := 0 "some invalid reference".	
	trueObject := self instantiateClass: (self resolve: 'wollok.lang.Boolean').
	falseObject := self instantiateClass: (self resolve: 'wollok.lang.Boolean').

]

{ #category : #allocation }
WKSemispaceMemory >> instantiateClass: aClass [

	| oop classIndex |
	oop := self allocateSlots: aClass numberOfSlots + 3 "for the header, identity hash and size".
	classIndex := classTable indexOf: aClass.
	self haltIf: classIndex = 0.
	
	self slotAt: oop put: classIndex.
	self slotAt: oop + 8 put: nextIdentityHash.
	self slotAt: oop + 16 put: 3 + aClass numberOfSlots.
	
	nextIdentityHash := nextIdentityHash + 1.
	1 to: aClass numberOfSlots do: [ :i |
		self storeInstanceVariable: i ofObject: oop withValue: nullObject ].
	^ oop
]

{ #category : #allocation }
WKSemispaceMemory >> instantiateList [

	| class |
	class := self resolve: 'wollok.lang.List'.
	^ self instantiateClass: class
]

{ #category : #accessing }
WKSemispaceMemory >> interpreter [
	^ interpreter
]

{ #category : #accessing }
WKSemispaceMemory >> interpreter: anObject [
	interpreter := anObject
]

{ #category : #testing }
WKSemispaceMemory >> isNull: anInteger [ 
	
	^ anInteger = 0
]

{ #category : #accessing }
WKSemispaceMemory >> nullObject [
	^ nullObject
]

{ #category : #accessing }
WKSemispaceMemory >> nullObject: anObject [
	nullObject := anObject
]

{ #category : #integers }
WKSemispaceMemory >> pharoRepresentationOfInteger: anInteger [ 
	
	"If it is negative, two complement!"
	anInteger highBit = 64
		ifTrue: [ ^ ((anInteger bitXor: 16rFFFFFFFFFFFFFFFF) + 1) negated ].
	
	^ anInteger
]

{ #category : #'name resolution' }
WKSemispaceMemory >> resolve: aString [ 
	
	| class |	
	class := interpreter resolve: aString.
	(classTable includes: class)
		ifTrue: [ ^ class ].
	
	classTable at: nextFreeClass put: class.
	nextFreeClass := nextFreeClass + 1.
	^ class
]

{ #category : #'garbage collection' }
WKSemispaceMemory >> scanFuture [
	
	| scan sizeOfObject |
	scan := future.
	[ scan < nextFree ] whileTrue: [
		self scanObject: scan.
		sizeOfObject := self slotAt: scan + 16.
		scan := scan + (sizeOfObject * 8) ]
]

{ #category : #'garbage collection' }
WKSemispaceMemory >> scanObject: oop [ 

	| pointerSlots reference |
	pointerSlots := (self classOf: oop) numberOfSlots.
	0 to: pointerSlots - 1 do: [ :i |
		reference := self
			fetchInstanceVariable: i + 3 "skip class, identity hash, size"
			ofObject: oop.
		(self isCopied: reference)
			ifFalse: [ reference := self copyAndForward: reference ].
		self
			storeInstanceVariable: i + 3 "skip class, identity hash, size"
			ofObject: oop
			withValue: reference ]

	
]

{ #category : #'memory-access' }
WKSemispaceMemory >> slotAt: address [ 
	"Check allignment"
	self assert: address \\ 8 = 0.
	^ memory integerAt: address + 1 size: 8 signed: false
]

{ #category : #'memory-access' }
WKSemispaceMemory >> slotAt: address put: aValue [
	"Check allignment"
	self assert: address \\ 8 = 0.
	memory integerAt: address + 1 put: aValue size: 8 signed: false.
]

{ #category : #'object-format' }
WKSemispaceMemory >> storeInstanceVariable: anIndex ofObject: anOop withValue: aValue [ 
	
	self slotAt: anOop + (2 + anIndex * 8) put: aValue
]

{ #category : #accessing }
WKSemispaceMemory >> trueObject [
	^ trueObject
]

{ #category : #accessing }
WKSemispaceMemory >> trueObject: anObject [
	trueObject := anObject
]

{ #category : #accessing }
WKSemispaceMemory >> wollokClassName: anOop [

	^ (self classOf: anOop) name
]
