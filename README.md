MapTouchInterception
======================

A sample project exhibiting problems adding a tap gesture recognizer to a MKMapView, and programmatically selecting annotations.

### Goal

Determine if a touch on a MKMapView hits one of the overlays. If it does, add an annotation and callout displaying from the touch location.

### Problem

MKMapView uses a MKVariableDelayTapRecognizer, which delays handling touch events on the map view a surprising long time. After handling a tap that intercepts an overlay, a new annotaiton is added and selected to display the callout, but the MKMapView automatically deselects the new annotation immediately after. To avoid this, the new annotation selection can be delayed by about 0.4 seconds, but that is a ridiculous hack and user experience.