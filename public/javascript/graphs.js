jQuery(function(){
    $("document").ready(function(){
        $("#myTab a:last").click(function(e){
            e.preventDefault();
            $(this).tab('show');
        });

        var results = Morris.Line({
            element: 'results-graph',
            data: $("#results").data("graph"),
            xkey: 'id',
            ykeys: ['score'],
            labels: ['Score'],
            parseTime: false
        });
        var freq = Morris.Line({
            element: 'frequency-graph',
            data: $("#frequency").data("graph"),
            xkey: 'id',
            ykeys: ['score'],
            labels: ['Score'],
            parseTime: false
        });
        var dist = Morris.Line({
            element: 'distance-graph',
            data: $("#distance").data("graph"),
            xkey: 'id',
            ykeys: ['score'],
            labels: ['Score'],
            parseTime: false
        });
        var loc = Morris.Line({
            element: 'location-graph',
            data: $("#location").data("graph"),
            xkey: 'id',
            ykeys: ['score'],
            labels: ['Score'],
            parseTime: false
        });
        var pr = Morris.Line({
            element: 'pagerank-graph',
            data: $("#pagerank").data("graph"),
            xkey: 'id',
            ykeys: ['score'],
            labels: ['Score'],
            parseTime: false
        });

        $("ul.nav a").on('shown.bs.tab', function(e){
            var types = $(this).attr('data-identifier');
            var typesArray = types.split(',');
            $.each(typesArray, function(k, v){
                eval(v + ".redraw()");
            });
        });
        $("ul.nav a:first").tab('show');
    });
});
