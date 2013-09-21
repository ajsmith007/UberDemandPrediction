console.log('Load script.js');

var theQuotes; // the Model :: Model-View Controller

function showQuote(quote){
	console.log(quote.ticker);
	//theQuotes = quote;
	$('#result').html(quote.ticker)
}

function handleClick(e){
	$.ajax('/',{
		type: 'GET',
		data: {
			fmt: 'json'
		}
	});
}

$(document).ready(function(){
	//$('#getitbutton').on('click', handleClick);
	handleClick();
});