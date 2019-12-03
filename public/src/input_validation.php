<!DOCTYPE html>

<html>

<!--    NAVIGATION BAR-->
<?php include "header.html";?>
<?php include "title.html";?>

<div class="panel">
<?php
    $debug=""; //put -d here when testing    
    $aResult = array();
    if( !isset($_POST['code']) ) { $aResult['error'] = 'ERROR: No code passed to input_validation.php';}
    $code=escapeshellcmd($_POST["code"]);
    $uniqlength=escapeshellcmd($_POST["uniqlength"]);
    $nickname = "my_assembly";
    if( !isset($_POST['min_size']) ) { $aResult['error'] = 'ERROR: No min_size passed to input_validation.php';}
    if( !isset($_POST['max_size']) ) { $aResult['error'] = 'ERROR: No max_size passed to input_validation.php';}
    $min_size = escapeshellcmd($_POST["min_size"]);
    $max_size = escapeshellcmd($_POST["max_size"]);

    if( isset($_POST['nickname']) ) {
        $nickname = escapeshellcmd($_POST['nickname']);

        // Replace all non-alphanumeric characters with underscores
        $nickname = preg_replace('/[^a-zA-Z0-9]/', '_', $nickname);
    }

    // if( !isset($_POST['read_length']) ) { echo shell_exec('echo ERROR: No read_length passed to run.php >> user_data/$code/run.log');}
    // $kmer_length = $_POST["kmer_length"];
    // $read_length = $_POST["read_length"];


    $url="analysis.php?code=$code";
    $run_url="run_algorithm.php";
    $filename="user_uploads/$code";
    
    $back_button= "<form action=\"./\" method=GET><button type=\"submit\" class=\"center btn btn-danger\">Back</button></form>";
    //$continue_button= "<form action=\"$url\"><input type=\"hidden\" name = \"code\" value=\"$code\"><button type=\"submit\" class=\"center btn btn-success\">Continue</button></form>";
    
    $continue_button= "<form 
        action=\"$run_url\" 
        method=\"post\">
            <input type=\"hidden\" name = \"code\" value=\"$code\">   
            <input type=\"hidden\" name=\"nickname\" value=\"$nickname\">  
            <input type=\"hidden\" name=\"uniqlength\" value=\"$uniqlength\">  
            <input type=\"hidden\" name=\"max_size\" value=\"$max_size\">  
            <input type=\"hidden\" name=\"min_size\" value=\"$min_size\"> 
            <button type=\"submit\" class=\"center btn btn-success\">Continue</button>
        </form>";
        
        // <input type=\"hidden\" name=\"read_length\" value=\"$read_length\"> 
    
    if (!file_exists ($filename)) {
        echo "<div class=\"alert center alert-danger\" role=\"alert\">No file uploaded</div>";
        echo "$back_button";
        exit;
    }
    
    $consistent=true;
    // $myfile = fopen($filename, "r") or die("Unable to open file!");
    // $line1 = fgets($myfile);

    $myfile = gzopen($filename, "r") or die("Unable to open file!");
    $line1 = gzgets($myfile);


    
    $line1 = trim(preg_replace( '/\s+/', ' ', $line1 ));
    
    $array=array_map("trim",explode(' ',$line1));
    if (count($array)==2) {
        // echo "GOOD first line";
    } else {
        echo "Bad first line. \n";
        $consistent=false;
    }

    $line2 = fgets($myfile);
    $line2 = trim(preg_replace( '/\s+/', ' ', $line2 ));
    
    if ($line2 == "NUCMER") {
        // echo "GOOD second line";
    } else {
        echo "Bad second line\n";
        $consistent=false;
    }

    // fclose($myfile);
    gzclose($myfile);

    if ($consistent) {
        // if ($previous_bins > 500) {
            echo "<div class=\"alert center alert-success\" role=\"alert\">Great! File was uploaded and looks like a real delta file</div>";
        // } else {
            // echo "<div class=\"alert center alert-warning\" role=\"alert\">File was uploaded and has acceptable dimensions:  $line_counter samples by $previous_bins bins, but the analysis is unlikely to work optimally without more bins. We recommend at least 500 bins for higher accuracy.</div>";
        // }
        
        if (!file_exists("user_data/$code")) {
            
        }
        else {
            echo "<div class=\"alert center alert-info\" role=\"alert\">File already submitted once. Please continue.</div>";
        }
        echo "<div style=\"margin-left:1%;\"><div class=\"col-sm-1\">";
        echo "$back_button";
        echo "</div><div class=\"col-sm-1\">";
        echo "$continue_button";
        echo "</div></div>";
    }
    else {
        echo "<div class=\"alert center alert-danger\" role=\"alert\">This doesn't look like a delta file. Are you sure it is the output from nucmer? The first line should list two file names separated by a space, and the second line should be the word 'NUCMER'. The remaining lines in the file specify alignments.";
        echo "</div>";
        echo "$back_button";
    }
   
    
    
    
?>
</div>
</body>
</html>
