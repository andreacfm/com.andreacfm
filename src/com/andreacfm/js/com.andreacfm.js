if(typeof(com) == 'undefined'){
	com = new Object();
}
	
com.andreacfm = {};

/**
 * Clone
 * @param {Object} object
 */	
com.andreacfm.Clone = function(object) {
    function F() {}
	F.prototype = object;
	return new F;
}


com.andreacfm.form = {};	

/**
 * Require jQuery
 * @param {Object} elId
 * @param {Object} data
 * @param {Object} pk
 * @param {Object} label
 * @param {Object} joinId
 * @param {Object} text
 */
com.andreacfm.form.Combo  = function(elId,data,pk,label,joinId,text,proxy,selected,returnAll){

	var _elId = elId;
	var _data = data;
	var _joinId = joinId;
	var _pk = pk;
	var _label = label;		
	var _text = text || 'Seleziona ...';
	var _proxy = proxy || {};
	var _selected = selected;
	var _returnAll = returnAll || false;
	
	_proxy.status = false;
	_proxy.type = _proxy.type || 'GET';
	_proxy.params = _proxy.params || {};
	if(_proxy.href){
		_proxy.status = true;
	}
		
	function doOutput(val){
		var html = ['<option value="0">' + _text + '</option>'];
		for(i=0; i < _data.length; i++){
			if (_returnAll) {
				html.push('<option value="' + _data[i][_pk] + '">' + _data[i][_label] + '</option>');
			}
			else {
				if (_data[i][_joinId] == val) {
					if (_data[i][_pk] == _selected) {
						html.push('<option value="' + _data[i][_pk] + '" selected="selected">' + _data[i][_label] + '</option>');
					}
					else {
						html.push('<option value="' + _data[i][_pk] + '">' + _data[i][_label] + '</option>');
					}
				}
			}
		}
		$('#' + _elId).html(html.join(' '));		
	}
	
	this.change = function(el){
		var _instance = this;
		var val = el.getSelected();
		var name = el.getName();
		
		if(_proxy.status){
			var params = _proxy.params;
			params[name] = val;
			$.ajax({
				type : 'POST',
				url : proxy.href,
				data : params,
				cache : true,
				dataType : 'json',
				success : function(data){
					if (_proxy.root) {
						_data = data[_proxy.root];
					}else{
						_data = data;
					}
					doOutput(val);
					if(_instance.notify){
						_instance.notify('change');
					}	

				}
			});
		}else{
			doOutput(val);
			if(this.notify){
				this.notify('change');
			}				
		}
	}
	
	this.reset = function(){
		var html = '<option value="0">' + _text + '</option>';
		$('#' + _elId).html(html);
		if(this.notify){
			this.notify('reset');
		}	
	}
 	
	this.getSelected = function(){
		return $('#' + _elId).val();
	}

	this.getName = function(){
		return $('#' + _elId).attr('name');
	}
		
}



/* 
 * @ Massimo Foti 
 * www.massimocorner.com
 */
com.andreacfm.notifier = {};

com.andreacfm.notifier.Decorator = function(obj){
		
		obj.observers = [];

		obj.register = function(observer){
			obj.observers.push(observer);
		}

		obj.unregister = function(observer){
			for(var i=0; i<obj.observers.length; i++){
				if(obj.observers[i] == observer){
					obj.observers.splice(i, 1);
					break;
				}
			}
		}

		obj.notify = function(methodName){
			for(var i=0; i<obj.observers.length; i++){
				var obs = obj.observers[i];
				if(obs){
					if(obs[methodName]){
						obs[methodName](obj);
					}
				}
			}
		}

	return obj;
	}


com.andreacfm.util = {};
	
/**
 * Clock
 * @param {String} id  Dom Element of where to place the clock
 */	
com.andreacfm.util.Clock = function (id){
	setInterval(function(){		
		var date = new Date();
		var month = date.getMonth() + 1;
		var str = date.getDay() + '/' + month + '/' + date.getFullYear() + '  ' + date.getHours() + ':' + date.getMinutes() + ':' + date.getSeconds();
		document.getElementById(id).innerHTML = str;				
	},1000);			
}

com.andreacfm.util.PreventDefault = function(e){
	if(e.preventDefault){ 
		e.preventDefault()
	}else{
		e.returnValue = false;
	};
}
