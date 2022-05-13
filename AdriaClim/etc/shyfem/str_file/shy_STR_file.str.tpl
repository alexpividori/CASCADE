--------------------------------------------------------
                SECTION TITLE and GRID
--------------------------------------------------------
$title
	%%SHY_SIM_DESCRIPTION%%
	%%SHY_SIM_NAME%%
	%%SHY_BASIN_FILENAME%%
$end

--------------------------------------------------------
                SECTION PARAMETER
--------------------------------------------------------
$para
	idt    = '60s'		idtmin = 0.1

        itanf  = '%%SHY_ITANF%%'        itend  = '%%SHY_ITEND%%'
        itmout = '%%SHY_ITMOUT%%'        idtout = '1h'
        itmcon = '%%SHY_ITMCON%%'        idtcon = '1h'
        itmext = '%%SHY_ITMEXT%%'        idtext = '15m'
        itmflx = '%%SHY_ITMFLX%%'        idtflx = '15m'
        itmrst = '%%SHY_ITMRST%%'        idtrst = %%SHY_IDTRST%%

        itrst = %%SHY_ITRST%%

        date   = %%SHY_DATE%%	time   = 0

        ireib  = 6      czdef  = 0.0025

        ilin   = 0      itlin  = 0      iclin  = 0
        itsplt = 2      idtsyn = '15m'
        coumax = 0.9    rstol  = 0.9
        ampar  = 0.60   azpar  = 0.60   aapar  = 0.

        icor   = 1      isphe  = 1
        href   = 0.     hlvmin = 0.
        iwtype = 1      itdrag = 0      dragco = 0.0025

        iturb  = 1      ibarcl = 1      ievap  = 1
        iheat  = 5      hdecay = 2      botabs = 0

        ihtype = 4

        isalt  = 1      salref = 0      shpar  = 0.1
        itemp  = 1      temref = 0      thpar  = 0.1
        iconz  = 0      conref = 0      chpar  = 0.1

        itvd   = 2      itvdv  = 1

        ilytyp = 3      hlvmin = 0.5
        nomp   = 8

        idhtyp = 2

        netcdf = 1
$end

--------------------------------------------------------
                  SECTION 3D LEVELS
--------------------------------------------------------
$levels
        1.2 2 3 4 5 6 7 8 9 10
        12 14 16 18 20 22 24 26 28 30
        32 35
$end

--------------------------------------------------------
                SECTION BOUNDARY
--------------------------------------------------------
$bound1 ---- Adriatic Sea  ----
        kbound = 12098 13759 13570 13909 13944 13079 13586 13028
		 13029 13724 13038 14044 13995 13996 13999 14046
		 14049 14022 14023 17850 14891 15806 16683 17836 
		 15650 15573 15434 15433 15171 15065 15029 15028 
		 17793 16464 16111 16110 17626 15599 15597 15598 
		 15658 16674 17821 16446 18149 14919 14916 14914 
		 14912 14910 14908 
        boundn = 'input/adri/zetan.fem'
        saltn  = 'input/adri/saltn.fem'
        tempn  = 'input/adri/tempn.fem'
        vel3dn = 'input/adri/velon.fem'
	tnudge = 50
$end

---------- NORTH ADRIATIC RIVERS --------------------

$bound2 --- Fiume Mirna (from Cozzi and Giani 2011) ---
       kbound = 18315 18316
       ibtyp  = 2
       zref   = 6.7
       conz   = 0.
       salt   = 0.5
       temp   = -999
       levmax = 2
$end
       boundn = 'input/rivers/mirna.dat'

$bound3 --- Fiume Dragonja (from Cozzi and Giani 2011) ---
       kbound = 18311 18312
       ibtyp  = 2
       zref   = 0.7
       conz   = 0.
       salt   = 0.5
       temp   = -999
       levmax = 2
$end
       boundn = 'input/rivers/dragonja.dat'

$bound4 --- Fiume Drnica (from Cozzi and Giani 2011) ---
       kbound = 14648 14647
       ibtyp  = 2
       zref   = 0.2
       conz   = 0.
       salt   = 0.5
       temp   = -999
       levmax = 2
$end
       boundn = 'input/rivers/drnica.dat'

$bound5 --- Fiume Badasevica (from Cozzi and Giani 2011) ---
       kbound = 14539 18307
       ibtyp  = 2
       zref   = 0.2
       conz   = 0.
       salt   = 0.5
       temp   = -999
       levmax = 2
$end
       boundn = 'input/rivers/badasevica.dat'

$bound6 --- Fiume Rizana (from Cozzi and Giani 2011) ---
       kbound = 14521 14520
       ibtyp  = 2
       zref   = 3.2
       conz   = 0.
       salt   = 0.5
       temp   = -999
       levmax = 2
$end
       boundn = 'input/rivers/rizana.dat'

$bound7 --- Rio Ospo ---
       kbound = 14460 14459
       ibtyp  = 2
       zref   = 0.5
       conz   = 0.
       salt   = 0.5
       temp   = -999
       levmax = 2
$end
       boundn = 'input/rivers/ospo.dat'

$bound8 --- Timavo (from Cozzi and Giani 2011) ---
       kbound = 14305 14304
       ibtyp  = 2
       zref   = 26.
       conz   = 0.
       salt   = 0.5
       temp   = -999
       levmax = 2
$end
       boundn = 'input/rivers/timavo.dat'

$bound9  ---- Fiume Isonzo ---
       kbound = 14177 18306
       ibtyp  = 2
       boundn = 'input/rivers/isonzo.dat'
       conz   = 0.
       temp   = -999
       salt   = 0.5
       nad    = 4
       levmax = 2
$end

$bound10 ---- Fiume Tagliamento ---
       kbound = 13979 13978
       ibtyp  = 2
       boundn = 'input/rivers/tagliamento.dat'
       conz   = 0.
       temp   = -999
       salt   = 0.5
       levmax = 2
$end

$bound11  ---- Canale dei Lovi ---
       kbound = 13389 13405
       ibtyp  = 2
       zref   = 10.
       conz   = 0.
       temp   = -999
       salt   = 0.5
       levmax = 2
$end
       boundn = 'input/rivers/lovi.dat'

$bound12 ---- Canale Nicesolo - Lemene ---
       kbound = 13988 13987
       ibtyp  = 2
       boundn = 'input/rivers/nicesolo_lemene.dat'
       conz   = 0.
       temp   = -999
       salt   = 0.5
       levmax = 2
$end

$bound13 ---- Fiume Livenza + Monticano (from Arpa Veneto, AdriaClim D3.2.1) ---
       kbound = 13982 13983
       ibtyp  = 2
       zref   = 88.3
       conz   = 0.
       temp   = -999
       salt   = 0.5
       levmax = 2
$end
       boundn = 'input/rivers/livenza_monticano.dat'

---------- MARANO AND GRADO LAGOON RIVERS -----------------

$bound14  ---- Fiume Stella ----
        kbound = 11109 11108
        ibtyp  = 2
        boundn = 'input/rivers/stella.dat'
        temp   = -999
        salt   = 0.5
        conz   = 0.
        levmax = 2
$end

$bound15  ---- Fiume Turgnano ----
        kbound = 11217 11216
        ibtyp  = 2
        boundn = 'input/rivers/turgnano.dat'
        temp   = -999
        salt   = 0.5
        conz   = 0.
        levmax = 2
$end

$bound16  ---- Torrente Cormor ----
        kbound = 11144 11143
        ibtyp  = 2
        boundn = 'input/rivers/cormor.dat'
        temp   = -999
        salt   = 0.5
        conz   = 0.
        levmax = 2
$end

$bound17 ---- Fiume Zellina ----
        kbound = 11177 11176
        ibtyp  = 2
        zref   = 1.
        temp   = -999
        conz   = 0.
        salt   = 0.5
        levmax = 2
$end
        boundn = 'input/rivers/zellina.dat'

$bound18  ---- Fiume Corno ----
        kbound = 10828 10827
        ibtyp  = 2
        boundn = 'input/rivers/corno.dat'
        temp   = -999
        conz   = 0.
        salt   = 0.5
        levmax = 2
$end

$bound19  ---- Fiume Ausa ----
        kbound = 10833 10841
        ibtyp  = 2
        boundn = 'input/rivers/ausa.dat'
        temp   = -999
        conz   = 0.
        salt   = 0.5
        levmax = 2
$end

$bound20  ---- Fiume Natissa + Terzo ----
        kbound = 11242 11241
        ibtyp  = 2
        zref   = 2.0
        temp   = -999
        conz   = 0.
        salt   = 0.5
        levmax = 2
$end
        boundn = 'input/rivers/natissa_terzo.dat'

--------------------------------------------------------
           SECTION EXTRA for TIME SERIES
--------------------------------------------------------
$extra
        5160    'SG001'
        4758    'SG002'
        228     'SG003'
        12902   'SB004'
        12389   'SX005'
        12362   'SX006'
        4483    'SG007'
        4408    'SG008'
        14007   'SX009'
        13181   'SX010'
        13684   'SX011'
        11631   'SX012'
        13928   'SX013'
        15454   'SX014'
        12331   'SX015'
        3658    'SG016'
        12617   'SX017'
        3603    'SG018'
        13351   'SX019'
        13884   'SX020'
        12950   'SX021'
        2303    'SG022'
        13072   'SB023'
        16535   'SX024'
        12249   'SX025'
        12741   'SX026'
        17035   'SX027'
        15148   'SG028'
        15874   'SX029'
        15623   'SP030'
        15147   'SX031'
        16961   'SX032'
        14927   'SX033'
        18187   'SP034'
        16873   'SX035'
        16021   'SX036'
        18207   'SX037'
        14942   'SX038'
        18268   'SX039'
        16805   'SX040'
        14696   'SN041'
        15976   'SX042'
        18028   'SP043'
        15563   'SP044'
        16114   'SX045'
        18263   'SX046'
        13825   'CB001'
        13215   'CB002'
        12567   'CF003'
        13790   'CB004'
        12799   'CB005'
        13279   'CB006'
        12330   'CF007'
        12484   'CB008'
        13853   'CX009'
        12926   'CB010'
        12445   'CX011'
        12643   'CX012'
        12826   'CB013'
        12573   'CB014'
        12959   'CB015'
        18047   'CF016'
        16591   'CF017'
        16729   'CP018'
        16189   'CP019'
        16034   'CX020'
        16065   'CN021'
        18243   'CB022'
        15971   'CX023'
        17345   'CP024'
        16336   'CB025'
        17090   'CP026'
        15175   'CB027'
        15950   'CB028'
        15838   'CB029'
        15625   'CX030'
        17628   'CB031'
        15867   'CX032'
        16619   'CP033'
        15666   'CB034'
        5009    'LX001'
        5081    'LF002'
        5685    'LX003'
        5314    'LX004'
        8251    'LI005'
        4141    'LX006'
        366     'LX007'
        860     'LX008'
        4530    'LX009'
        4280    'LF010'
        6859    'LI011'
        1497    'LX012'
        1638    'LX013'
        13127   'LX014'
        1120    'LX015'
        3218    'LX016'
        9414    'LI017'
        2654    'LX018'
        13149   'MX001'
        14055   'MX002'
        17778   'MX003'
        15423   'MX004'
        17174   'MX005'
        13990   'MX006'
        18227   'MX007'
        16084   'MX008'
        15311   'MX009'
        14038   'MX010'
        16853   'MX011'
        15126   'MX012'
        14902   'MX013'
        18142   'MX014'
        16946   'MX015'
        14831   'MX016'
        15649   'MX017'
        16054   'MX018'
        17646   'MX019'
        15041   'MX020'
$end    

--------------------------------------------------------
           SECTION FLUX
--------------------------------------------------------
$flux
        7156 9978 7157 9982 7159 'Primero'
        5825 9402 5812 9398 5802 9388 5800 'Grado'
        5820 9298 5821 'Morgo'
        6756 8794 6753 8786 6726 8781 6716 8765 6666 8757 6667 'Buso'
        6697 8536 6699 8564 6734 8560 6732 8556 6730 8552 6678
        8647 8230 8654 6679 'SAndrea'
	7859 11253 11255 7860 11256 7883 11257 7880 11254 7878 'Lignano'
$end

--------------------------------------------------------
           SECTION FILES
--------------------------------------------------------
$name
        gotmpa = 'input/gotmturb.nml'
        wind   = 'input/meteo/wind.fem'
        qflux  = 'input/meteo/qflux.fem'
        rain   = 'input/meteo/rain.fem'
        saltin = 'input/adri/saltin.fem'
        tempin = 'input/adri/tempin.fem'
        restrt = '%%RESTRT_FILE_LINK%%'
$end
