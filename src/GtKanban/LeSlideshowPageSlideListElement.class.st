Class {
	#name : #LeSlideshowPageSlideListElement,
	#superclass : #LeSlideshowPageSlideElement,
	#category : #'GtKanban-UI'
}

{ #category : #initialization }
LeSlideshowPageSlideListElement >> initialize [
	super initialize.
	self
		matchParent;
		preventChildrenMouseEvents;
		when: BlClickEvent
			do: [ :anEvent | 
				| clickedSnipet expandedSnippet parentTool |
				anEvent consumed: true.
				self allowChildrenMouseEvents.
				parentTool := anEvent currentTarget
						allParentsDetect: [ :anElement | anElement id asSymbol = #slidesDetailTool ]
						ifFound: #yourself
						ifNone: [ nil ].
				clickedSnipet := (anEvent currentTarget query // LeElementSnippetElement)
						result first snippetViewModel snippetModel.
				expandedSnippet := (parentTool children second query
						// LeElementSnippetElement) result first snippetViewModel snippetModel.
				parentTool
					replaceChild: parentTool children second
					with: (self slideDetailElementFor: clickedSnipet inParentTool: parentTool).
				parentTool
					enqueueTask: [ (parentTool children second query // #'source-coder--editor') result first
							requestFocus ] asBlTask	"]" ];
		when: BlMouseLeaveEvent
			do: [ :anEvent | 
				anEvent consumed: true.
				self hasFocus ifTrue: [ self loseFocus ].
				self preventChildrenMouseEvents ].
	self children first hideCoder
]

{ #category : #ui }
LeSlideshowPageSlideListElement >> slideDetailElementFor: aSnippet inParentTool: parentTool [
	| aFrame |
	aFrame := BrFrame new
			padding: (BlInsets all: 10);
			matchParent;
			constraintsDo: [ :c | c linear weight: 4 ];
			addAptitude: BrShadowAptitude new
					+ (BrGlamorousSlideExteriorAptitude new
							backgroundPaint: Color white;
							borderPaint: Color transparent).
	self onSnippetRemoved: aFrame.
	aFrame
		enqueueTask: [ | aLeSnippetContainerElement |
			aLeSnippetContainerElement := aSnippet asSlideshowPageElement.
			aLeSnippetContainerElement children first
				updateCoderHeightTo: parentTool extent y * 0.25;
				updateElementHeightTo: parentTool extent y * 0.65.
			aFrame
				addChild: (BrFrame new
						matchParent;
						addChild: aLeSnippetContainerElement) ] asBlTask.
	^ aFrame
]
