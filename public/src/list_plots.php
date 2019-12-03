<?php
    $code=$_POST['code'];
    // echo json_encode(shell_exec("ls user_data/". $code . "/*.png"));

    // $pattern = "user_data/".$code."/*.png";
    $filenames = glob("user_data/".$code."/*.png");
    echo json_encode($filenames);
?>
