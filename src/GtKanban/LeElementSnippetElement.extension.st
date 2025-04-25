Extension { #name : #LeElementSnippetElement }

{ #category : #'*GtKanban' }
LeElementSnippetElement >> createRefreshContentButton [
	^ BrButton new
		beSmallSize;
		margin: (BlInsets top: 0 right: 0 bottom: 10 left: 10);
		padding: (BlInsets all: 10);
		zIndex: 10;
		aptitude: BrGlamorousButtonWithIconAptitude + BrGlamorousToggleBackgroundAptitude;
		icon: BrGlamorousIcons refresh asElement;
		label: 'Refresh' asString;
		action: [
			self generateDisplayElement.
			self fireEvent: (LeElementSnippetEvaluated new element: self; snippet: self snippet)];
		yourself
]

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
