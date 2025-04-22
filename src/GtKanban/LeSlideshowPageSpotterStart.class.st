Class {
	#name : #LeSlideshowPageSpotterStart,
	#superclass : #Object,
	#category : #'GtKanban-Spotter'
}

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
			collectMenuItems" "{LeContextMenuItemSpecification new title: 'Element Snippet'; snippetClass: LeElementSnippet}"
			LeSlideshowPageElement slideTemplates
			 ];
		itemName: #key;
		previewElement: [:each | each value create ];
		filterBySubstring;
		withoutCategoryAction;
		withoutItemsLimit;
		wantsToDisplayOnEmptyQuery: true
]
