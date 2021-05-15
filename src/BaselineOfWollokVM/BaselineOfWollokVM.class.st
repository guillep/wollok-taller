Class {
	#name : #BaselineOfWollokVM,
	#superclass : #BaselineOf,
	#category : #BaselineOfWollokVM
}

{ #category : #baselines }
BaselineOfWollokVM >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ 
			
			spec
				baseline: 'SmaCC' 
				with: [
					spec
						loads: 'Runtime';
						repository: 'github://j-brant/Smacc:7aafca9' ].
			
			spec
				package: 'Wollok-Parser' with: [ spec requires: 'SmaCC' ];
				package: 'WollokVM-Memory';
				package: 'WollokVM-ASTInterpreter' 
					with: [ spec requires: #('Wollok-Parser' 'WollokVM-BytecodeInterpreter') ];
				package: 'WollokVM-BytecodeCompiler' 
					with: [ spec requires: #('Wollok-Parser') ];
				package: 'WollokVM-BytecodeInterpreter' 
					with: [ spec requires: #( 'WollokVM-BytecodeCompiler' 'Wollok-Parser') ];
				package: 'WollokVM-Tests' 
					with: [ spec requires: #(
							'WollokVM-BytecodeInterpreter'
							'WollokVM-ASTInterpreter'
							'WollokVM-Memory') ];
				package: 'Wollok-UI' 
					with: [ spec requires: #('WollokVM-ASTInterpreter') ]
			]
]
