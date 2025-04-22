Class {
	#name : #LeSlideshowPageSpotterStart,
	#superclass : #Object,
	#instVars : [
		'database'
	],
	#category : #'GtKanban-Spotter'
}

{ #category : #accessing }
LeSlideshowPageSpotterStart >> database [
	^ database
]

{ #category : #accessing }
LeSlideshowPageSpotterStart >> database: anObject [
	database := anObject
]

{ #category : #printing }
LeSlideshowPageSpotterStart >> gtDisplayOn: aStream [
	aStream nextPutAll: 'Add new snippet'
]

{ #category : #searching }
LeSlideshowPageSpotterStart >> gtNewSnippetFor: aSearch [
	<gtSearch>
	
	^ aSearch list
		title: 'Add Slide to Page';
		priority: 1;
		items: [" LeContextMenuSnippetItemsCollector new 
			collectMenuItems" {LeContextMenuItemSpecification new title: 'Element Snippet'; snippetClass: LeElementSnippet} ];
		itemName: #title;
		filterBySubstring;
		withoutCategoryAction;
		withoutItemsLimit;
		wantsToDisplayOnEmptyQuery: true
]
