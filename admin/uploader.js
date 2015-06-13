window.addEventListener("load", function() {
	var inputs = document.querySelectorAll("input[type='text']");
	Array.prototype.forEach.call(inputs, function(input) {
		input.scrollLeft = input.scrollWidth; //Scroll to end to see size
	});
});