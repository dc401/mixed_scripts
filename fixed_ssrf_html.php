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
                                    //input validation from https://medium.com/secjuice/php-ssrf-techniques-9d422cb28d51
                                    if(filter_var($argv[1], FILTER_VALIDATE_URL)) {
                                        $r = parse_url($argv[1]);
                                        print_r($r);
                                        if(preg_match('/scalesec\.com$/', $r['host'])) {
                                        echo "<pre>";
                                        echo htmlentities(file_get_contents($_GET["url"]));
                                        echo "</pre>";
                                    }

                                }
                }
                ?>
        </body>
</html>
//this is a modified code to mimic https://www.sans.org/blog/cloud-instance-metadata-services-imds-/
//xtecsystems.com/research