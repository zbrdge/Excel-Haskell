import qualified Data.Map as M (fromList, lookup, findWithDefault)
import Data.List.Split (chunksOf, endBy)

import KpiStructure
import ExcelCom 

-- tests 

newExcel = coRun $ do 
    pExl <- createObjExl 
    propertySet "Visible" [inBool True]  pExl

    
fichierTest = "C:/Users/lyup7323/Developpement/Haskell/Com/qos1.xls"
fichierTest2 = "E:/Programmation/haskell/Com/qos1.xls"
fichierTest3 = "E:/Programmation/haskell/Com/qos.xls"
fichierTest4 = "C:/Users/lyup7323/Developpement/Haskell/Com/qos.xls"

--
openXls = coRun $ do 
    pExl <- createObjExl
    propertySet "Visible" [inBool True]  pExl
    workBooks <- pExl # getWorkbooks
    workBooks # openWorkBooks fichierTest2

--
readCell = coRun $ do 
    pExl <- createObjExl
    -- propertySet "Visible" [inBool True]  pExl
    workBooks <- pExl # getWorkbooks
    workBook <- workBooks # openWorkBooks fichierTest2
    sheet <- workBook # getSheet (1 :: Int)
    text <- sheet # getRange "C3" ## getText 
    putStrLn text
    --workBooks # method_0_0 "Save"
    workBooks # method_1_0 "Close" xlDoNotSaveChanges 
    pExl # method_0_0 "Quit"
    release pExl

---
main2 = coRun $ do 
    pExl <- createObjExl
    pExl # showXl
    workBooks <- pExl # getWorkbooks
    workBook <- workBooks # openWorkBooks fichierTest2
    workSheets <- workBook # getWSheets
    sheetSel <- workSheets # propertyGet_1 "Item" (1::Int) 
    sheetSel # getRange "C1:C12" ## setValue "haskell runs Excel"
    text <- sheetSel # getRange "C1" ## getText 
    putStrLn text

    activeWBook <- pExl # getActiveWB
    activeWBook # method_1_0 "Save" xlWorkbookDefault

    workBooks # method_1_0 "Close" xlSaveChanges
    pExl # method_0_0 "Quit"
    mapM release [sheetSel,workSheets, activeWBook,workBook, workBooks, pExl]




main1 = coRun $ do
    idEx <- getActiveObject "Excel.Application"
    idEx # showXl
    text <- idEx # getActiveCell ## getText
    putStrLn text
    idEx # getActiveCell ## setValue "haskell runs"

testcell = coRun $ do
    idEx <- getActiveObject "Excel.Application"
    sheet <- idEx # getActiveWB ## getSheet (2 :: Int) 
    sheet # getRange "C1:C12" ## setValue "haskell pilote Excel"
    text <- sheet # getRange "E1" ## getText 
    putStrLn text

nbsheets = coRun $ do
    idEx <- getActiveObject "Excel.Application"
    workSheets <- idEx # getActiveWB ## getWSheets
    nbsheets <- workSheets # propertyGet_0 "Count" :: IO Int
    putStrLn $ "Nb Sheets = " ++ show nbsheets


testSelectSheet :: Variant a1 => a1 -> IO ()
testSelectSheet n = coRun $ do 
    pExl <- createObjExl
    pExl # showXl
    workBooks <- pExl # getWorkbooks
    workBook <- workBooks # openWorkBooks fichierTest2
    workBook # sheetSelect n

testSelectRng :: Variant a1 => String -> a1 -> IO ()
testSelectRng cell sheet = coRun $ do 
    pExl <- createObjExl
    pExl # showXl
    workBooks <- pExl # getWorkbooks
    workBook <- workBooks # openWorkBooks fichierTest2
    sheetSel <- workBook # getSheet sheet
    sheetSel # select
    rng <- sheetSel # getRange cell
    rng # select 

{--
        my $range = ntol ($col).$max_excel_row;
        # Find the bottommost row for this column.
        my $last_row = $sheet->Range ($range)->End (xlUp)->Row;
        for (my $row = 1; $row <= $last_row; $row++) {
    
    --}

--
--printData :: Variant a1 => IDispatch d -> a1 -> IO ()
printData workSheets sheetName = do 

    sheetSel <- workSheets # propertyGet_1 "Item" sheetName 
    
    -- get KPI
    kpi <- mapM (\x -> sheetSel # getCells x 3 ## getText) [7..100]
    let kpiIndMap   = M.fromList $ zip kpi [7..]
        rowSite     = M.lookup "Sites" kpiIndMap
        rowChannels = M.lookup "Nb channels" kpiIndMap
        rowMinutes  = M.lookup "Minutes (Millions)" kpiIndMap
        rowCalls    = M.lookup "Calls (Millions)" kpiIndMap
        rowPgad     = M.lookup "Post Gateway Answer Delay (sec)" kpiIndMap
        rowAsr      = M.lookup "Answer Seizure Ratio (%)" kpiIndMap
        rowNer      = M.lookup "Network Efficiency Ratio (%)" kpiIndMap
        rowAttps    = M.lookup "ATTPS = Average Trouble Ticket Per Site" kpiIndMap
        rowAfis     = M.lookup "Average FT Incident per Site\" AFIS" kpiIndMap
        rowMos      = M.lookup "Mean Opinion Score (PESQ)" kpiIndMap
        rowPdd      = M.lookup "Post Dialing Delay (sec)" kpiIndMap
        rowCsr      = M.lookup "Call Sucessful Ratio" kpiIndMap
        rowRtd      = M.lookup "RTD average" kpiIndMap
        rowAvail    = M.lookup "Availability ratio HO (outage&changes)" kpiIndMap
        rowUnAvail  = M.lookup "Unavailability minutes HO (outage&changes)" kpiIndMap
        rowComInd1  = M.lookup "CommentIndispo1" kpiIndMap
        rowComInd2  = M.lookup "CommentIndispo2" kpiIndMap
        rowComInd3  = M.lookup "CommentIndispo3" kpiIndMap
        rowComInd4  = M.lookup "CommentIndispo4" kpiIndMap
        rowComInd5  = M.lookup "CommentIndispo5" kpiIndMap
        rowComAfis1 = M.lookup "CommentAFIS1" kpiIndMap
        rowComAfis2 = M.lookup "CommentAFIS2" kpiIndMap
        rowComMos1  = M.lookup "CommentMOS1" kpiIndMap
        rowComMos2  = M.lookup "CommentMOS2" kpiIndMap

        lookupData :: Variant a => a -> Maybe Int -> IO [a] 
        -- return a list of Kpi's datas if kpi's row is found otherwise a defaut value
        lookupData fill rowKpi = maybe (return $ replicate 52 fill) -- default value [fill,...fill]
                                       (getData getValue) -- handler 
                                       rowKpi -- Nothing or Just (kpi row) 
        getData func row = mapM (\x -> sheetSel # getCells row x ## func) [4..55]
        insertPerc = map perc --  add a % to a non-empty list
        perc "" = ""
        perc a  = ((++"%").take 4) a

    nbSites         <- lookupData 0 rowSite :: IO [Int]
    -- nbSites2 <- maybe (return $ replicate 52 0) (getData getInt) rowSite
    -- nbSites2 <- mapM (\x -> sheetSel # getCells 7 x ## getInt) [4..55]
    nbChannels      <-  lookupData 0 rowChannels :: IO [Int]
    nbMinutes       <- fmap (map trunc) $ lookupData 0.0 rowMinutes :: IO [Double]
    nbCalls         <- fmap (map trunc) $ lookupData 0.0 rowCalls :: IO [Double]
    postGAD         <- fmap (map trunc) $ lookupData 0.0 rowPgad :: IO [Double]
    asr             <- fmap (map trunc) $ lookupData 0.0 rowAsr :: IO [Double]
    ner             <- fmap (map trunc) $ lookupData 0.0 rowNer :: IO [Double]
    attps           <- fmap insertPerc $ lookupData "" rowAttps :: IO [String]
    afis            <- fmap insertPerc $ lookupData "" rowAfis :: IO [String]
    mos             <- fmap (map trunc) $ lookupData 0.0 rowMos :: IO [Double]
    pdd             <- fmap (map trunc) $ lookupData 0.0 rowPdd :: IO [Double]
    csr             <- fmap (map trunc) $ lookupData 0.0 rowCsr :: IO [Double]
    rtd             <- fmap (map trunc) $ lookupData 0.0 rowRtd :: IO [Double]
    --avail           <- lookupData "" rowAvail :: IO [String]
    unavail         <- fmap (map trunc) $ lookupData 0.0 rowUnAvail :: IO [Double]
    commentIndisp1  <- lookupData "" rowComInd1
    commentIndisp2  <- lookupData "" rowComInd2
    commentIndisp3  <- lookupData "" rowComInd3
    commentIndisp4  <- lookupData "" rowComInd4
    commentIndisp5  <- lookupData "" rowComInd5
    commentAFIS1    <- lookupData "" rowComAfis1
    commentAFIS2    <- lookupData "" rowComAfis2
    commentMOS1     <- lookupData "" rowComMos1
    commentMOS2     <- lookupData "" rowComMos2
    
    -- print them
    putStrLn "----nbSites---"
    print nbSites
    putStrLn "----nbChannels---"
    print nbChannels
    putStrLn "----nbMinutes---"
    print nbMinutes
    putStrLn "----ASR ---"
    print asr
    putStrLn "----Ner ---"
    print ner
    putStrLn "----mos ---"
    print mos
    putStrLn "----pdd ---"
    print pdd
    putStrLn "----csr ---"
    print csr
    putStrLn "---- rtd ---"
    print rtd
    putStrLn "---- commentIndisp1 ---"
    print commentIndisp1
    putStrLn "---- commentIndisp2 ---"
    print commentIndisp2
    putStrLn "---- commentIndisp3 ---"
    print commentIndisp3
    putStrLn "---- commentIndisp4 ---"
    print commentIndisp4
    putStrLn "---- commentIndisp5 ---"
    print commentIndisp5
    putStrLn "---- commentAFIS1 ---"
    print commentAFIS1
    putStrLn "---- commentAFIS2 ---"
    print commentAFIS2
    putStrLn "---- commentMOS1 ---"
    print commentMOS1
    putStrLn "---- CommentMOS2 ---"
    mapM_ putStr commentMOS2
    putStrLn "----attps ---"
    print attps
    putStrLn "----afis ---"
    print afis 
    putStrLn "----avail ---"
   -- print avail 
    putStrLn "----unvail ---"
    print unavail 
    --}
    putStrLn "---- kpi ---"
    print kpi
    
    release sheetSel

testCell = coRun $ do 
    pExl <- createObjExl
    workBooks <- pExl # getWorkbooks
    pExl # propertySet "DisplayAlerts" [inBool False]
    workBook <- workBooks # openWorkBooks fichierTest3
    workSheets <- workBook # getWSheets

    printData workSheets "BIV"
    
    workBooks # method_1_0 "Close" xlDoNotSaveChanges
    pExl # method_0_0 "Quit"
    mapM release [workSheets, workBook, workBooks, pExl]

{-
    -
 rng <- sheetSel # getRange "C1:C20"
*Main> r <- rng # enumVariants :: IO (Int,[String])
*Main> r

        -}

bivData = coRun $ do 
    pExl <- createObjExl
    workBooks <- pExl # getWorkbooks
    pExl # propertySet "DisplayAlerts" [inBool False]
    workBook <- workBooks # openWorkBooks fichierTest3
    putStrLn  $"File loaded: " ++ fichierTest3

    workSheets <- workBook # getWSheets

    sheetSel <- workSheets # propertyGet_1 "Item" "BIV"

    rng1 <- sheetSel # propertyGet_1 "Range" "C7"
    endrow <- rng1 # propertyGet_1 "End" xlDown
    row <- endrow # propertyGet_0 "Row" :: IO Int
    let lastrow =  "C7:BC"++ show row
    putStrLn $ "endrow = " ++  lastrow
    rng <- sheetSel # propertyGet_1 "Range" lastrow
    (_,r) <- rng # enumVariants :: IO (Int,[String])


    return r
{--
    workBooks # method_1_0 "Close" xlDoNotSaveChanges
    pExl # method_0_0 "Quit"
    mapM release [endrow,rng,rng1, sheetSel, workSheets, workBook, workBooks, pExl]
--}



{--
    - helpers
        - --} 

-- take 2 decimals
trunc :: Double -> Double
trunc double = (fromInteger $ round $ double * (10^2)) / (10.0 ^^2)

    -- reads double or put 0 
toDouble :: String -> Double
toDouble xs = case (reads.chgComma.endBy "," $ xs :: [(Double,String)] ) of
    [(d,s)] -> d
    _ -> 0
    where 
        chgComma [x,y] = x ++ "." ++ (take 2 y)
        chgComma xs = concat xs

toInt xs = case (reads xs :: [(Int,String)] ) of
    [(d,s)] -> d
    _ -> 0





{--
    - tests 
        - --}

sheetsName = ["BIV","BIC"]

main = coRun $ do
    (pExl, workBooks, workSheets) <- xlInit
    mapM_ (processRowData workSheets) sheetsName
    xlQuit workBooks pExl

xlQuit workBooks appXl = do
    workBooks # method_1_0 "Close" xlDoNotSaveChanges
    appXl # method_0_0 "Quit"

xlInit = do   
    pExl <- createObjExl
    workBooks <- pExl # getWorkbooks
    pExl # propertySet "DisplayAlerts" [inBool False]
    workBook <- workBooks # openWorkBooks fichierTest4
    putStrLn  $"File loaded: " ++ fichierTest4
    workSheets <- workBook # getWSheets'
    return (pExl, workBooks, workSheets)
    

processRowData :: Sheet a -> String -> IO ()
processRowData sheets sheetName = do 
    rowsService <- rowsFromSheet sheets sheetName
    putStrLn $ "got all datas from " ++ sheetName
    printListData rowsService
    putStrLn $ replicate 50 '-'


rowsFromSheet :: Sheet a -> String -> IO [String] 
rowsFromSheet workSheets sheetName= do 
    sheetSel <- workSheets # propertyGet_1 "Item" sheetName

{-    rng1 <- sheetSel # propertyGet_1 "Range" "C7"
    endrow <- rng1 # propertyGet_1 "End" xlDown
    row <- endrow # propertyGet_0 "Row" :: IO Int
    -}
    let row = 79
    let lastrow =  "C7:BC"++ show row
    putStrLn $ "endrow = " ++  lastrow
    rng <- sheetSel # propertyGet_1 "Range" lastrow
    fmap snd $ rng # enumVariants


printListData rows = do     
    let kpiData toX n  = map (toX.(rows!!).(+53*n)) [1..52]
        kpiName     = map (\n -> rows!!(53*n)) $ [0..72]
        kpiIndMap   = M.fromList $ zip kpiName [0..]
        rowNb s     = M.lookup s kpiIndMap

        rowSite     = rowNb "Sites"
        rowChannels = rowNb "Nb channels"
        rowMinutes  = rowNb "Minutes (Millions)"
        rowCalls    = rowNb "Calls (Millions)" 
        rowPgad     = rowNb "Post Gateway Answer Delay (sec)" 
        rowAsr      = rowNb "Answer Seizure Ratio (%)" 
        rowNer      = rowNb "Network Efficiency Ratio (%)" 
        rowAttps    = rowNb "ATTPS = Average Trouble Ticket Per Site" 
        rowAfis     = rowNb "Average FT Incident per Site\" AFIS" 
        rowMos      = rowNb "Mean Opinion Score (PESQ)" 
        rowPdd      = rowNb "Post Dialing Delay (sec)" 
        rowCsr      = rowNb "Call Sucessful Ratio" 
        rowRtd      = rowNb "RTD average" 
        rowAvail    = rowNb "Availability ratio HO (outage&changes)" 
        rowUnAvail  = rowNb "Unavailability minutes HO (outage&changes)" 
        rowComInd1  = rowNb "CommentIndispo1" 
        rowComInd2  = rowNb "CommentIndispo2" 
        rowComInd3  = rowNb "CommentIndispo3" 
        rowComInd4  = rowNb "CommentIndispo4" 
        rowComInd5  = rowNb "CommentIndispo5" 
        rowComAfis1 = rowNb "CommentAFIS1" 
        rowComAfis2 = rowNb "CommentAFIS2" 
        rowComMos1  = rowNb "CommentMOS1" 
        rowComMos2  = rowNb "CommentMOS2" 

        lookupData toX fill rowKpi = maybe (replicate 52 fill) -- default value [fill,...fill]
                                       (kpiData toX) -- handler 
                                       rowKpi -- Nothing or Just (kpi row) 

        nbSites = lookupData toInt 0 rowSite 
        nbChannels = lookupData toInt 0 rowChannels
        nbMinutes = lookupData toDouble 0 rowMinutes
        asr = lookupData toDouble 0 rowAsr
        ner = lookupData toDouble 0 rowNer
        attps = lookupData toDouble 0 rowAttps
        afis = lookupData toDouble 0 rowAfis
        mos = lookupData toDouble 0 rowMos
        pdd = lookupData toDouble 0 rowPdd
        csr = lookupData toDouble 0 rowCsr
        rtd = lookupData toDouble 0 rowRtd
        avail = lookupData toDouble 0 rowAvail
        unavail = lookupData toDouble 0 rowUnAvail
        
        commentIndisp1 = lookupData id "" rowComInd1
        commentIndisp2 = lookupData id ""  rowComInd2
        commentIndisp3 = lookupData id ""  rowComInd3
        commentIndisp4 = lookupData id ""  rowComInd4
        commentIndisp5 = lookupData id ""  rowComInd5
        commentAFIS1 = lookupData id ""  rowComAfis1
        commentAFIS2 = lookupData id ""  rowComAfis2
        commentMOS1 = lookupData id ""  rowComMos1
        commentMOS2 = lookupData id "" rowComMos2

    
    -- return (kpiName!! ind , kpiData ind)
    -- print them
    putStrLn "----nbSites---"
    print nbSites
    putStrLn "----nbChannels---"
    print nbChannels
    putStrLn "----nbMinutes---"
    print nbMinutes
    putStrLn "----ASR ---"
    print asr
    putStrLn "----Ner ---"
    print ner
    putStrLn "----mos ---"
    print mos
    putStrLn "----pdd ---"
    print pdd
    putStrLn "----csr ---"
    print csr
    putStrLn "---- rtd ---"
    print rtd
    putStrLn "---- commentIndisp1 ---"
    print commentIndisp1
    putStrLn "---- commentIndisp2 ---"
    print commentIndisp2
    putStrLn "---- commentIndisp3 ---"
    print commentIndisp3
    putStrLn "---- commentIndisp4 ---"
    print commentIndisp4
    putStrLn "---- commentIndisp5 ---"
    print commentIndisp5
    putStrLn "---- commentAFIS1 ---"
    print commentAFIS1
    putStrLn "---- commentAFIS2 ---"
    print commentAFIS2
    putStrLn "---- commentMOS1 ---"
    print commentMOS1
    putStrLn "---- CommentMOS2 ---"
    mapM_ putStr commentMOS2
    putStrLn "----attps ---"
    print attps
    putStrLn "----afis ---"
    print afis 
    putStrLn "----avail ---"
    print avail 
    putStrLn "----unvail ---"
    print unavail 

--data KPIType = Int | Double | String
--data KpiStruct = KpiStruct { structKpiName :: String, structKpiData :: [KPIType]} 
--                deriving (show)
{--
    - structure
        
services ::[ServStruct]
Servstruct = data   { servName :: String
                    , kpi :: [KpiStruct]
                    }
KpiStruct = data    { kpiName :: String
                    , kpidonne :: []
}


        --}

testSplit = coRun $ do
    pExl <- createObjExl
    workBooks <- pExl # getWorkbooks
    pExl # propertySet "DisplayAlerts" [inBool False]
    workBook <- workBooks # openWorkBooks fichierTest3
    putStrLn  $"File loaded: " ++ fichierTest3
    workSheets <- workBook # getWSheets'

    rows <- rowsFromSheet workSheets "BIV"
    putStrLn "got all datas from BIV"

    printDataSplit rows  

    workBooks # method_1_0 "Close" xlDoNotSaveChanges
    pExl # method_0_0 "Quit"
  
printDataSplit r = do 
    let part xss        = map (\(x:xs) -> (x,xs)) xss
        kmKPI           = M.fromList.part.chunksOf 53 $ r
        defKpi          = replicate 52 ""
        nbSites         = map toInt $ M.findWithDefault defKpi "Sites" kmKPI
        nbChannels      = map toInt $ M.findWithDefault defKpi "Nb channels" kmKPI
        nbMinutes       = map toDouble $ M.findWithDefault defKpi "Minutes (Millions)" kmKPI
        calls           = map toDouble $ M.findWithDefault defKpi "Calls (Millions)" kmKPI
        pgad            = map toDouble $ M.findWithDefault defKpi "Post Gateway Answer Delay (sec)" kmKPI
        asr             = map toDouble $ M.findWithDefault defKpi "Answer Seizure Ratio (%)" kmKPI
        ner             = map toDouble $ M.findWithDefault defKpi "Network Efficiency Ratio (%)" kmKPI
        attps           = map toDouble $ M.findWithDefault defKpi "ATTPS = Average Trouble Ticket Per Site" kmKPI
        afis            = map toDouble $ M.findWithDefault defKpi "Average FT Incident per Site\" AFIS" kmKPI
        mos             = map toDouble $ M.findWithDefault defKpi "Mean Opinion Score (PESQ)" kmKPI
        pdd             = map toDouble $ M.findWithDefault defKpi "Post Dialing Delay (sec)" kmKPI
        csr             = map toDouble $ M.findWithDefault defKpi "Call Sucessful Ratio" kmKPI
        rtd             = map toDouble $ M.findWithDefault defKpi "RTD average" kmKPI
        avail           = map toDouble $ M.findWithDefault defKpi "Availability ratio HO (outage&changes)" kmKPI
        unAvail         = map toDouble $ M.findWithDefault defKpi "Unavailability minutes HO (outage&changes)" kmKPI
        commentIndisp1  = M.findWithDefault defKpi "CommentIndispo1" kmKPI
        commentIndisp2  = M.findWithDefault defKpi "CommentIndispo2" kmKPI
        commentIndisp3  = M.findWithDefault defKpi "CommentIndispo3" kmKPI
        commentIndisp4  = M.findWithDefault defKpi "CommentIndispo4" kmKPI
        commentAFIS1    = M.findWithDefault defKpi "CommentAFIS1" kmKPI
        commentAFIS2    = M.findWithDefault defKpi "CommentAFIS2" kmKPI
        commentMOS1     = M.findWithDefault defKpi "CommentMOS1" kmKPI
        commentMOS2     = M.findWithDefault defKpi "CommentMOS2" kmKPI
    
 
    -- print them
    putStrLn "----nbSites---"
    print nbSites
    putStrLn "----nbChannels---"
    print nbChannels
    putStrLn "----nbMinutes---"
    print nbMinutes
    putStrLn "----ASR ---"
    print asr
    putStrLn "----Ner ---"
    print ner
    putStrLn "----mos ---"
    print mos
    putStrLn "----pdd ---"
    print pdd
    putStrLn "----csr ---"
    print csr
    putStrLn "---- rtd ---"
    print rtd
    putStrLn "---- commentIndisp1 ---"
    print commentIndisp1
    putStrLn "---- commentIndisp2 ---"
    print commentIndisp2
    putStrLn "---- commentIndisp3 ---"
    print commentIndisp3
    putStrLn "---- commentIndisp4 ---"
    print commentIndisp4
    putStrLn "---- commentAFIS1 ---"
    print commentAFIS1
    putStrLn "---- commentAFIS2 ---"
    print commentAFIS2
    putStrLn "---- commentMOS1 ---"
    print commentMOS1
    putStrLn "---- CommentMOS2 ---"
    mapM_ putStr commentMOS2
    putStrLn "----attps ---"
    print attps
    putStrLn "----afis ---"
    print afis 
    putStrLn "----avail ---"
    print avail 
    putStrLn "----unvail ---"
    print unAvail 
    

testEndRow = coRun $ do
    pExl <- createObjExl
    workBooks <- pExl # getWorkbooks
    pExl # propertySet "DisplayAlerts" [inBool False]
    workBook <- workBooks # openWorkBooks fichierTest3
    workSheets <- workBook # getWSheets

    sheetSel <- workSheets # propertyGet_1 "Item" "BIV"
    
    rng <- sheetSel # propertyGet_1 "Range" "C7"

    endrow <- rng # propertyGet_1 "End" xlDown
    row <- endrow # propertyGet_0 "Row" :: IO Int
    putStrLn $ "endrow = " ++ (show row)

    workBooks # method_1_0 "Close" xlDoNotSaveChanges
    pExl # method_0_0 "Quit"
