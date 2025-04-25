Extension { #name : #LeElementSnippetElement }

{ #category : #'*GtKanban' }
LeElementSnippetElement >> onCodeEvaluated: anEvaluatedAnnouncement [
	(anEvaluatedAnnouncement requesterObject isRequestedByElementOrItsChild: self)
		ifFalse: [ ^ self ].

	self setElement: [ anEvaluatedAnnouncement evaluationResult value ].
	self
		fireEvent: (LeSnippetEvaluated new
				element: self;
				snippet: self snippet;
				evaluationResult: anEvaluatedAnnouncement evaluationResult)
]

{ #category : #'*GtKanban' }
LeElementSnippetElement >> updateElementHeightTo: aHeight [
	self isCoderCreated
		ifFalse: [ ^ self ].

	elementContainer vExact: aHeight 
]
