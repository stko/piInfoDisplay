'use strict';

var settings = {}

function init() {
	if (typeof (Storage) !== "undefined") {
		settings = JSON.parse(localStorage.getItem("piInfoDisplay"))
		if (settings) {
			document.greenform.text.value = settings.greentext
			document.greenform.fontsize.value = settings.greenfontsize
			document.redform.text.value = settings.redtext
			document.redform.fontsize.value = settings.redfontsize
		}else{
			settings = {}
		}
	}
}

function doSend() {
		if (typeof (Storage) !== "undefined") {
			settings.greentext = document.greenform.text.value
			settings.greenfontsize = document.greenform.fontsize.value
			settings.redtext = document.redform.text.value
			settings.redfontsize = document.redform.fontsize.value
			localStorage.setItem( "piInfoDisplay" , JSON.stringify( settings ) )
		}
	return true
}

function doClear() {
		if (typeof (Storage) !== "undefined") {
			localStorage.removeItem("piInfoDisplay");
		}
	return true
}

window.addEventListener("load", init, false);


