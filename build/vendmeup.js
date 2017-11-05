////var Web3 = require('web3');
////if (typeof web3 !== 'undefined') {
////  web3 = new Web3(web3.currentProvider);
////} else {
////  // set the provider you want from Web3.providers
////  web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
////}
//var Web3 = 'web3';
//require([Web3], function(Web3){
//   var web3 = new Web3(Web3.givenProvider || "http://localhost:8545");
//	console.log(web3);
//
////	var balanceWei = web3.eth.getBalance('0x250F688D86856506DB47E447baE4014Eb6D1C19F');
////	console.log(balanceWei);
//	
////	var balance = web3.fromWei(balanceWei, 'ether');
//	var number = web3.eth.blockNumber;
////	console.log(balance);
//	console.log(number);
//})
	

$(document).ready(function () {
//	var Web3 = require('web3');

//	$('.info').append($(balanceWei));
//	$('.info').append($(balance));
//	$('.info').append($(number));
	
	$('.square').each(function (e) {
		$(this).on('click', function () {
			switchDisplay(this);
		});
	});
	
	$('.add-btn').each(function () {
		$(this).on('click', function () {
			var item = $(this).parents('.square');
			var pic = item.find('.img-cont');
			var q = item.find('.clicked');
			var i = q.find('input');
			var quant = i.val();
			if (quant > 0 && quant <= 100) {
				var t = item.find('h4');
				var thing = t.text();
				var lstElem = $('<li class="anItem"><div class="row"><div class="col-xs-5"><p class="quant">&nbsp;&nbsp;x '+ quant +'</p></div><div class="col-xs-6"><p class="itemName">'+ thing +'</p></div></div></li>');
				var lst = $('ul.items');
				lst.append(lstElem);
			}
			$(q).hide();
			$(pic).show();
			i.val('1');
			switchDisplay(item);
		});
	});
	
	$('input').each(function () {
		$(this).on('click', function () {
			var item = $(this).parents('.square');
			var pic = item.find('.img-cont');
			var q = item.find('.clicked');
//			$(q).hide();
//			$(pic).show();
			//i.val('1');
			switchDisplay(item);
		});
		
	});
	
	$('.reset-btn').on('click', function () {
		var lst = $('ul.items');
		lst.empty();
	});
	
	function switchDisplay (curr) {
		var item = $(curr).find('.clicked');
		var pic = $(curr).find('.img-cont');
		var i = item.find('input');
		pic.toggle();
		item.toggle();
//		$(this).off('click', switchDisplay);
	}
});