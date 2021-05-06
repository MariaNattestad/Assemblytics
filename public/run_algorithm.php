<html>
    <body>
        
<?php

    if( !isset($_POST['code']) ) { echo shell_exec('echo ERROR: No run ID passed to run_algorithm.php >> user_data/ERRORS/run_algorithm.log');}
    $code=preg_replace('/[^A-Za-z0-9]/', '', $_POST["code"]);
    
    if( !isset($_POST['nickname']) ) { echo shell_exec('echo ERROR: No nickname passed to run_algorithm.php >> user_data/$code/run_algorithm.log');}
    if( !isset($_POST['uniqlength']) ) { echo shell_exec('echo ERROR: No uniqlength passed to run_algorithm.php >> user_data/$code/run_algorithm.log');} 
    if( !isset($_POST['min_size']) ) { echo shell_exec('echo ERROR: No min_size passed to run_algorithm.php >> user_data/$code/run_algorithm.log');} 
    if( !isset($_POST['max_size']) ) { echo shell_exec('echo ERROR: No max_size passed to run_algorithm.php >> user_data/$code/run_algorithm.log');} 
    $nickname = escapeshellarg($_POST["nickname"]);
    $uniqlength = escapeshellarg($_POST["uniqlength"]);
    $min_size = escapeshellarg($_POST["min_size"]);
    $max_size = escapeshellarg($_POST["max_size"]);
    $url="analysis.php?code=$code";
    $filename="user_uploads/$code";
    $oldmask = umask(0);
    mkdir("user_data/$code");
    umask($oldmask);

    echo shell_exec("../scripts/Assemblytics $filename user_data/$code/$nickname $uniqlength $min_size $max_size &> user_data/$code/run_algorithm_errors.log &");

    $new_dataset = array( "date"=>time(), "codename"=>$code, "description"=> $nickname );

    $my_datasets = array();
    if(isset($_COOKIE["results"])) {
      // cookie is already there, adding to the existing info
      $my_datasets = json_decode($_COOKIE["results"], true);
    }

    array_push($my_datasets, $new_dataset);
    setcookie("results", json_encode($my_datasets));

    header('Location: '.$url);
?>
    </body>
</html>

<!-- <form name="input_code_form" action="run.php" id="analysis_form" method="post"> -->
