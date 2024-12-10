
## Installation

```st
[ EpMonitor current
	disableDuring: [ Metacello new
			baseline: 'GtKanban';
			repository: 'github://botwhytho/GtKanban:main/src';
			onConflictUseLoaded;
			load ] ] forkAt: 29 named: #GtKanban
```

## Load Lepiter

After installing with Metacello, you will be able to execute

```
#BaselineOfGtKanban asClass loadLepiter
```
