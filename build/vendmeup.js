$(document).ready(function () {
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