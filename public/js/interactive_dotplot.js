

function getUrlVars() {
    var vars = {};
    var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
        vars[key] = value;
    });
    return vars;
}

var run_id_code=getUrlVars()["code"];


var directory="user_data/" + run_id_code + "/";
var nickname=getUrlVars()["nickname"];

document.getElementById("nickname_header_dotplot").innerHTML = nickname.replace(/_/g," ");

console.log(run_id_code)
console.log(nickname)


//////////  Positions and sizes for drawing  //////////

var w = window,
    d = document,
    e = d.documentElement,
    g = d.getElementsByTagName('body')[0];

var svg_width;
var svg_height;

var top_edge_padding;
var bottom_edge_padding;
var left_edge_padding;
var right_edge_padding;

var dotplot_canvas_width;
var dotplot_canvas_height;

var chrom_label_y_offset;
var contig_label_x_offset;
var min_pixels_to_draw = 1;
var max_num_alignments = 100000;


//////////  Drawing/D3 objects  //////////
var svg = null;
var dotplot_container = null;
var dotplot_canvas = null;

var dotplot_ref_axis;
var dotplot_query_axis;

//////////  Scales  //////////
var dotplot_ref_scale = d3.scale.linear();
var dotplot_query_scale = d3.scale.linear();

//////////  Behavior  ///////////
var zoom = null;

//////////  reference x query selection  ///////////

var refs_selected = null;
var queries_selected = null;


//////////  Data  //////////

var loaded_ref_index = false;
var loaded_query_index = false;
var loaded_alignments = false;

var ref_index = null;
var query_index = null;

var matching_queries_by_ref = {};
var matching_refs_by_query = {};

var coords_data = null;

var ref_chrom_start_positions = {}; // ref_chrom_start_positions["chr1"] = 234793761 // absolute position on the dot plot
var query_chrom_start_positions = {};  // query_chrom_start_positions["JSAC01000015.1"] = 8237493 // absolute position on the dot plot
var ref_chrom_label_data = [];
var query_chrom_label_data = [];
var cumulative_ref_size = 0;
var cumulative_query_size = 0;


console.log("Starting");
load_data();
responsive_sizing();

function responsive_sizing() {

  // top_banner_height = 120; // without title
  top_banner_height = 170; // with title
 

  window_width = (w.innerWidth || e.clientWidth || g.clientWidth);//*0.98;
  svg_width = window_width*0.7;
  svg_height = (w.innerHeight || e.clientHeight || g.clientHeight) - top_banner_height;

  var right_panel_width = window_width-svg_width;

  // console.log(svg_width)

  top_edge_padding = svg_height*0.04;
  bottom_edge_padding = svg_height*0.15;
  left_edge_padding = svg_width*0.10;
  right_edge_padding = svg_width*0.03; 


  ////////  Create the SVG  ////////
  svg = d3.select("svg")
    .attr("width", svg_width)
    .attr("height", svg_height);
  
  d3.select("#panel")
    .attr("width",right_panel_width)
    .attr("height",svg_height);

  svg.append("rect")
          .attr("width",svg_width)
          .attr("height",svg_height)
          .attr("class","background")
          .style('fill',"none");


  dotplot_canvas_width = svg_width - left_edge_padding - right_edge_padding;
  dotplot_canvas_height = svg_height - top_edge_padding - bottom_edge_padding;


  // TEMPORARY:
  // dotplot_canvas_width = dotplot_canvas_width/2;
  
  // Make it into a square
  // dotplot_canvas_width = Math.min(dotplot_canvas_height,dotplot_canvas_width);
  // dotplot_canvas_height = dotplot_canvas_width;


  // Calculate positions/padding for labels, etc. 
  chrom_label_y_offset = bottom_edge_padding/10;
  contig_label_x_offset = -left_edge_padding/10;
}


var info_stats = "";
function load_data() {
    console.log("Starting to load data from file");
    d3.select("#panel").style("visibility",'visible');
    message_to_user("Loading data");

    d3.csv(directory + nickname + ".info.csv", function(error,info_input) {
        if (error) throw error;

        for (var i = 0; i<info_input.length; i++) {
          d3.select("#stats").append("p").text(info_input[i].key + " = " + info_input[i].value)
        }
        console.log(info_input);
        
    });


    console.log("Loading reference index");
    d3.csv(directory + nickname + ".ref.index", function(error,ref_index_input) {
        if (error) throw error;

        // Reference
        for (var i=0;i<ref_index_input.length;i++){
            ref_index_input[i].ref_length = +ref_index_input[i].ref_length;
            matching_queries_by_ref[ref_index_input[i].ref] = ref_index_input[i].matching_queries.split("~");
        }
        ref_index = ref_index_input;
        loaded_ref_index = true;        
        console.log("Done loading reference index from file");
    });

    console.log("Loading query index");
    d3.csv(directory + nickname + ".query.index", function(error,query_index_input) {
        if (error) throw error;

        // Query
        for (var i=0;i<query_index_input.length;i++){
            query_index_input[i].query_length = +query_index_input[i].query_length;
            matching_refs_by_query[query_index_input[i].query] = query_index_input[i].matching_refs.split("~");
        }
        query_index = query_index_input;
        loaded_query_index = true;
        console.log("Done loading query index from file");
    });


    wait_then_run_when_all_data_loaded();
}

function load_alignments_from_file() {
    message_to_user("Loading alignments");

    console.log("Loading all alignments");
    // ref_start,ref_end,query_start,query_end,ref_length,query_length,ref,query,tag
    d3.csv(directory + nickname + ".oriented_coords.csv", function(error,coords_input) {
        if (error) throw error;
        
        for (var i=0;i<coords_input.length;i++){
          coords_input[i].ref_start = +coords_input[i].ref_start
          coords_input[i].query_start = +coords_input[i].query_start
          coords_input[i].ref_end = +coords_input[i].ref_end
          coords_input[i].query_end = +coords_input[i].query_end
          coords_input[i].ref_length = +coords_input[i].ref_length
          coords_input[i].query_length = +coords_input[i].query_length
        }
        coords_data = coords_input; // set global variable for accessing this elsewhere
        loaded_alignments = true;

        draw_alignments();
        console.log("Done loading data from file");
    });
}

function wait_then_run_when_all_data_loaded() {
  console.log("checking")

  if (loaded_ref_index & loaded_query_index) { // & loaded_alignments) {
    load_alignments_from_file();
    use_indices();
    draw_dotplot();

  } else {
    console.log("loading indices")

    window.setTimeout(wait_then_run_when_all_data_loaded,500)
  }
}


function use_indices() {

    // Reference
    ref_chrom_start_positions = {}; // for quick lookup
    ref_chrom_label_data = []; // for drawing chromosome labels
    cumulative_ref_size = 0;
    for (var i=0;i<ref_index.length;i++){
        var chrom = ref_index[i].ref;
        if (refs_selected == null || refs_selected.indexOf(chrom) != -1) {
          ref_chrom_start_positions[chrom] = cumulative_ref_size; 
          ref_chrom_label_data.push({"chrom":chrom,"pos":cumulative_ref_size,"length":ref_index[i].ref_length});
          cumulative_ref_size += ref_index[i].ref_length;
        }
    }
    // Save the total size of the chromosomes to the domain for the dotplot scale
    dotplot_ref_scale.domain([0,cumulative_ref_size]);

    // Query
    query_chrom_start_positions = {}; // for quick lookup
    query_chrom_label_data = []; // for drawing chromosome labels
    cumulative_query_size = 0;
    for (var i=0;i<query_index.length;i++){
        var chrom = query_index[i].query;
        if (queries_selected == null || queries_selected.indexOf(chrom) != -1) {
          query_chrom_start_positions[chrom] = cumulative_query_size;
          query_chrom_label_data.push({"chrom":chrom,"pos":cumulative_query_size, "length":query_index[i].query_length});
          cumulative_query_size += query_index[i].query_length;
        }
    }
    // Save the total size of the chromosomes to the domain for the dotplot scale
    dotplot_query_scale.domain([0,cumulative_query_size]);

}


function calculate_positions() {
    console.log("calculate_positions() STARTING");


    // Annotate each alignment with an abs_ref_start, abs_ref_end, abs_query_start, abs_query_end that can be plugged directly into the dotplot_ref_scale and dotplot_query_scale scales
    for (var i = 0; i < coords_data.length; i++){
        coords_data[i].abs_ref_start = ref_chrom_start_positions[coords_data[i].ref] + coords_data[i].ref_start;
        coords_data[i].abs_ref_end = ref_chrom_start_positions[coords_data[i].ref] + coords_data[i].ref_end;
        coords_data[i].abs_query_start = query_chrom_start_positions[coords_data[i].query] + coords_data[i].query_start;
        coords_data[i].abs_query_end = query_chrom_start_positions[coords_data[i].query] + coords_data[i].query_end;
    }

    console.log("calculate_positions() DONE");
}

function draw_dotplot() {
    console.log("draw_dotplot");


    svg.selectAll("g").remove();

    //  Create container object (invisible grouping for the canvas but also contains the axes and axis labels)
    dotplot_container = svg.append("g")
        .attr("transform","translate(" + left_edge_padding + "," + top_edge_padding +")");

    //  Create canvas object (invisible grouping for all drawings inside the plot)
    dotplot_canvas = dotplot_container.append("g");

    //  Create rectangle to create a background color
    dotplot_canvas.append("rect")
          .attr("width",dotplot_canvas_width)
          .attr("height",dotplot_canvas_height)
          .attr("class","dotplot_canvas")
          .on("contextmenu", function (d, i) {
              d3.event.preventDefault();
              reset_selections();
          });

    dotplot_ref_scale.range([0,dotplot_canvas_width]); // start at left and plot towards the right
    dotplot_query_scale.range([dotplot_canvas_height,0]); // flipped so we start at the bottom and then plot up

    // Add axes
    dotplot_ref_axis = d3.svg.axis().scale(dotplot_ref_scale).orient("bottom").ticks(5).tickSize(-dotplot_canvas_height,0,0).tickFormat(d3.format("s"));
    // dotplot_container.append("g")
    //     .attr("class","axis")
    //     .attr("id","ref_axis")
    //     .attr("transform","translate(" + 0 + "," + dotplot_canvas_height + ")")
    //     .call(dotplot_ref_axis);

    dotplot_query_axis = d3.svg.axis().scale(dotplot_query_scale).orient("left").ticks(5).tickSize(-dotplot_canvas_width,0,0).tickFormat(d3.format("s"));
    // dotplot_container.append("g")
    //     .attr("class","axis")
    //     .attr("id","query_axis")
    //     .attr("transform","translate(" + 0 + "," + 0 + ")")
    //     .call(dotplot_query_axis);


    // X-axis
    dotplot_container.append("line")
      .style("stroke-width",2)
      .style("stroke", "gray")
      .attr("fill","none")
      .attr("x1",0)
      .attr("y1",dotplot_canvas_height)
      .attr("x2",dotplot_canvas_width)
      .attr("y2",dotplot_canvas_height);

    // Y-axis
    dotplot_container.append("line")
      .style("stroke-width",2)
      .style("stroke", "gray")
      .attr("fill","none")
      .attr("x1",0)
      .attr("y1",0)
      .attr("x2",0)
      .attr("y2",dotplot_canvas_height);
      



    zoom = d3.behavior.zoom()
        .x(dotplot_ref_scale)
        .y(dotplot_query_scale)
        .scaleExtent([1,1000])
        .on("zoom",function() {
          if (dotplot_ref_scale.domain()[0] < 0) {
            dotplot_ref_scale.domain([0, dotplot_ref_scale.domain()[1] - dotplot_ref_scale.domain()[0] + 0]);
          }
          if (dotplot_ref_scale.domain()[1] > cumulative_ref_size) {
            var xdom0 = dotplot_ref_scale.domain()[0] - dotplot_ref_scale.domain()[1] + cumulative_ref_size;
            dotplot_ref_scale.domain([xdom0, cumulative_ref_size]);
          }
          if (dotplot_query_scale.domain()[0] < 0) {
            dotplot_query_scale.domain([0, dotplot_query_scale.domain()[1] - dotplot_query_scale.domain()[0] + 0]);
          }
          if (dotplot_query_scale.domain()[1] > cumulative_query_size) {
            var ydom0 = dotplot_query_scale.domain()[0] - dotplot_query_scale.domain()[1] + cumulative_query_size;
            dotplot_query_scale.domain([ydom0, cumulative_query_size]);
          }
          redraw_on_zoom();
          dotplot_container.select("#ref_axis").call(dotplot_ref_axis);
          dotplot_container.select("#query_axis").call(dotplot_query_axis);
        });

    dotplot_canvas.call(zoom);

    draw_chromosome_labels();
}

function redraw_on_zoom() {
    draw_alignments();
    draw_chromosome_labels();
}


function hover_alignment(d) {
  d3.select("#hover_message").selectAll("p").remove();
  d3.select("#hover_message").append("p").text("Reference = " + d.ref + ": " + d.ref_start + " - " + d.ref_end)
  d3.select("#hover_message").append("p").text("Query = " + d.query + ": " + d.query_start + " - " + d.query_end)

}


function draw_alignment(updateSelection) {
  updateSelection
    .filter(filter_to_view)
    .style("stroke-width",1)
    .style("stroke", function(d) {
      if (d.tag=="repetitive") { return "red";
      } else {return "black";} })
    .attr("fill","none")
    .style("cursor", "crosshair")
    .on("mouseover", hover_alignment)

    .each(function (d) {
      var x1 = dotplot_ref_scale(d.abs_ref_start);
      var x2 = dotplot_ref_scale(d.abs_ref_end);
      var y1 = dotplot_query_scale(d.abs_query_start);
      var y2 = dotplot_query_scale(d.abs_query_end);
      var tangent = (y2-y1)/(x2-x1);

      var new_x1 = x1;
      var new_y1 = y1;

      var found_solution_1 = true;

      ///////////////////     point 1     ///////////////////

      if (x1 < 0 || y1 > dotplot_canvas_height || x1 > dotplot_canvas_width || y1 < 0) {
        found_solution_1 = false
        if (x1 < 0) { // left wall
          var new_x = 0;
          var new_y = y1 - x1 * tangent;
          if (new_x >= 0 && new_x <= dotplot_canvas_width && new_y >= 0 && new_y <= dotplot_canvas_height) {
            new_x1 = new_x;
            new_y1 = new_y;
            found_solution_1 = true;
          }
        }
        if (found_solution_1 == false && y1 > dotplot_canvas_height) { // floor
          var new_x = (dotplot_canvas_height-y1)/tangent + x1;
          var new_y = dotplot_canvas_height;
          if (new_x >= 0 && new_x <= dotplot_canvas_width && new_y >= 0 && new_y <= dotplot_canvas_height) {
            new_x1 = new_x;
            new_y1 = new_y;
            found_solution_1 = true;
          }
        }
        if (found_solution_1 == false && x1 > dotplot_canvas_width) { // right wall
          var new_x = dotplot_canvas_width;
          var new_y = y1+tangent*(dotplot_canvas_width-x1);
          if (new_x >= 0 && new_x <= dotplot_canvas_width && new_y >= 0 && new_y <= dotplot_canvas_height) {
            new_x1 = new_x;
            new_y1 = new_y;
            found_solution_1 = true;
          }
        }
        if (found_solution_1 == false && y1 < 0) { // ceiling
          var new_y = 0;
          var new_x = x1 + (0-y1)/tangent;
          if (new_x >= 0 && new_x <= dotplot_canvas_width && new_y >= 0 && new_y <= dotplot_canvas_height) {
            new_x1 = new_x;
            new_y1 = new_y;
            found_solution_1 = true;
          }
        }
      }

      ///////////////////     point 2     ///////////////////

      var new_x2 = x2;
      var new_y2 = y2;
      var found_solution_2 = true;
      if (x2 < 0 || y2 > dotplot_canvas_height || x2 > dotplot_canvas_width || y2 < 0) {
        found_solution_2 = false;
        if (x2 < 0) { // left wall
          var new_x = 0;
          var new_y = y1 - x1 * tangent;
          if (new_x >= 0 && new_x <= dotplot_canvas_width && new_y >= 0 && new_y <= dotplot_canvas_height) {
            new_x2 = new_x;
            new_y2 = new_y;
            found_solution_2 = true;
          } 
        }
        if (found_solution_2 == false && y2 > dotplot_canvas_height) { // floor
          var new_x = (dotplot_canvas_height-y1)/tangent + x1;
          var new_y = dotplot_canvas_height;
          if (new_x >= 0 && new_x <= dotplot_canvas_width && new_y >= 0 && new_y <= dotplot_canvas_height) {
            new_x2 = new_x;
            new_y2 = new_y;
            found_solution_2 = true;
          }
        }
        if (found_solution_2 == false && x2 > dotplot_canvas_width) { // right wall
          var new_x = dotplot_canvas_width;
          var new_y = y1+tangent*(dotplot_canvas_width-x1);
          if (new_x >= 0 && new_x <= dotplot_canvas_width && new_y >= 0 && new_y <= dotplot_canvas_height) {
            new_x2 = new_x;
            new_y2 = new_y;
            found_solution_2 = true;
          }
        }
        if (found_solution_2 == false && y2 < 0) { // ceiling
          var new_y = 0;
          var new_x = x1 + (0-y1)/tangent;
          if (new_x >= 0 && new_x <= dotplot_canvas_width && new_y >= 0 && new_y <= dotplot_canvas_height) {
            new_x2 = new_x;
            new_y2 = new_y;
            found_solution_2 = true;
          } 
        }
      }

      // console.log(found_solution_1 + " -- " + found_solution_2);
      if (!(found_solution_1 && found_solution_2)) {
        // Don't draw if it 
        new_x2 = new_x1;
        new_y2 = new_y1;
      }

      d3.select(this).attr({
        x1:new_x1,
        y1:new_y1,
        x2:new_x2,
        y2:new_y2
      })
    })

}
function filter_to_view(d) {
    if (refs_selected != null && refs_selected.indexOf(d.ref) == -1) {
      return false;
    }
    if (queries_selected != null && queries_selected.indexOf(d.query) == -1) {
      return false;
    }
    var x1 = dotplot_ref_scale(d.abs_ref_start);
    var x2 = dotplot_ref_scale(d.abs_ref_end);
    var y1 = dotplot_query_scale(d.abs_query_start);
    var y2 = dotplot_query_scale(d.abs_query_end);

    // if (num_alignments_in_view >= max_num_alignments) {
    //   return false;
    // } else {
      if (!((x1 < 0 && x2 < 0) || (x1 > dotplot_canvas_width && x2 > dotplot_canvas_width) || (y1 < 0 && y2 < 0) || (y1 > dotplot_canvas_height && y2 > dotplot_canvas_height))) {
        num_alignments_in_view += 1;
        return true;
      } else {
        return false;
      }
    // }
}

var current_draw_ID = 0;

function draw_lines(svg, data, batchSize) {
    num_alignments_in_view = 0;
    var filtered_data = data.filter(filter_to_view);
    var alignments = svg.selectAll('line.alignment').data(filtered_data);
    current_draw_ID += 1;
    var this_draw_ID = current_draw_ID;

    function drawBatch(batchNumber) {
        return function() {
            console.log("drawBatch");
            var startIndex = batchNumber * batchSize;
            var stopIndex = Math.min(filtered_data.length, startIndex + batchSize);
            var updateSelection = d3.selectAll(alignments[0].slice(startIndex, stopIndex));
            var enterSelection = d3.selectAll(alignments.enter()[0].slice(startIndex, stopIndex));
            var exitSelection = d3.selectAll(alignments.exit()[0].slice(startIndex, stopIndex));

            enterSelection.each(function(d, i) {
                var newElement = svg.append('line')[0][0];
                enterSelection[0][i] = newElement;
                updateSelection[0][i] = newElement;
                newElement.__data__ = this.__data__;
            }).attr("class","alignment");

            exitSelection.remove();

            draw_alignment(updateSelection);


            if (stopIndex >= filtered_data.length) {
                message_to_user("Done");
            } else {
              if (current_draw_ID == this_draw_ID) {
                setTimeout(drawBatch(batchNumber + 1), 0);
              }
            }
        };
    }
    setTimeout(drawBatch(0), 0);
}

function draw_alignments() {

  message_to_user("Drawing alignments");
  calculate_positions();

  dotplot_canvas.selectAll("line.alignment").remove();
  var BATCH_SIZE = 1000;
  draw_lines(dotplot_canvas.data([0]), coords_data, BATCH_SIZE);
}


function clear_chromosome_labels() {
  dotplot_canvas.selectAll("line.chromosome").remove();
  dotplot_container.selectAll("text.chromosome").remove();
  dotplot_canvas.selectAll("line.contig").remove();
  dotplot_container.selectAll("text.contig").remove();
}

function draw_chromosome_labels() {
  clear_chromosome_labels();
  

    //////////////////////////////     Reference labels     //////////////////////////////
    
    dotplot_canvas.selectAll("line.chromosome")
        .data(ref_chrom_label_data)
        .enter()
        .append("line")
            .filter(function(d) {return ((refs_selected == null || refs_selected.indexOf(d.chrom)!=-1) && (dotplot_ref_scale(d.pos) > 0 && dotplot_ref_scale(d.pos) < dotplot_canvas_width))})
                .attr("class","chromosome")
                .style("stroke-width",1)
                .style("stroke", "gray")
                .attr("fill","none")
                .attr("x1",function(d){ return dotplot_ref_scale(d.pos); })
                .attr("y1",0)
                .attr("x2",function(d){ return dotplot_ref_scale(d.pos); })
                .attr("y2",dotplot_canvas_height);

    
    dotplot_container.selectAll("text.chromosome")
        .data(ref_chrom_label_data)
        .enter()
        .append("text")
            .filter(function(d) {return ((refs_selected == null || refs_selected.indexOf(d.chrom)!=-1) && (!(dotplot_ref_scale(d.pos + d.length) < 0 || dotplot_ref_scale(d.pos) > dotplot_canvas_width)))})
                .attr("class","chromosome")
                .attr("text-anchor", "end")
                .attr("dominant-baseline","middle")
                .attr("y",function(d) {
                  if (dotplot_ref_scale(d.pos) > 0 && dotplot_ref_scale(d.pos + d.length) < dotplot_canvas_width) {
                    return dotplot_ref_scale(d.pos+d.length/2);
                  } else if (dotplot_ref_scale(d.pos + d.length) < dotplot_canvas_width) {
                    // If end of chromosome is showing, put label at average of left wall and end of chromosome
                    return (dotplot_ref_scale(d.pos+d.length) + 0)/2;
                  } else if (dotplot_ref_scale(d.pos) > 0) {
                    // If start of chromosome is showing, put label at average of start and the right wall
                    return (dotplot_ref_scale(d.pos)+dotplot_canvas_width)/2;
                  } else {
                    return dotplot_canvas_width/2;
                  }
                })
                .attr("x",function(d) {return -dotplot_canvas_height-chrom_label_y_offset;})
                .text(function(d) {return d.chrom; })
                .style("fill","gray")
                .style("font-size",function(d) { return Math.min(dotplot_ref_scale(d.length) , ((bottom_edge_padding*0.8) / this.getComputedTextLength() * 14)) + "px";  })
                .attr("transform", "rotate(-90)")
            .on("click",zoom_to_chromosome)
            .on("contextmenu", function (d, i) {
              d3.event.preventDefault();
              reset_selections();
            });

    //////////////////////////////     Query labels     //////////////////////////////

    if (query_chrom_label_data.length < 200 || queries_selected != null) {
          
          dotplot_canvas.selectAll("line.contig")
              .data(query_chrom_label_data)
              .enter()
              .append("line")
                  .filter(function(d) {return (dotplot_query_scale(d.pos) > 0 && dotplot_query_scale(d.pos) < dotplot_canvas_height)})
                      .attr("class","contig")
                      .style("stroke-width",1)
                      .style("stroke", "gray")
                      .attr("fill","none")
                      .attr("x1",0)
                      .attr("y1",function(d){ return dotplot_query_scale(d.pos); })
                      .attr("x2",dotplot_canvas_width)
                      .attr("y2",function(d){ return dotplot_query_scale(d.pos); });
          
          dotplot_container.selectAll("text.contig")
              .data(query_chrom_label_data)
              .enter()
              .append("text")
                  .filter(function(d) {return !(dotplot_query_scale(d.pos) < 0 || dotplot_query_scale(d.pos + d.length) > dotplot_canvas_height)})
                      .attr("class","contig")
                      .attr("text-anchor", "end")
                      .attr("dominant-baseline","middle")
                      .attr("y",function(d) {
                        if (dotplot_query_scale(d.pos) < dotplot_canvas_height && dotplot_query_scale(d.pos + d.length) > 0) {
                          return dotplot_query_scale(d.pos+d.length/2);
                        } else if (dotplot_query_scale(d.pos + d.length) > 0) {
                          // If end of chromosome is showing, put label at average of floor and end of chromosome
                          return (dotplot_query_scale(d.pos+d.length) + dotplot_canvas_height)/2;
                        } else if (dotplot_query_scale(d.pos) < dotplot_canvas_height) {
                          // If start of chromosome is showing, put label at average of start and the ceiling
                          return (dotplot_query_scale(d.pos)+0)/2;
                        } else {
                          return dotplot_canvas_height/2;
                        }
                      })
                      .attr("x",function(d) {return contig_label_x_offset;})
                      .text(function(d) {return d.chrom; })
                      .style("fill","gray")
                      .style("font-size",function(d) {return Math.min(dotplot_query_scale(d.pos)-dotplot_query_scale(d.pos + d.length), left_edge_padding*0.8 / this.getComputedTextLength() * 14) + "px";  })
                      .on("click",zoom_to_contig)
                      .on("contextmenu", function (d, i) {
                        d3.event.preventDefault();
                        reset_selections();
                      });
      }
}

function reset_selections(){
  refs_selected = null;
  queries_selected = null;
  clear_chromosome_labels();
  use_indices();
  draw_dotplot();
  draw_alignments();
}

function measure_shared_sequence_ref(query,ref) {
  var shared_sequence = 0;
  for (var i = 0; i < coords_data.length; i++) {
    if (coords_data[i].ref == ref && coords_data[i].query == query) {
      shared_sequence += Math.abs(dotplot_ref_scale(coords_data[i].abs_ref_end) - dotplot_ref_scale(coords_data[i].abs_ref_start));
    }
  }
  return shared_sequence;
}

function measure_shared_sequence_query(query,ref) {
  var shared_sequence = 0;
  for (var i = 0; i < coords_data.length; i++) {
    if (coords_data[i].ref == ref && coords_data[i].query == query) {
      shared_sequence += Math.abs(dotplot_query_scale(coords_data[i].abs_query_end) - dotplot_query_scale(coords_data[i].abs_query_start));
    }
  }
  return shared_sequence;
}

var min_shared_seq_in_pixels = 5;

function zoom_to_chromosome(d) {
  console.log("zoom to chromosome");
  console.log(d.chrom);
  // console.log(matching_queries_by_ref[d.chrom]);
  refs_selected = [d.chrom];
  var potential_queries_selected = matching_queries_by_ref[d.chrom];
  // console.log(queries_selected);
  queries_selected = potential_queries_selected;

  use_indices();


  // Narrow down to queries with at least a small shared sequence
  queries_selected = [];
  for (var i = 0; i < potential_queries_selected.length; i++) {
    if (measure_shared_sequence_ref(potential_queries_selected[i],d.chrom) >= min_shared_seq_in_pixels) {
      queries_selected.push(potential_queries_selected[i]);
    }
  }

  clear_chromosome_labels();
  use_indices()
  draw_dotplot();
  draw_alignments();


}

function zoom_to_contig(d) {
  console.log(d.chrom);
  console.log(matching_refs_by_query[d.chrom]);
  queries_selected = [d.chrom];
  var potential_refs_selected = matching_refs_by_query[d.chrom];
  refs_selected = potential_refs_selected;

  use_indices();

  console.log(potential_refs_selected);
  // Narrow down to queries with at least a small shared sequence
  refs_selected = [];
  for (var i = 0; i < potential_refs_selected.length; i++) {
    // console.log(potential_refs_selected[i]);
    // console.log(measure_shared_sequence_query(d.chrom,potential_refs_selected[i]));
    if (measure_shared_sequence_query(d.chrom,potential_refs_selected[i]) >= min_shared_seq_in_pixels) {
      refs_selected.push(potential_refs_selected[i]);
    }
  }
  console.log(refs_selected);

  clear_chromosome_labels();

  use_indices();
  draw_dotplot();
  draw_alignments();

}


function message_to_user(message) {
  d3.select("#user_message")
    .text(message)
}

window.onresize = resizeWindow;
function resizeWindow()
{
  clear_chromosome_labels();
  responsive_sizing();
  draw_dotplot();
  draw_alignments();

}
