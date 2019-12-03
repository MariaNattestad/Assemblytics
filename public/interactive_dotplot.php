<!DOCTYPE html>

<html>


<!--    NAVIGATION BAR-->
    <?php include "header.html";?>
    
    <div style="text-align: center"><h3 id="nickname_header_dotplot"></h3></div>
    
    <svg>       </svg>
    <div id="panel" style="visibility: hidden" dominant-baseline="top">
      <div style="text-align: left" id="stats"><strong>Info:</strong></div>
      <div style="text-align: left"><strong>Progress:</strong><p id="user_message"></p></div>
      <div style="text-align: left"><strong>Hover coordinates:</strong><div id="hover_message"> </div></div>
    </div>

<style>

    .axis path,line {
      stroke:#ccc;
    }
    .background {
      /*fill:#eee;*/
      fill:#ccc;
    }
    .dotplot_canvas {
      fill:#fff;
    }

    #panel {
      display:inline-block;
      padding: 5px 5px 5px 5px;
      float:left;
    }
    svg {
      display:inline-block;
      float:left;
    }

   /* .chromosome {
      font-size:2vmin;
    }*/
    
</style>

<script src="js/d3.v3.min.js"></script>
<script src="js/render_queue.js"></script>
<script src="js/interactive_dotplot.js"></script>

<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
<script src="js/bootstrap.min.js"></script>


