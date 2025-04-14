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
	database addPage: LeExampleCustomPageType samplePage.
	self assert: database pages size = 1.
	^ database
]
