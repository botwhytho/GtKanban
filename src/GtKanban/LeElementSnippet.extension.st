Extension { #name : #LeElementSnippet }

{ #category : #'*GtKanban' }
LeElementSnippet >> asSlideshowPageElement [
	| viewModel snippetElement |
	viewModel := self asSnippetViewModel.
	snippetElement := (LeSlideshowPageSnippetView new
			snippetElementClass: viewModel snippetElementClass)
			beFullWidth;
			needsContentDecorationBar: false.
	snippetElement snippetViewModel: viewModel.
	snippetElement padding: (BlInsets all: 10).
	^ snippetElement
]
