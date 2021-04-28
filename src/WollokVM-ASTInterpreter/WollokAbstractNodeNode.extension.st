Extension { #name : #WollokAbstractNodeNode }

{ #category : #'*WollokVM-ASTInterpreter' }
WollokAbstractNodeNode >> gtInspectorSourceCodeIn: composite [
	<gtInspectorPresentationOrder: 30> 

	^ composite text
		title: [ 'Source code' translated ];
		display: [ self completeSource ];
		initialize: [ :presentation | 
			presentation selectionInterval: self sourceInterval ];
		when: [ self source notNil ]
]

{ #category : #'*WollokVM-ASTInterpreter' }
WollokAbstractNodeNode >> gtInspectorTreeIn: composite [
	<gtInspectorPresentationOrder: 30> 
	^ (GTSimpleSmaCCTreeBrowser new treeIn: composite)
		title: [ 'Tree' translated ]
]
