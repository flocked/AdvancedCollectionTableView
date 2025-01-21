# ``OutlineViewDiffableDataSourceSnapshot``

## Overview

## Topics

### Creating a snapshot

- ``init()``
- ``snapshot(of:includingParent:)``
- ``append(_:to:)``

### Accessing items

- ``items`` 
- ``rootItems``
- ``visibleItems``
- ``children(of:recursive:)``

### Getting item metrics

- ``index(of:)``
- ``level(of:)``
- ``parent(of:)``
- ``contains(_:)``
- ``isVisible(_:)``
- ``isDescendant(_:of:)``

### Inserting items

- ``insert(_:before:)-5psi5``
- ``insert(_:before:)-3vdz``
- ``insert(_:after:)-97sm4``
- ``insert(_:after:)-9at59``

### Moving items

- ``move(_:before:)``
- ``move(_:after:)``
- ``move(_:toIndex:of:)``

### Removing items

- ``delete(_:)``
- ``deleteAll()``

### Replacing items

- ``replace(childrenOf:using:)``

### Expanding and collapsing items

- ``isExpanded(_:)``
- ``expand(_:)``
- ``collapse(_:)``

### Configurating group items

- ``groupItems`` 
- ``GroupItemProperties``

### Debugging snapshots

- ``visualDescription()``
