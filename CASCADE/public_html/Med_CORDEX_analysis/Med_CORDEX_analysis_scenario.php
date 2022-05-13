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
                padding: 10px;
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

<body bgcolor="#AFFFFF" >  

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

<!-- +++++++++++++++++++++++++++      MAPS      ++++++++++++++++++++++++++++++++ -->
<br><br><br><br><br>

<pre><font face="Times New Roman" size="4">      Boundary and internal Points: </font>  </pre>
<a href="./logos/map_SHYFEM_BC_points.png" target="_blank" title="Boundary and internal Points">
<img src="./logos/map_SHYFEM_BC_points.png" alt="Boundary and internal Points" style="float:left;width:450px;height:396px;">
</a>

<br><br><br><br><br> <br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>

<!-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
 
<table align="center">

<caption class="titleDiv" style="font-size:2vw"> Med-CORDEX data file scenario analysis</caption>


<thead bgcolor="gainsboro">
<tr>
<!-- +++++++++++++++ first cell +++++++++++++++++++ -->

<th align="center" > <p class="first_cell"> Model </p> </th> 

<!-- +++++++++++++ end of first cell +++++++++++++++++ -->

<th>  <p  class="myClass" > 2025÷2035    </p>  </th> 
<th>  <p  class="myClass" > 2035÷2045    </p>  </th> 
<th>  <p  class="myClass" > 2045÷2055    </p>  </th> 
<th>  <p  class="myClass" > 2055÷2065    </p>  </th> 
<th>  <p  class="myClass" > 2065÷2075    </p>  </th> 
<th>  <p  class="myClass" > 2075÷2085    </p>  </th>
<th>  <p  class="myClass" > 2085÷2095    </p>  </th>
</tr> 
</thead>

<tbody>
<!-- chartreuse for rcp 2.6 yellow for 4.5  and red for 8.5 -->
<!-- ================================================================ -->  
<!-- ========================= CMCC-CM_COSMOMED ===================== -->
<!-- ================================================================ -->

<tr>
<th bgcolor="yellow" text-align:center > CMCC-CM_COSMOMED ( RCP 4.5 )</th>

<!-- +++++++++++++++++++++ 2025-2035 ++++++++++++++++++ -->

<td style="color:red">
Temp:
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B01/sdim_boxplot_temp_B01_CMCC-CM_COSMOMED_rcp45_v1_2025_2035.png"  target="_blank" >B01</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B02/sdim_boxplot_temp_B02_CMCC-CM_COSMOMED_rcp45_v1_2025_2035.png"  target="_blank" >B02</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B03/sdim_boxplot_temp_B03_CMCC-CM_COSMOMED_rcp45_v1_2025_2035.png"  target="_blank" >B03</a> <br>
Sal: 
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B01/sdim_boxplot_sal_B01_CMCC-CM_COSMOMED_rcp45_v1_2025_2035.png"  target="_blank" >B01</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B02/sdim_boxplot_sal_B02_CMCC-CM_COSMOMED_rcp45_v1_2025_2035.png"  target="_blank" >B02</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B03/sdim_boxplot_sal_B03_CMCC-CM_COSMOMED_rcp45_v1_2025_2035.png"  target="_blank" >B03</a> <br>
zos: 
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B01/sdim_boxplot_zos_B01_CMCC-CM_COSMOMED_rcp45_v1_2025_2035.png"  target="_blank" >B01</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B02/sdim_boxplot_zos_B02_CMCC-CM_COSMOMED_rcp45_v1_2025_2035.png"  target="_blank" >B02</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B03/sdim_boxplot_zos_B03_CMCC-CM_COSMOMED_rcp45_v1_2025_2035.png"  target="_blank" >B03</a> <br>
</td>

<!-- +++++++++++++++++++++ 2035-2045 ++++++++++++++++++ -->

<td style="color:red">
Temp:
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B01/sdim_boxplot_temp_B01_CMCC-CM_COSMOMED_rcp45_v1_2035_2045.png"  target="_blank" >B01</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B02/sdim_boxplot_temp_B02_CMCC-CM_COSMOMED_rcp45_v1_2035_2045.png"  target="_blank" >B02</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B03/sdim_boxplot_temp_B03_CMCC-CM_COSMOMED_rcp45_v1_2035_2045.png"  target="_blank" >B03</a> <br>
Sal:
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B01/sdim_boxplot_sal_B01_CMCC-CM_COSMOMED_rcp45_v1_2035_2045.png"  target="_blank" >B01</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B02/sdim_boxplot_sal_B02_CMCC-CM_COSMOMED_rcp45_v1_2035_2045.png"  target="_blank" >B02</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B03/sdim_boxplot_sal_B03_CMCC-CM_COSMOMED_rcp45_v1_2035_2045.png"  target="_blank" >B03</a> <br>
zos:
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B01/sdim_boxplot_zos_B01_CMCC-CM_COSMOMED_rcp45_v1_2035_2045.png"  target="_blank" >B01</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B02/sdim_boxplot_zos_B02_CMCC-CM_COSMOMED_rcp45_v1_2035_2045.png"  target="_blank" >B02</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B03/sdim_boxplot_zos_B03_CMCC-CM_COSMOMED_rcp45_v1_2035_2045.png"  target="_blank" >B03</a> <br>
</td>

<!-- +++++++++++++++++++++ 2045-2055 ++++++++++++++++++ -->

<td style="color:red">
Temp:
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B01/sdim_boxplot_temp_B01_CMCC-CM_COSMOMED_rcp45_v1_2045_2055.png"  target="_blank" >B01</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B02/sdim_boxplot_temp_B02_CMCC-CM_COSMOMED_rcp45_v1_2045_2055.png"  target="_blank" >B02</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B03/sdim_boxplot_temp_B03_CMCC-CM_COSMOMED_rcp45_v1_2045_2055.png"  target="_blank" >B03</a> <br>
Sal:
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B01/sdim_boxplot_sal_B01_CMCC-CM_COSMOMED_rcp45_v1_2045_2055.png"  target="_blank" >B01</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B02/sdim_boxplot_sal_B02_CMCC-CM_COSMOMED_rcp45_v1_2045_2055.png"  target="_blank" >B02</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B03/sdim_boxplot_sal_B03_CMCC-CM_COSMOMED_rcp45_v1_2045_2055.png"  target="_blank" >B03</a> <br>
zos:
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B01/sdim_boxplot_zos_B01_CMCC-CM_COSMOMED_rcp45_v1_2045_2055.png"  target="_blank" >B01</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B02/sdim_boxplot_zos_B02_CMCC-CM_COSMOMED_rcp45_v1_2045_2055.png"  target="_blank" >B02</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B03/sdim_boxplot_zos_B03_CMCC-CM_COSMOMED_rcp45_v1_2045_2055.png"  target="_blank" >B03</a> <br>
</td>

<!-- +++++++++++++++++++++ 2055-2065 ++++++++++++++++++ -->

<td style="color:red">
Temp:
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B01/sdim_boxplot_temp_B01_CMCC-CM_COSMOMED_rcp45_v1_2055_2065.png"  target="_blank" >B01</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B02/sdim_boxplot_temp_B02_CMCC-CM_COSMOMED_rcp45_v1_2055_2065.png"  target="_blank" >B02</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B03/sdim_boxplot_temp_B03_CMCC-CM_COSMOMED_rcp45_v1_2055_2065.png"  target="_blank" >B03</a> <br>
Sal:
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B01/sdim_boxplot_sal_B01_CMCC-CM_COSMOMED_rcp45_v1_2055_2065.png"  target="_blank" >B01</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B02/sdim_boxplot_sal_B02_CMCC-CM_COSMOMED_rcp45_v1_2055_2065.png"  target="_blank" >B02</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B03/sdim_boxplot_sal_B03_CMCC-CM_COSMOMED_rcp45_v1_2055_2065.png"  target="_blank" >B03</a> <br>
zos:
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B01/sdim_boxplot_zos_B01_CMCC-CM_COSMOMED_rcp45_v1_2055_2065.png"  target="_blank" >B01</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B02/sdim_boxplot_zos_B02_CMCC-CM_COSMOMED_rcp45_v1_2055_2065.png"  target="_blank" >B02</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B03/sdim_boxplot_zos_B03_CMCC-CM_COSMOMED_rcp45_v1_2055_2065.png"  target="_blank" >B03</a> <br>
</td>
<!-- +++++++++++++++++++++ 2065-2075 ++++++++++++++++++ -->
<td style="color:red">
Temp:
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B01/sdim_boxplot_temp_B01_CMCC-CM_COSMOMED_rcp45_v1_2065_2075.png"  target="_blank" >B01</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B02/sdim_boxplot_temp_B02_CMCC-CM_COSMOMED_rcp45_v1_2065_2075.png"  target="_blank" >B02</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B03/sdim_boxplot_temp_B03_CMCC-CM_COSMOMED_rcp45_v1_2065_2075.png"  target="_blank" >B03</a> <br>
Sal:
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B01/sdim_boxplot_sal_B01_CMCC-CM_COSMOMED_rcp45_v1_2065_2075.png"  target="_blank" >B01</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B02/sdim_boxplot_sal_B02_CMCC-CM_COSMOMED_rcp45_v1_2065_2075.png"  target="_blank" >B02</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B03/sdim_boxplot_sal_B03_CMCC-CM_COSMOMED_rcp45_v1_2065_2075.png"  target="_blank" >B03</a> <br>
zos:
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B01/sdim_boxplot_zos_B01_CMCC-CM_COSMOMED_rcp45_v1_2065_2075.png"  target="_blank" >B01</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B02/sdim_boxplot_zos_B02_CMCC-CM_COSMOMED_rcp45_v1_2065_2075.png"  target="_blank" >B02</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B03/sdim_boxplot_zos_B03_CMCC-CM_COSMOMED_rcp45_v1_2065_2075.png"  target="_blank" >B03</a> <br>
</td>
<!-- +++++++++++++++++++++ 2075-2085 ++++++++++++++++++ -->
<td style="color:red">
Temp:
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B01/sdim_boxplot_temp_B01_CMCC-CM_COSMOMED_rcp45_v1_2075_2085.png"  target="_blank" >B01</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B02/sdim_boxplot_temp_B02_CMCC-CM_COSMOMED_rcp45_v1_2075_2085.png"  target="_blank" >B02</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B03/sdim_boxplot_temp_B03_CMCC-CM_COSMOMED_rcp45_v1_2075_2085.png"  target="_blank" >B03</a> <br>
Sal:
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B01/sdim_boxplot_sal_B01_CMCC-CM_COSMOMED_rcp45_v1_2075_2085.png"  target="_blank" >B01</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B02/sdim_boxplot_sal_B02_CMCC-CM_COSMOMED_rcp45_v1_2075_2085.png"  target="_blank" >B02</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B03/sdim_boxplot_sal_B03_CMCC-CM_COSMOMED_rcp45_v1_2075_2085.png"  target="_blank" >B03</a> <br>
zos:
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B01/sdim_boxplot_zos_B01_CMCC-CM_COSMOMED_rcp45_v1_2075_2085.png"  target="_blank" >B01</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B02/sdim_boxplot_zos_B02_CMCC-CM_COSMOMED_rcp45_v1_2075_2085.png"  target="_blank" >B02</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B03/sdim_boxplot_zos_B03_CMCC-CM_COSMOMED_rcp45_v1_2075_2085.png"  target="_blank" >B03</a> <br>
</td>
<!-- +++++++++++++++++++++ 2085-2095 ++++++++++++++++++ -->
<td style="color:red">
Temp:
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B01/sdim_boxplot_temp_B01_CMCC-CM_COSMOMED_rcp45_v1_2085_2095.png"  target="_blank" >B01</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B02/sdim_boxplot_temp_B02_CMCC-CM_COSMOMED_rcp45_v1_2085_2095.png"  target="_blank" >B02</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B03/sdim_boxplot_temp_B03_CMCC-CM_COSMOMED_rcp45_v1_2085_2095.png"  target="_blank" >B03</a> <br>
Sal:
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B01/sdim_boxplot_sal_B01_CMCC-CM_COSMOMED_rcp45_v1_2085_2095.png"  target="_blank" >B01</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B02/sdim_boxplot_sal_B02_CMCC-CM_COSMOMED_rcp45_v1_2085_2095.png"  target="_blank" >B02</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B03/sdim_boxplot_sal_B03_CMCC-CM_COSMOMED_rcp45_v1_2085_2095.png"  target="_blank" >B03</a> <br>
zos:
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B01/sdim_boxplot_zos_B01_CMCC-CM_COSMOMED_rcp45_v1_2085_2095.png"  target="_blank" >B01</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B02/sdim_boxplot_zos_B02_CMCC-CM_COSMOMED_rcp45_v1_2085_2095.png"  target="_blank" >B02</a>
<a href="./SCENARIO/boxplot_NCL/CMCC-CM_COSMOMED/B03/sdim_boxplot_zos_B03_CMCC-CM_COSMOMED_rcp45_v1_2085_2095.png"  target="_blank" >B03</a> <br>
</td>
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++ -->
</tr>

</tr>


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
