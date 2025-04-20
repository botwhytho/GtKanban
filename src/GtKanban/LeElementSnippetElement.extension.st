Extension { #name : #LeElementSnippetElement }

{ #category : #'*GtKanban' }
LeElementSnippetElement >> updateElementHeightTo: aHeight [
	self isCoderCreated
		ifFalse: [ ^ self ].

	coderElement vExact: aHeight 
]
