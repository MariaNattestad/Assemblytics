<!DOCTYPE html>

<html>

<!--    NAVIGATION BAR-->
<?php include "header.html";?>
<?php include "title.html";?>

<!--INSTRUCTIONS-->
<div class="row">
  <div class="col-lg-7">
    <div class="panel panel-default">
      <div class="panel-heading"> <h3 class="panel-title">Instructions</h3></div>
      <div class="panel-body"><p>Upload a delta file to analyze alignments of an assembly to another assembly or a reference genome</p>
        <ol>
          <li>Download and install <a href="http://sourceforge.net/projects/mummer/files/" target="_blank">MUMmer</a></li>
          <li>Align your assembly to a reference genome using nucmer (from MUMmer package)
              <p><pre>$ nucmer -maxmatch -l 100 -c 500 REFERENCE.fa ASSEMBLY.fa -prefix OUT</pre></p>
              <p>
                Consult the <a href="http://mummer.sourceforge.net/manual/" target="_blank">MUMmer manual</a> if you encounter problems</li>
              </p></li>
          <li>Optional: Gzip the delta file to speed up upload (usually 2-4X faster)
            <p><pre>$ gzip OUT.delta</pre>
              Then use the OUT.delta.gz file for upload.
            </p></li>
          <li>Upload the .delta or delta.gz file (<a href="public/sample.delta" target="_blank">view example</a>) to Assemblytics</li>
        </ol>
        <p>
          Important: Use only contigs rather than scaffolds from the assembly. This will prevent false positives when the number of Ns in the scaffolded sequence does not match perfectly to the distance in the reference. 
        </p>
        <p>
          The unique sequence length required represents an anchor for determining if a sequence is unique enough to safely call variants from, which is an alternative to the mapping quality filter for read alignment. 
        </p>
      </div>
    </div>
  </div>
  <div class="col-lg-5"> 
    <div class="panel panel-default">
      <div class="panel-heading"> <h3 class="panel-title">Run Assemblytics</h3></div>
      <div class="panel-body">
        <div class="center frame"> 
            <!--    DROPZONE   -->
            <form action="file_upload.php" class="dropzone" id="myAwesomeDropzone">
                <input type="hidden" name="code_hidden" value="">
            </form>
            <!--   end of DROPZONE   -->
        </div>
        <div class="center frame"> 
          <!--    SUBMIT BUTTON with hidden field to transport code to next page   -->
          <form name="input_code_form" action="input_validation.php"  method="post">
            <p>
              <div class="input-group input-group-lg">
                <span class="input-group-addon">Description</span>
                  <input type="text" name="nickname" class="form-control" value = "my favorite organism">
              </div>
            </p>
            <p>
              <div class="input-group input-group-lg">
                <span class="input-group-addon">Unique sequence length required</span>
                  <input type="number" max="100000" step="1000" min="1000" name="uniqlength" class="form-control" value = "10000">
              </div>
            </p>
            <p>
              <div class="input-group input-group-lg">
                <span class="input-group-addon">Maximum variant size</span>
                  <input type="number" max="100000" step="1000" min="1000" name="max_size" class="form-control" value = "10000">
              </div>
            </p>
            <p>
              <div class="input-group input-group-lg">
                <span class="input-group-addon">Minimum variant size</span>
                  <input type="number" max="50" step="1" min="1" name="min_size" class="form-control" value = "50">
              </div>
            </p>
            <p id="analysis_form">
              <!--  submit button set from within front_page_script.js --> 
            </p>
          </form>
        </div>
      </div>
    </div>
  </div>
</div>


<!--scripts at the end of the file so they don't slow down the html loading-->
<script src="js/front_page_script.js"></script>
<script src="js/dropzone.js"></script>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
<script src="js/bootstrap.min.js"></script>

<script type="text/javascript">
Dropzone.options.myAwesomeDropzone = {
  accept: function(file, done) {
    console.log("uploaded");
    done();
  },
  maxFilesize: 2000, // in MiB
  init: function() {
    this.on("addedfile", function() {
      if (this.files[1]!=null){
        this.removeFile(this.files[0]);
      }
    });
  }
};  

</script>
</body>
</html>
