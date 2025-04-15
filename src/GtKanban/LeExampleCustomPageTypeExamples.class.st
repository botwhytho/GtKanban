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
	(database pagesByType at: LeExampleCustomPageType) removeAll.
	(database instVarNamed: #pagesByUuid) removeAll.
	database reload.
	database monitor reloadPage: database pages first.
	^ database
]
