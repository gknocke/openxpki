/** format helper: factory & base classes */

/**
you can dynamically register new Helper via OXI.FormatHelperFactory.registerComponent(format,componentname,method)
*/
OXI.FormatHelperFactory = OXI.ComponentFactory.create({
    _componentMap : {
        timestamp :  'FormatTimestamp',
        link      :  'FormatLink',
        email     :  'FormatEmail',
        certstatus:  'FormatCertStatus'
    },

    _instances: {},

    /** direct access to singleton-helper */
    getHelper: function (type){
        if(!this._instances[type]){
            this._instances[type] = this.getComponent(type);//no params possible here
        }
        return this._instances[type];
    }

});


OXI.FormatHelper = Ember.Object.extend({
    format: function(data){
        return data;
    }
});

OXI.FormatTimestamp = OXI.FormatHelper.extend({
    format: function(timestamp){
    	timestamp = parseInt(timestamp);
    	if (timestamp == 0) { return ''; }
        var D = new Date(timestamp*1000);
        //return D.toLocaleString();
        return D.toGMTString();
    }
});

OXI.FormatLink  = OXI.FormatHelper.extend({
    format: function(link){

        if(!link.label){
            App.applicationAlert('link with no label!');
            return;
        }
        if(!link.page && !link.action){
            App.applicationAlert('link '+label+'with neither action nor page!');
            return;
        }
        var link_id = OXI.getUniqueId();
        
        OXI.registerMethod(link_id,function(){
    		App.handleAction(link);
        });
        
        var $link = $('<a/>').html(link.label).attr('id',link_id).attr('href','#').attr('onclick',"OXI.callMethod('"+link_id+"');event.cancelBubble=true;return false;");        
       
        var $outer =   $('<div/>');   
        $link.appendTo($outer);                
        return $outer.html();

    }
});

/*Format Email*/
OXI.FormatEmail  = OXI.FormatHelper.extend({
    format: function(email){
		/*stupid regex for basic typos*/	
		if(!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.label)){
			App.applicationAlert('Syntax error in email: ' + email.label);
			return;
		}
		
        var email_id = OXI.getUniqueId();
        
        OXI.registerMethod(email_id,function(){
    		App.handleAction(email);
        });
        var $email = $('<a/>').html(email.label).attr('id',email_id).attr('href','mailto:' + email.label).attr('onclick',"OXI.callMethod('"+email_id+"');");        
       
        var $outer =   $('<div/>');   
        $email.appendTo($outer);                
        return $outer.html();
    }
});

OXI.FormatCertStatus = OXI.FormatHelper.extend({
    format: function(status){    	
        var $span = $('<span/>').html( status.label ).attr('class','certstatus-' + status.value.toLowerCase() );                             
        var $outer =   $('<div/>');   
        $span.appendTo($outer);
        return $outer.html();
    }
});



