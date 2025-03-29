Extension { #name : #LePage }

{ #category : #'*GtKanban' }
LePage >> asPhlowTool [
	<return: #LePhlowTool>
	^ self type asLepiterPagePhlowTool
]

{ #category : #'*GtKanban' }
LePage >> gtDefaultInspectorTool [
 ^ self asPhlowTool
]
