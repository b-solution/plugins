jQuery.noConflict();

jQuery(document).ready(function(){
    jQuery('#periodictask_next_run_date').datepicker(
        {dateFormat: "yy-mm-dd", minDate: new Date()}
    );
});

