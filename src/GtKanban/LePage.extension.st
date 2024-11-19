Extension { #name : #LePage }

{ #category : #'*GtKanban' }
LePage >> asPhlowTool [
	<return: #LePhlowTool>
	^ self type asLepiterPagePhlowTool
]

{ #category : #'*GtKanban' }
LePage >> gtKanbanFor: aView [
	<gtView>
	^ aView explicit
		title: 'Kanban';
		priority: 100;
		stencil: [ | lists cards | 
		"BrFrame new
				matchParent;
				addChild: BlBasicExamples new circle"
		lists := self children select: [:each| (each parent isKindOf: LePage) and: [ each isTextSnippet ]].
		cards := lists flatCollect: [:each| each children].
		BlTextElement text: ('Board has ' , lists size asString , ' lists with ' , cards size asString, ' cards total') asRopedText] 
]
