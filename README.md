grapp-iron-ajax
===============

A Polymer iron-ajax web component with some customizations.
See https://elements.polymer-project.org/elements/iron-ajax for more information about the base element.

Compatible with Polymer 1.0+

Extends
-------

  * [**iron-ajax**](https://elements.polymer-project.org/elements/iron-ajax)

Currently with Polymer 1.0 we cannot extend custom elements. So in this version if have copied the
code from the iron-ajax element into my grapp-iron-ajax element.

Modifications:

* Set the 'Accept' header to 'application/json' for JSON requests
* Add a 'token' property and set the 'Authorization' header to this token if it is specified
* Set lastResponse to the response data in case of a request error
