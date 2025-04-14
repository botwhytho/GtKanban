Extension { #name : #LePage }

{ #category : #'*GtKanban' }
LePage >> asPhlowTool [
	<return: #LePhlowTool>
	^ self type asLepiterPagePhlowTool
]

{ #category : #'*GtKanban' }
LePage >> asPreviewElement [
	^ self type asPreviewElement
]

{ #category : #'*GtKanban' }
LePage >> gtDefaultInspectorTool [
 ^ self asPhlowTool
]

{ #category : #'*GtKanban' }
LePage >> gtSpotterActDefaultFrom: aSpotterElement [
	| pageTool toolElement |

	pageTool := self asPhlowTool.
	toolElement := pageTool asElementDo: [ :e | e ].
	(GtPager 
		openWrappedOn: toolElement 
		title: self tabLabel 
		from: aSpotterElement) maximized
]
