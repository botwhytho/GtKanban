Class {
	#name : #LeExampleCustomPageTypeExamples,
	#superclass : #Object,
	#category : #'GtKanban-Examples'
}

{ #category : #example }
LeExampleCustomPageTypeExamples >> databaseWithSamplePage [
	<gtExample>
	| database |
	database := LeDatabaseWithLocalMonitorExamples new databaseWithMonitor.
	database monitor
		storage: (LeMockLocalJsonV4StorageWithMissingDeserializers new
				removeDeserializers: {LeExampleCustomPageType}).
	database addPage: LeExampleCustomPageType samplePage.
	self assert: database pages size = 1.
	^ database
]

{ #category : #example }
LeExampleCustomPageTypeExamples >> deregisterCustomPageTypeAndReloadDatabase [
	<gtExample>
	| database |
	database := self databaseWithSamplePage.
	database monitor reloadPage: database pages first.
	self
		assert: (database pages first type isKindOf: LeUnknownNamedPageType)
		description: 'A page with a title and an unknown page type most be loaded into the database as a page with type `LeUnknownNamedPageType`'.
	^ database
]
