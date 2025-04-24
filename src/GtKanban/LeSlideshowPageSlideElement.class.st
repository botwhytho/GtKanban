Class {
	#name : #LeSlideshowPageSlideElement,
	#superclass : #BrFrame,
	#instVars : [
		'snippet'
	],
	#category : #'GtKanban-UI'
}

{ #category : #initialization }
LeSlideshowPageSlideElement class >> forSnippet: aLeElementSnippet [
	^ self basicNew
		snippet: aLeElementSnippet;
		initialize
]

{ #category : #initialization }
LeSlideshowPageSlideElement >> initialize [
	super initialize.
	self
		matchParent;
		addAptitude: BrShadowAptitude new
				+ (BrGlamorousSlideExteriorAptitude new
						backgroundPaint: Color white;
						borderPaint: Color transparent);
		addChild: (self snippet
				elementHeight: 200;
				codeHeight: 200;
				asSlideshowPageElement)
]

{ #category : #accessing }
LeSlideshowPageSlideElement >> snippet [
	^ snippet
]

{ #category : #accessing }
LeSlideshowPageSlideElement >> snippet: aLeElementSnippet [
	snippet := aLeElementSnippet
]
