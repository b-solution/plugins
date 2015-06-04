document.observe("dom:loaded", function(){
    var form = $('modules-form');
    var input = form['enabled_module_names[]'];
    
    var tracker = false;    
    var periodic = false;
    
    for (var i=0; i< input.length; i++){
        switch(input[i].value){
            case 'issue_tracking':
                tracker = input[i];
                break;
            case 'periodictask_module':
                periodic = input[i];
                break;
            default:
                break;
        }
    }
    
    // No Tracker means not Tasks
    if (!tracker){ periodic.setStyle({ display: 'none' }); }
    else{
        tracker.observe('click', trackerClick);
        periodic.observe('click', periodicClick);
        periodic.up().insert(" (nur zusammen mit einem Tracker)");
    }

    function trackerClick(event){
        if (tracker.checked == false){ periodic.checked = false; }
    }

    function periodicClick(event){
        console.log(tracker.checked);
        if ( tracker.checked == false ){ Event.stop(event); }
    }    
});


