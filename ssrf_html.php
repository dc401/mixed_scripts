<html>
        <body>
                <form action="" method="get">
                        URL: <input type="text" name="url"><br>
                <input type="submit" name="submit_ssrf">
                </form>

                Results:
                <?php
                        if(isset($_GET['submit_ssrf'])) {
                                if (!empty($_GET["url"])) {
                                echo "<pre>";
                                echo htmlentities(file_get_contents($_GET["url"]));
                                echo "</pre>";
                                }
                }
                ?>
        </body>
</html>
//this is a modified code to mimic https://www.sans.org/blog/cloud-instance-metadata-services-imds-/
//xtecsystems.com/research
