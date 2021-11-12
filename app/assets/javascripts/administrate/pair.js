$(function(){
    if($('#bot_pair_id').length){
        var selectizeControl = $('#bot_pair_id')[0].selectize;
        selectizeControl.on('change', function(value) {
            $.ajax({
                type:'GET',
                dataType: 'json',
                url: `/admin/pairs/${value}`,
                success: function(value){
                    $('#pair_current_price').text(value.current_price);
                }
            });
        });
    }
});