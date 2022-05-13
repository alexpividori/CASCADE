<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html lang="EN">
<head>
                <title>INTERREG IT-HR  CASCADE project -- ARPA FVG - CRMA  -- C3HPC DATA ACCESS</title>
                <meta http-equiv="Content-type" content="text/html; charset=utf-8">
                <meta http-equiv="content-language" content="it, en">
                <meta name="author" content="Alex Pividori">
                <link rel="stylesheet" href="./styles.css" type="text/css">
       

      <style type="text/css">
            body {
                font-family: sans-serif;
                color: black;
                /* background-image: url("./logos/calm-sea-background.jpg"); */
                background-color: #f0f8ff;
            }

            .titleDiv {
                color: #6495ed;
                background-color: rgba(0, 99, 73, 0.1); /* #fff8dc */;
                text-align: center;
                font-family: "Times New Roman", Times, serif;
            }

            .myClass  {
                color: black;
                border-collapse: collapse;
                text-align: center;
            }

            table, th {
                border: 1px solid black;
                border-collapse: collapse;
                text-align: center;
            }
    
            td {
                border: 1px solid black;
                border-collapse: collapse;
                text-align: right;
            }

            th, td {
                padding: 15px;
                border-collapse: collapse;
            }

            a:link {
                color: #708090;
                background-color: transparent;
                text-decoration: none;
            }

            a:visited {
                color: #796878;
                background-color: transparent;
                text-decoration: none;
            }

            a:hover {
                text-decoration: underline;
            }


            a:active {
                color: red;
                background-color: transparent;
                text-decoration: underline;
            }


            p.first_cell {
                text-align: center;
                margin-bottom: 0em;
                color: #ff5050;
            }

        </style>

 
</head>

<!-- +++++++++++++  START BODY +++++++++++++++++++++++++++++++ -->

<body BGCOLOR="#AFFFFF">

<script type="text/javascript">

  var date2 = new Date();  // today's date
  var date1 = new Date(date2);
  var date3 = new Date(date2);
  var date4 = new Date(date2);
  var date5 = new Date(date2);
  
  date1.setDate(date2.getDate() - 1);
  date3.setDate(date2.getDate() + 1);
  date4.setDate(date2.getDate() + 2);
  date5.setDate(date2.getDate() + 3);
  
  var year1  = date1.getFullYear();
  var month1 = ("0" + (date1.getMonth() + 1)).slice(-2);
  var day1   = ("0" + date1.getDate() ).slice(-2);  

  var year2  = date2.getFullYear();
  var month2 = ("0" + (date2.getMonth() + 1)).slice(-2);
  var day2   = ("0" + date2.getDate() ).slice(-2);

  var year3  = date3.getFullYear();
  var month3 = ("0" + (date3.getMonth() + 1)).slice(-2);
  var day3   = ("0" + date3.getDate() ).slice(-2);

  var year4  = date4.getFullYear();
  var month4 = ("0" + (date4.getMonth() + 1)).slice(-2);
  var day4   = ("0" + date4.getDate() ).slice(-2);

  var year5  = date5.getFullYear();
  var month5 = ("0" + (date5.getMonth() + 1)).slice(-2);
  var day5   = ("0" + date5.getDate() ).slice(-2);

  var date1d  = year1 +  "" + month1 + ""  + day1

  var date1s  = year1 + "-" + month1 + "-" + day1  
  var date2s  = year2 + "-" + month2 + "-" + day2
  var date3s  = year3 + "-" + month3 + "-" + day3
  var date4s  = year4 + "-" + month4 + "-" + day4
  var date5s  = year5 + "-" + month5 + "-" + day5  

</script>

<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->

<div class="titleDiv">
            <a href="https://www.italy-croatia.eu/web/CASCADE" target="_blank" title="CASCADE website">
                <img src="logos/CASCADE-logo.png" alt="Interreg Italy-Croatia CASCADE" style="float:left;height:15.0%;width:18.8%">
            </a>

            <a href="http://www.arpa.fvg.it/cms/tema/aria/utilita/CRMA/index.html" target="_blank" title="CRMA website (it)">
                <img src="logos/crma-logo.png" alt="Centro Regionale di Modellistica Ambientale" style="float:right;height:14.0%;width:13.0%">
            </a>

            <a href="http://www.arpa.fvg.it" target="_blank" title="ARPA FVG website (it)">
                <img src="logos/arpafvg-logo.jfif" alt="Agenzia Regionale per la Protezione dell'Ambiente del Friuli Venezia Giulia" style="float:right;height:14.2%;width:16.2%">
            </a>

            <h3 align="center">Interreg IT-HR CASCADE @ ARPA FVG - CRMA</h3>
</div>
<h1 align="center" style="font-size:1.5vw" id="current_date" > </h1>
<br><br><br><br>

<script>document.getElementById("current_date").innerHTML = "Current date: "+date2s;</script>
 
<table align="center">

<caption class="titleDiv" style="font-size:2vw"> Marine forecasts for Northern Adriatic Sea </caption>

<thead bgcolor="gainsboro">
<tr>

<!-- +++++++++++++++ first cell +++++++++++++++++++ -->

<th align="center" >
<p class="first_cell"> <?php 

$actual_date = date("Y-m-d",strtotime("+2 Hours"));
$update_date = date("Y-m-d", filemtime("./FORECAST/f_d1/tsdiagram_Grado_00.30.png"));
echo "Date of update: ";
echo $update_date . "<br>" ; 

if ( $actual_date == $update_date ) 
{ echo " Files are correclty updated"."<br>"; echo '<img src="logos/green_light.png" alt="Data correctly updated" width="30" height="30" >';}
else 
{ echo " Warning: Files are not daily updated"."<br>"; echo'<img src="logos/red_light.png" alt="Files not correctly updated" width="30" height="30" >';}
?></p>
</th> 

<!-- +++++++++++++ end of first cell +++++++++++++++++ -->

<th> +00h   <p id="bulletin_date_value" class="myClass" > </p> (bulletin date) </th> 
<th> +24h   <p id="24_date_value"       class="myClass" > </p>                 </th> 
<th> +48h   <p id="48_date_value"       class="myClass" > </p>                 </th> 
<th> +72h   <p id="72_date_value"       class="myClass" > </p>                 </th> 
<th> +96h   <p id="96_date_value"       class="myClass" > </p>                 </th> 
</tr> 
</thead>

<?php
if ( $actual_date == $update_date ) {
echo '<script>' . 'document.getElementById("bulletin_date_value").innerHTML = date1s;'.'</script>';
echo '<script>' . 'document.getElementById("24_date_value").innerHTML = date2s;'.'</script>';
echo '<script>' . 'document.getElementById("48_date_value").innerHTML = date3s;'.'</script>';
echo '<script>' . 'document.getElementById("72_date_value").innerHTML = date4s;'.'</script>';
echo '<script>' . 'document.getElementById("96_date_value").innerHTML = date5s;'.'</script>';
 }
?>


<tbody>

<!-- ++++++++++++++++++++++++++++++++++++++++++++ -->

<tr>
<th bgcolor="aquamarine" text-align:right > TS-Diagrams </th>

<!-- +++++++++++++++++++++ Day 1 ++++++++++++++++++ -->

<td style="color:red"> 
Grado: &nbsp; &nbsp; &nbsp; &nbsp;
<a href="./FORECAST/f_d1/tsdiagram_Grado_00.30.png" target="_blank"  title="TS-Diagram near Grado-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d1/tsdiagram_Grado_06.30.png" target="_blank"  title="TS-Diagram near Grado-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d1/tsdiagram_Grado_12.30.png" target="_blank"  title="TS-Diagram near Grado-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d1/tsdiagram_Grado_18.30.png" target="_blank"  title="TS-Diagram near Grado-diffusor at 18:30">18:30</a>
<br> 
Lignano:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<a href="./FORECAST/f_d1/tsdiagram_Lignano_00.30.png" target="_blank"  title="TS-Diagram near Lignano-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d1/tsdiagram_Lignano_06.30.png" target="_blank"  title="TS-Diagram near Lignano-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d1/tsdiagram_Lignano_12.30.png" target="_blank"  title="TS-Diagram near Lignano-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d1/tsdiagram_Lignano_18.30.png" target="_blank"  title="TS-Diagram near Lignano-diffusor at 18:30">18:30</a>
<br>
Servola:  &nbsp; &nbsp; &nbsp;
<a href="./FORECAST/f_d1/tsdiagram_Servola_00.30.png" target="_blank"  title="TS-Diagram near Servola-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d1/tsdiagram_Servola_06.30.png" target="_blank"  title="TS-Diagram near Servola-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d1/tsdiagram_Servola_12.30.png" target="_blank"  title="TS-Diagram near Servola-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d1/tsdiagram_Servola_18.30.png" target="_blank"  title="TS-Diagram near Servola-diffusor at 18:30">18:30</a>
<br>
Staranzano:
<a href="./FORECAST/f_d1/tsdiagram_Staranzano_00.30.png"  target="_blank"  title="TS-Diagram near Staranzano-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d1/tsdiagram_Staranzano_06.30.png"  target="_blank"  title="TS-Diagram near Staranzano-diffusor at 00:30">06:30</a>
<a href="./FORECAST/f_d1/tsdiagram_Staranzano_12.30.png"  target="_blank"  title="TS-Diagram near Staranzano-diffusor at 00:30">12:30</a>
<a href="./FORECAST/f_d1/tsdiagram_Staranzano_18.30.png"  target="_blank"  title="TS-Diagram near Staranzano-diffusor at 00:30">18:30</a>
</td>

<!-- +++++++++++++++++++++ Day 2 ++++++++++++++++++ -->

<td>
<a href="./FORECAST/f_d2/tsdiagram_Grado_00.30.png" target="_blank"  title="TS-Diagram near Grado-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d2/tsdiagram_Grado_06.30.png" target="_blank"  title="TS-Diagram near Grado-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d2/tsdiagram_Grado_12.30.png" target="_blank"  title="TS-Diagram near Grado-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d2/tsdiagram_Grado_18.30.png" target="_blank"  title="TS-Diagram near Grado-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d2/tsdiagram_Lignano_00.30.png" target="_blank"  title="TS-Diagram near Lignano-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d2/tsdiagram_Lignano_06.30.png" target="_blank"  title="TS-Diagram near Lignano-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d2/tsdiagram_Lignano_12.30.png" target="_blank"  title="TS-Diagram near Lignano-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d2/tsdiagram_Lignano_18.30.png" target="_blank"  title="TS-Diagram near Lignano-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d2/tsdiagram_Servola_00.30.png" target="_blank"  title="TS-Diagram near Servola-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d2/tsdiagram_Servola_06.30.png" target="_blank"  title="TS-Diagram near Servola-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d2/tsdiagram_Servola_12.30.png" target="_blank"  title="TS-Diagram near Servola-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d2/tsdiagram_Servola_18.30.png" target="_blank"  title="TS-Diagram near Servola-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d2/tsdiagram_Staranzano_00.30.png"  target="_blank"  title="TS-Diagram near Staranzano-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d2/tsdiagram_Staranzano_06.30.png"  target="_blank"  title="TS-Diagram near Staranzano-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d2/tsdiagram_Staranzano_12.30.png"  target="_blank"  title="TS-Diagram near Staranzano-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d2/tsdiagram_Staranzano_18.30.png"  target="_blank"  title="TS-Diagram near Staranzano-diffusor at 18:30">18:30</a>
</td>

<!-- +++++++++++++++++++++ Day 3 ++++++++++++++++++ -->

<td>
<a href="./FORECAST/f_d3/tsdiagram_Grado_00.30.png" target="_blank"  title="TS-Diagram near Grado-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d3/tsdiagram_Grado_06.30.png" target="_blank"  title="TS-Diagram near Grado-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d3/tsdiagram_Grado_12.30.png" target="_blank"  title="TS-Diagram near Grado-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d3/tsdiagram_Grado_18.30.png" target="_blank"  title="TS-Diagram near Grado-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d3/tsdiagram_Lignano_00.30.png" target="_blank"  title="TS-Diagram near Lignano-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d3/tsdiagram_Lignano_06.30.png" target="_blank"  title="TS-Diagram near Lignano-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d3/tsdiagram_Lignano_12.30.png" target="_blank"  title="TS-Diagram near Lignano-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d3/tsdiagram_Lignano_18.30.png" target="_blank"  title="TS-Diagram near Lignano-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d3/tsdiagram_Servola_00.30.png" target="_blank"  title="TS-Diagram near Servola-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d3/tsdiagram_Servola_06.30.png" target="_blank"  title="TS-Diagram near Servola-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d3/tsdiagram_Servola_12.30.png" target="_blank"  title="TS-Diagram near Servola-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d3/tsdiagram_Servola_18.30.png" target="_blank"  title="TS-Diagram near Servola-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d3/tsdiagram_Staranzano_00.30.png"  target="_blank"  title="TS-Diagram near Staranzano-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d3/tsdiagram_Staranzano_06.30.png"  target="_blank"  title="TS-Diagram near Staranzano-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d3/tsdiagram_Staranzano_12.30.png"  target="_blank"  title="TS-Diagram near Staranzano-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d3/tsdiagram_Staranzano_18.30.png"  target="_blank"  title="TS-Diagram near Staranzano-diffusor at 18:30">18:30</a>
</td>

<!-- +++++++++++++++++++++ Day 4 ++++++++++++++++++ -->

<td>
<a href="./FORECAST/f_d4/tsdiagram_Grado_00.30.png" target="_blank"  title="TS-Diagram near Grado-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d4/tsdiagram_Grado_06.30.png" target="_blank"  title="TS-Diagram near Grado-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d4/tsdiagram_Grado_12.30.png" target="_blank"  title="TS-Diagram near Grado-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d4/tsdiagram_Grado_18.30.png" target="_blank"  title="TS-Diagram near Grado-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d4/tsdiagram_Lignano_00.30.png" target="_blank"  title="TS-Diagram near Lignano-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d4/tsdiagram_Lignano_06.30.png" target="_blank"  title="TS-Diagram near Lignano-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d4/tsdiagram_Lignano_12.30.png" target="_blank"  title="TS-Diagram near Lignano-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d4/tsdiagram_Lignano_18.30.png" target="_blank"  title="TS-Diagram near Lignano-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d4/tsdiagram_Servola_00.30.png" target="_blank"  title="TS-Diagram near Servola-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d4/tsdiagram_Servola_06.30.png" target="_blank"  title="TS-Diagram near Servola-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d4/tsdiagram_Servola_12.30.png" target="_blank"  title="TS-Diagram near Servola-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d4/tsdiagram_Servola_18.30.png" target="_blank"  title="TS-Diagram near Servola-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d4/tsdiagram_Staranzano_00.30.png"  target="_blank"  title="TS-Diagram near Staranzano-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d4/tsdiagram_Staranzano_06.30.png"  target="_blank"  title="TS-Diagram near Staranzano-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d4/tsdiagram_Staranzano_12.30.png"  target="_blank"  title="TS-Diagram near Staranzano-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d4/tsdiagram_Staranzano_18.30.png"  target="_blank"  title="TS-Diagram near Staranzano-diffusor at 18:30">18:30</a>
</td>

<!-- +++++++++++++++++++++ Day 5 ++++++++++++++++++ -->

<td>
<a href="./FORECAST/f_d5/tsdiagram_Grado_00.30.png" target="_blank"  title="TS-Diagram near Grado-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d5/tsdiagram_Grado_06.30.png" target="_blank"  title="TS-Diagram near Grado-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d5/tsdiagram_Grado_12.30.png" target="_blank"  title="TS-Diagram near Grado-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d5/tsdiagram_Grado_18.30.png" target="_blank"  title="TS-Diagram near Grado-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d5/tsdiagram_Lignano_00.30.png" target="_blank"  title="TS-Diagram near Lignano-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d5/tsdiagram_Lignano_06.30.png" target="_blank"  title="TS-Diagram near Lignano-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d5/tsdiagram_Lignano_12.30.png" target="_blank"  title="TS-Diagram near Lignano-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d5/tsdiagram_Lignano_18.30.png" target="_blank"  title="TS-Diagram near Lignano-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d5/tsdiagram_Servola_00.30.png" target="_blank"  title="TS-Diagram near Servola-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d5/tsdiagram_Servola_06.30.png" target="_blank"  title="TS-Diagram near Servola-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d5/tsdiagram_Servola_12.30.png" target="_blank"  title="TS-Diagram near Servola-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d5/tsdiagram_Servola_18.30.png" target="_blank"  title="TS-Diagram near Servola-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d5/tsdiagram_Staranzano_00.30.png"  target="_blank"  title="TS-Diagram near Staranzano-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d5/tsdiagram_Staranzano_06.30.png"  target="_blank"  title="TS-Diagram near Staranzano-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d5/tsdiagram_Staranzano_12.30.png"  target="_blank"  title="TS-Diagram near Staranzano-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d5/tsdiagram_Staranzano_18.30.png"  target="_blank"  title="TS-Diagram near Staranzano-diffusor at 18:30">18:30</a>
</td>


</tr>
<!-- ++++++++++++++++++++++++++++++++++++++++++++ -->

<tr>
<th bgcolor="chartreuse"> Contour-Velocity </th>

<td style="text-align:center">
<a href="./FORECAST/f_d1/cn_velocity_01.gif" target="_blank"  title="Daily contour velocity at 1.02 m depth">1.0 m Depth</a>
<a href="./FORECAST/f_d1/cn_velocity_04.gif" target="_blank"  title="Daily contour velocity at 7.02 m depth">7.9 m Depth</a>
</td>

<td>
<a href="./FORECAST/f_d2/cn_velocity_01.gif" target="_blank"  title="Daily contour velocity at 1.02 m depth">1.0 m Depth</a>
<a href="./FORECAST/f_d2/cn_velocity_04.gif" target="_blank"  title="Daily contour velocity at 7.02 m depth">7.9 m Depth</a>
</td>

<td>
<a href="./FORECAST/f_d3/cn_velocity_01.gif" target="_blank"  title="Daily contour velocity at 1.02 m depth">1.0 m Depth</a>
<a href="./FORECAST/f_d3/cn_velocity_04.gif" target="_blank"  title="Daily contour velocity at 7.02 m depth">7.9 m Depth</a>
</td>

<td>
<a href="./FORECAST/f_d4/cn_velocity_01.gif" target="_blank"  title="Daily contour velocity at 1.02 m depth">1.0 m Depth</a>
<a href="./FORECAST/f_d4/cn_velocity_04.gif" target="_blank"  title="Daily contour velocity at 7.02 m depth">7.9 m Depth</a>
</td>

<td>
<a href="./FORECAST/f_d5/cn_velocity_01.gif" target="_blank"  title="Daily contour velocity at 1.02 m depth">1.0 m Depth</a>
<a href="./FORECAST/f_d5/cn_velocity_04.gif" target="_blank"  title="Daily contour velocity at 7.02 m depth">7.9 m Depth</a>
</td>


</tr>

<!-- +++++++++++++++++++ Streamlines ++++++++++++++++++++++++++++++++ -->


<tr bordercolor="red">
<th bgcolor="sandybrown" > Streamlines  </th>

<td>
<!-- ++++ Grado +++++ -->

<p class="first_cell">Grado:</p>
Depth &nbsp; 1.0 m:
<a href="./FORECAST/f_d1/streamlines_Grado_01_00.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d1/streamlines_Grado_01_06.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d1/streamlines_Grado_01_12.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d1/streamlines_Grado_01_18.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 18:30">18:30</a>
<br>
Depth &nbsp; 5.5 m:
<a href="./FORECAST/f_d1/streamlines_Grado_03_00.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d1/streamlines_Grado_03_06.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d1/streamlines_Grado_03_12.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d1/streamlines_Grado_03_18.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 18:30">18:30</a>
<br>
Depth 10.5 m:
<a href="./FORECAST/f_d1/streamlines_Grado_05_00.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d1/streamlines_Grado_05_06.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d1/streamlines_Grado_05_12.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d1/streamlines_Grado_05_18.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 18:30">18:30</a>
<br>

<!-- ++++ Lignano +++++ -->


<p class="first_cell">Lignano:</p>
Depth &nbsp; 1.0 m:
<a href="./FORECAST/f_d1/streamlines_Lignano_01_00.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d1/streamlines_Lignano_01_06.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d1/streamlines_Lignano_01_12.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d1/streamlines_Lignano_01_18.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 18:30">18:30</a>
<br>
Depth &nbsp; 5.5 m:
<a href="./FORECAST/f_d1/streamlines_Lignano_03_00.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d1/streamlines_Lignano_03_06.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d1/streamlines_Lignano_03_12.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d1/streamlines_Lignano_03_18.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 18:30">18:30</a>
<br>
Depth 10.5 m:
<a href="./FORECAST/f_d1/streamlines_Lignano_05_00.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d1/streamlines_Lignano_05_06.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d1/streamlines_Lignano_05_12.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d1/streamlines_Lignano_05_18.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 18:30">18:30</a>
<br>

<!-- ++++ Servola +++++ -->

<p class="first_cell">Servola:</p>
Depth &nbsp;  1.0 m:
<a href="./FORECAST/f_d1/streamlines_Servola_01_00.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d1/streamlines_Servola_01_06.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d1/streamlines_Servola_01_12.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d1/streamlines_Servola_01_18.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 18:30">18:30</a>
<br>
Depth  &nbsp; 5.5 m:
<a href="./FORECAST/f_d1/streamlines_Servola_03_00.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d1/streamlines_Servola_03_06.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d1/streamlines_Servola_03_12.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d1/streamlines_Servola_03_18.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 18:30">18:30</a>
<br>
Depth 13.3 m:
<a href="./FORECAST/f_d1/streamlines_Servola_06_00.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d1/streamlines_Servola_06_06.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d1/streamlines_Servola_06_12.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d1/streamlines_Servola_06_18.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 18:30">18:30</a>
<br>

<!-- ++++ Staranzano +++++ -->

<p class="first_cell">Staranzano:</p>
Depth &nbsp; 1.0 m:
<a href="./FORECAST/f_d1/streamlines_Staranzano_01_00.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d1/streamlines_Staranzano_01_06.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d1/streamlines_Staranzano_01_12.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d1/streamlines_Staranzano_01_18.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 18:30">18:30</a>
<br>
Depth &nbsp; 5.5 m:
<a href="./FORECAST/f_d1/streamlines_Staranzano_03_00.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d1/streamlines_Staranzano_03_06.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d1/streamlines_Staranzano_03_12.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d1/streamlines_Staranzano_03_18.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 18:30">18:30</a>
<br>
Depth &nbsp; 7.9 m:
<a href="./FORECAST/f_d1/streamlines_Staranzano_04_00.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d1/streamlines_Staranzano_04_06.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d1/streamlines_Staranzano_04_12.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d1/streamlines_Staranzano_04_18.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 18:30">18:30</a>
<br>

</td>

<!-- ++++++++++++++++++ Durrent day ++++++++++++++++++++++++++ -->

<td>

<!-- ++++ Grado +++++ -->

<p class="first_cell">Grado:</p>
<a href="./FORECAST/f_d2/streamlines_Grado_01_00.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d2/streamlines_Grado_01_06.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d2/streamlines_Grado_01_12.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d2/streamlines_Grado_01_18.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d2/streamlines_Grado_03_00.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d2/streamlines_Grado_03_06.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d2/streamlines_Grado_03_12.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d2/streamlines_Grado_03_18.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d2/streamlines_Grado_05_00.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d2/streamlines_Grado_05_06.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d2/streamlines_Grado_05_12.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d2/streamlines_Grado_05_18.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 18:30">18:30</a>
<br>

<!-- ++++ Lignano +++++ -->


<p class="first_cell">Lignano:</p>
<a href="./FORECAST/f_d2/streamlines_Lignano_01_00.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d2/streamlines_Lignano_01_06.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d2/streamlines_Lignano_01_12.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d2/streamlines_Lignano_01_18.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d2/streamlines_Lignano_03_00.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d2/streamlines_Lignano_03_06.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d2/streamlines_Lignano_03_12.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d2/streamlines_Lignano_03_18.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d2/streamlines_Lignano_05_00.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d2/streamlines_Lignano_05_06.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d2/streamlines_Lignano_05_12.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d2/streamlines_Lignano_05_18.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 18:30">18:30</a>
<br>

<!-- ++++ Servola +++++ -->

<p class="first_cell">Servola:</p>
<a href="./FORECAST/f_d2/streamlines_Servola_01_00.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d2/streamlines_Servola_01_06.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d2/streamlines_Servola_01_12.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d2/streamlines_Servola_01_18.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d2/streamlines_Servola_03_00.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d2/streamlines_Servola_03_06.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d2/streamlines_Servola_03_12.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d2/streamlines_Servola_03_18.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d2/streamlines_Servola_06_00.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d2/streamlines_Servola_06_06.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d2/streamlines_Servola_06_12.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d2/streamlines_Servola_06_18.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 18:30">18:30</a>
<br>


<!-- ++++ Staranzano +++++ -->

<p class="first_cell">Staranzano:</p>
<a href="./FORECAST/f_d2/streamlines_Staranzano_01_00.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d2/streamlines_Staranzano_01_06.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d2/streamlines_Staranzano_01_12.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d2/streamlines_Staranzano_01_18.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d2/streamlines_Staranzano_03_00.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d2/streamlines_Staranzano_03_06.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d2/streamlines_Staranzano_03_12.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d2/streamlines_Staranzano_03_18.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d2/streamlines_Staranzano_04_00.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d2/streamlines_Staranzano_04_06.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d2/streamlines_Staranzano_04_12.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d2/streamlines_Staranzano_04_18.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 18:30">18:30</a>
<br>

</td>


<!-- ++++++++++++++++++ Day 3 ++++++++++++++++++++++++++++ -->

<td>

<!-- ++++ Grado +++++ -->

<p class="first_cell">Grado:</p>
<a href="./FORECAST/f_d3/streamlines_Grado_01_00.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d3/streamlines_Grado_01_06.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d3/streamlines_Grado_01_12.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d3/streamlines_Grado_01_18.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d3/streamlines_Grado_03_00.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d3/streamlines_Grado_03_06.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d3/streamlines_Grado_03_12.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d3/streamlines_Grado_03_18.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d3/streamlines_Grado_05_00.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d3/streamlines_Grado_05_06.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d3/streamlines_Grado_05_12.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d3/streamlines_Grado_05_18.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 18:30">18:30</a>
<br>


<!-- ++++ Lignano +++++ -->

<p class="first_cell">Lignano:</p>
<a href="./FORECAST/f_d3/streamlines_Lignano_01_00.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d3/streamlines_Lignano_01_06.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d3/streamlines_Lignano_01_12.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d3/streamlines_Lignano_01_18.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d3/streamlines_Lignano_03_00.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d3/streamlines_Lignano_03_06.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d3/streamlines_Lignano_03_12.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d3/streamlines_Lignano_03_18.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d3/streamlines_Lignano_05_00.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d3/streamlines_Lignano_05_06.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d3/streamlines_Lignano_05_12.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d3/streamlines_Lignano_05_18.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 18:30">18:30</a>
<br>


<!-- ++++ Servola +++++ -->
 
<p class="first_cell">Servola:</p>
<a href="./FORECAST/f_d3/streamlines_Servola_01_00.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d3/streamlines_Servola_01_06.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d3/streamlines_Servola_01_12.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d3/streamlines_Servola_01_18.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d3/streamlines_Servola_03_00.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d3/streamlines_Servola_03_06.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d3/streamlines_Servola_03_12.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d3/streamlines_Servola_03_18.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d3/streamlines_Servola_06_00.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d3/streamlines_Servola_06_06.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d3/streamlines_Servola_06_12.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d3/streamlines_Servola_06_18.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 18:30">18:30</a>
<br>


<!-- ++++ Staranzano +++++ -->

<p class="first_cell">Staranzano:</p>
<a href="./FORECAST/f_d3/streamlines_Staranzano_01_00.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d3/streamlines_Staranzano_01_06.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d3/streamlines_Staranzano_01_12.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d3/streamlines_Staranzano_01_18.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d3/streamlines_Staranzano_03_00.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d3/streamlines_Staranzano_03_06.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d3/streamlines_Staranzano_03_12.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d3/streamlines_Staranzano_03_18.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d3/streamlines_Staranzano_04_00.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d3/streamlines_Staranzano_04_06.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d3/streamlines_Staranzano_04_12.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d3/streamlines_Staranzano_04_18.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 18:30">18:30</a>
<br>

</td>


<!-- +++++++++++++++++++++++++++++  Day 4 +++++++++++++++++++++++++++++++ -->

<td>

<!-- ++++ Grado +++++ -->

<p class="first_cell">Grado:</p>
<a href="./FORECAST/f_d4/streamlines_Grado_01_00.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d4/streamlines_Grado_01_06.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d4/streamlines_Grado_01_12.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d4/streamlines_Grado_01_18.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d4/streamlines_Grado_03_00.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d4/streamlines_Grado_03_06.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d4/streamlines_Grado_03_12.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d4/streamlines_Grado_03_18.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d4/streamlines_Grado_05_00.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d4/streamlines_Grado_05_06.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d4/streamlines_Grado_05_12.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d4/streamlines_Grado_05_18.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 18:30">18:30</a>
<br>


<!-- ++++ Lignano +++++ -->

<p class="first_cell">Lignano:</p>
<a href="./FORECAST/f_d4/streamlines_Lignano_01_00.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d4/streamlines_Lignano_01_06.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d4/streamlines_Lignano_01_12.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d4/streamlines_Lignano_01_18.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d4/streamlines_Lignano_03_00.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d4/streamlines_Lignano_03_06.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d4/streamlines_Lignano_03_12.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d4/streamlines_Lignano_03_18.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d4/streamlines_Lignano_05_00.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d4/streamlines_Lignano_05_06.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d4/streamlines_Lignano_05_12.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d4/streamlines_Lignano_05_18.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 18:30">18:30</a>
<br>


<!-- ++++ Servola +++++ -->

<p class="first_cell">Servola:</p>
<a href="./FORECAST/f_d4/streamlines_Servola_01_00.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d4/streamlines_Servola_01_06.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d4/streamlines_Servola_01_12.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d4/streamlines_Servola_01_18.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d4/streamlines_Servola_03_00.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d4/streamlines_Servola_03_06.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d4/streamlines_Servola_03_12.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d4/streamlines_Servola_03_18.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d4/streamlines_Servola_06_00.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d4/streamlines_Servola_06_06.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d4/streamlines_Servola_06_12.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d4/streamlines_Servola_06_18.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 18:30">18:30</a>
<br>


<!-- ++++ Staranzano +++++ -->

<p class="first_cell">Staranzano:</p>
<a href="./FORECAST/f_d4/streamlines_Staranzano_01_00.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d4/streamlines_Staranzano_01_06.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d4/streamlines_Staranzano_01_12.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d4/streamlines_Staranzano_01_18.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d4/streamlines_Staranzano_03_00.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d4/streamlines_Staranzano_03_06.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d4/streamlines_Staranzano_03_12.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d4/streamlines_Staranzano_03_18.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d4/streamlines_Staranzano_04_00.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d4/streamlines_Staranzano_04_06.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d4/streamlines_Staranzano_04_12.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d4/streamlines_Staranzano_04_18.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 18:30">18:30</a>
<br>


</td>

<!-- +++++++++++++++++++++++++++   Day 5    +++++++++++++++++++++++++++ -->


<td>

<!-- ++++ Grado +++++ -->

<p class="first_cell">Grado:</p>
<a href="./FORECAST/f_d5/streamlines_Grado_01_00.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d5/streamlines_Grado_01_06.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d5/streamlines_Grado_01_12.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d5/streamlines_Grado_01_18.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d5/streamlines_Grado_03_00.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d5/streamlines_Grado_03_06.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d5/streamlines_Grado_03_12.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d5/streamlines_Grado_03_18.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d5/streamlines_Grado_05_00.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d5/streamlines_Grado_05_06.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d5/streamlines_Grado_05_12.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d5/streamlines_Grado_05_18.30.png"  target="_blank"  title="Streamlines near Grado-diffusor at 18:30">18:30</a>
<br>


<!-- ++++ Lignano +++++ -->

<p class="first_cell">Lignano:</p>
<a href="./FORECAST/f_d5/streamlines_Lignano_01_00.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d5/streamlines_Lignano_01_06.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d5/streamlines_Lignano_01_12.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d5/streamlines_Lignano_01_18.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d5/streamlines_Lignano_03_00.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d5/streamlines_Lignano_03_06.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d5/streamlines_Lignano_03_12.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d5/streamlines_Lignano_03_18.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d5/streamlines_Lignano_05_00.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d5/streamlines_Lignano_05_06.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d5/streamlines_Lignano_05_12.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d5/streamlines_Lignano_05_18.30.png"  target="_blank"  title="Streamlines near Lignano-diffusor at 18:30">18:30</a>
<br>


<!-- ++++ Servola +++++ -->

<p class="first_cell">Servola:</p>
<a href="./FORECAST/f_d5/streamlines_Servola_01_00.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d5/streamlines_Servola_01_06.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d5/streamlines_Servola_01_12.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d5/streamlines_Servola_01_18.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d5/streamlines_Servola_03_00.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d5/streamlines_Servola_03_06.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d5/streamlines_Servola_03_12.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d5/streamlines_Servola_03_18.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d5/streamlines_Servola_06_00.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d5/streamlines_Servola_06_06.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d5/streamlines_Servola_06_12.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d5/streamlines_Servola_06_18.30.png"  target="_blank"  title="Streamlines near Servola-diffusor at 18:30">18:30</a>
<br>


<!-- ++++ Staranzano +++++ -->

<p class="first_cell">Staranzano:</p>
<a href="./FORECAST/f_d5/streamlines_Staranzano_01_00.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d5/streamlines_Staranzano_01_06.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d5/streamlines_Staranzano_01_12.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d5/streamlines_Staranzano_01_18.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d5/streamlines_Staranzano_03_00.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d5/streamlines_Staranzano_03_06.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d5/streamlines_Staranzano_03_12.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d5/streamlines_Staranzano_03_18.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 18:30">18:30</a>
<br>
<a href="./FORECAST/f_d5/streamlines_Staranzano_04_00.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 00:30">00:30</a>
<a href="./FORECAST/f_d5/streamlines_Staranzano_04_06.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 06:30">06:30</a>
<a href="./FORECAST/f_d5/streamlines_Staranzano_04_12.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 12:30">12:30</a>
<a href="./FORECAST/f_d5/streamlines_Staranzano_04_18.30.png"  target="_blank"  title="Streamlines near Staranzano-diffusor at 18:30">18:30</a>
<br>


</td>

</tr>

<!-- ++++++++++++++++++++++++++++++++++++++++++++ -->


</tbody>
</table>

</body>


 <div  style="font-size: 10px">
            <p    style="text-align:center; color:black" >
               ARPA FVG - Via Cairoli, 14 - 33057 Palmanova (UD)<br>
               Tel +39 0432 1918111 - Fax +39 0432 1918120 - C.F. P.IVA 02096520305<br>
            </p>
        </div>

</html>
