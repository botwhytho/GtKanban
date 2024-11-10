Extension { #name : #LePageType }

{ #category : #'*GtKanban' }
LePageType >> asLepiterPagePhlowTool [
	^ (self respondsTo: #customPhlowTool) ifTrue: [ self customPage ] ifFalse: [ self defaultPage ]
]

{ #category : #'*GtKanban' }
LePageType >> customPage [
	^ GtPhlowCompositeTool new
		addTool: (self perform: #customPhlowTool);
		addTool: (LePagePhlowTool new
				shouldFocusFirstSnippet: true;
				page: self page);
		addTool: (GtPhlowTool default object: self page)
]

{ #category : #'*GtKanban' }
LePageType >> defaultPage [
	^ GtPhlowCompositeTool new
		addTool: (LePagePhlowTool new
				shouldFocusFirstSnippet: true;
				page: self page);
		addTool: (GtPhlowTool default object: self page)
]
