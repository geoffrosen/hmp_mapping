#####################################################################################
#Copyright (C) <2012>
#
#Permission is hereby granted, free of charge, to any person obtaining a copy of
#this software and associated documentation files (the "Software"), to deal in the
#Software without restriction, including without limitation the rights to use, copy,
#modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
#and to permit persons to whom the Software is furnished to do so, subject to
#the following conditions:
#
#The above copyright notice and this permission notice shall be included in all copies
#or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
#INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
#PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
#HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
#OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
#SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# This file is a component of the MaAsLin (Multivariate Associations Using Linear Models), 
# authored by the Huttenhower lab at the Harvard School of Public Health
# (contact Timothy Tickle, ttickle@hsph.harvard.edu).
#####################################################################################

inlinedocs <- function(
##author<< Curtis Huttenhower <chuttenh@hsph.harvard.edu> and Timothy Tickle <ttickle@hsph.harvard.edu>
##description<< Collection of minor utility scripts
) { return( pArgs ) }

#source("Constants.R")

funcRename <- function(
### Modifies labels for plotting
### If the name is not an otu collapse to the last two clades
### Otherwise use the most terminal clade
astrNames
### Names to modify for plotting
){
  astrRet <- c()
  for( strName in astrNames )
  {
    astrName <- strsplit( strName, c_cFeatureDelimRex )[[1]]
    i <- length( astrName )
    if( ( astrName[i] == c_strUnclassified ) || !is.na( as.numeric( astrName[i] ) ) )
    {
      strRet <- paste( astrName[( i - 1 ):i], collapse = c_cFeatureDelim )
    } else {
    strRet <- astrName[i]
    }
    astrRet <- c(astrRet, strRet)
  }
  return( astrRet )
  ### List of modified names
}

funcBonferonniCorrectFactorData <- function
### Bonferroni correct for factor data
(dPvalue,
### P-value to correct
vsFactors,
### Factors of the data to correct
fIgnoreNAs = TRUE
){
  vsUniqueFactors = unique( vsFactors )
  if( fIgnoreNAs ){ vsUniqueFactors = setdiff( vsUniqueFactors, c("NA","na","Na","nA") ) }
  return( dPvalue * max( 1, ( length( vsUniqueFactors ) - 1 ) ) )
  ### Numeric p-value that is correct for levels (excluding NA levels)
}

funcCalculateTestCounts <- function(
### Calculates the number of tests used in inference
iDataCount,
asMetadata,
asForced,
asRandom,
fAllvAll
){
  iMetadata = length(asMetadata)
  iForced = length(setdiff(intersect( asForced, asMetadata ), asRandom))
  iRandom = length(intersect( asRandom, asMetadata ))
  if(fAllvAll)
  {
    #AllvAll flow formula
    return((iMetadata-iForced-iRandom) * iDataCount)
  }

  #Normal flow formula
  return((iMetadata-iRandom) * iDataCount)
}

funcGetRandomColors=function(
#Generates a given number of random colors
tempNumberColors = 1
### Number of colors to generate
){
  adRet = c()
  return(sapply(1:tempNumberColors, function(x){
    adRGB <- ( runif( 3 ) * 0.66 ) + 0.33
    adRet <- c(adRet, rgb( adRGB[1], adRGB[2], adRGB[3] ))
  }))
}

funcCoef2Col <- function(
### Searches through a dataframe and looks for a column that would match the coefficient
### by the name of the column or the column name and level appended together.
strCoef,
### String coefficient name
frmeData,
### Data frame of data
astrCols = c()
### Column names of interest (if NULL is given, all column names are inspected).
){
  #If the coefficient is the intercept there is no data column to return so return null
  if( strCoef %in% c("(Intercept)", "Intercept") ) { return( NULL ) }
  #Remove ` from coefficient
  strCoef <- gsub( "`", "", strCoef )

  #If the coefficient name is not in the data frame
  if( !( strCoef %in% colnames( frmeData ) ) )
  {
    fHit <- FALSE
    #If the column names are not provided, use the column names of the dataframe.
    if( is.null( astrCols ) ){astrCols <- colnames( frmeData )}

    #Search through the different column names (factors)
    for( strFactor in astrCols )
    {
      #Select a column, if it is not a factor or does not begin with the factor's name then skip
      adCur <- frmeData[,strFactor]
      if( ( class( adCur ) != "factor" ) ||
        ( substr( strCoef, 1, nchar( strFactor ) ) != strFactor ) ) { next }

      #For the factors, create factor-level name combinations to read in factors
      #Then check to see the factor-level combination is the coefficient of interest
      #If it is then store that factor as the coefficient of interest
      #And break
      for( strValue in levels( adCur ) )
      {
        strCur <- paste( strFactor, strValue, sep = c_sFactorNameSep )
        if( strCur == strCoef )
        {
          strCoef <- strFactor
          fHit <- TRUE
          break
        }
      }

      #If the factor was found, return
      if( fHit ){break }
    }
  }

  #If the original coefficient or the coefficient factor combination name are in the
  #data frame, return the name. Otherwise return NA.
  return( ifelse( ( strCoef %in% colnames( frmeData ) ), strCoef, NA ) )
  ### Coefficient name
}

funcColToMFAValue = function(
### Given a column name, return the MFA values that could be associated with the name
lsColNames,
### String list of column names (as you would get from names(dataframe))
dfData
### Data frame of data the column names refer to
){
  lsMFAValues = c()

  for(sColName in lsColNames)
  {
    axCur = dfData[[sColName]]

    if(is.logical(axCur)){axCur=as.factor(axCur)}
    if(is.factor(axCur))
    {
      lsLevels = levels(axCur)
      if((length(lsLevels)==2) && (!is.na(as.numeric(lsLevels[1]))) && (!is.na(as.numeric(lsLevels[2]))))
      {
        lsMFAValues = c(lsMFAValues,paste(sColName,lsLevels[1],sep=c_sMFANameSep1),paste(sColName,lsLevels[2],sep=c_sMFANameSep1))
      }else{
        for(sLevel in levels(axCur))
        {
          lsMFAValues = c(lsMFAValues,sLevel)
        }
      }
    } else {
      lsMFAValues = c(lsMFAValues,sColName)
    }
  }
  return(setdiff(lsMFAValues,c("NA",NA)))
}

funcMFAValue2Col = function(
### Given a value in a column, the column name is returned.
xValue,
dfData,
aiColumnIndicesToSearch = NULL
){
  lsColumnNames = names(dfData)

  if(is.null(aiColumnIndicesToSearch))
  {
    aiColumnIndicesToSearch = c(1:dim(dfData)[2])
  }

  # Could be the column name
  if(xValue %in% lsColumnNames){return(xValue)}

  # Could be the column name and value
  iValueLength = length(xValue)
  for( iColIndex in c(1:length(lsColumnNames) ))
  {
    adCur = dfData[[lsColumnNames[iColIndex]]]
    if(is.factor(adCur))
    {
      for(strValue in levels(adCur))
      {
        strCurVersion1 <- paste( lsColumnNames[iColIndex], strValue, sep = c_sMFANameSep1 )
        strCurVersion2 <- paste( lsColumnNames[iColIndex], strValue, sep = c_sMFANameSep2 )
        if((xValue == strCurVersion1) || (xValue == strCurVersion2)){return(lsColumnNames[iColIndex])}
      }
    }
  }

  # Could be the value
  for(iColIndex in aiColumnIndicesToSearch)
  {
    if(xValue %in% dfData[[lsColumnNames[iColIndex]]]){return(lsColumnNames[iColIndex])}
  }
  return(NULL)
}

funcColorHelper <- function(
### Makes sure the max is max and the min is min, and dmed is average
dMax = 1,
### Max number
dMin = -1,
### Min number
dMed = NA
### Average value
){
  #Make sure max is max and min is min
  vSort = sort(c(dMin,dMax))
  return( list( dMin = vSort[1], dMax = vSort[2], dMed = ifelse((is.na(dMed)), (dMin+dMax)/2.0, dMed ) ))
  ### List of min, max and med numbers
}

funcColor <- function(
### Generate a color based on a number that is forced to be between a min and max range.
### The color is based on how far the number is from the center of the given range
### From red to green (high) are produced with default settings
dX,
### Number from which to generate the color
dMax = 1,
### Max possible value
dMin = -1,
### Min possible value
dMed = NA,
### Central value if you don't want to be the average
adMax = c(1, 1, 0),
### Is used to generate the color for the higher values in the range, this can be changed to give different colors set to green
adMin = c(0, 0, 1),
### Is used to generate the color for the lower values in the range, this can be changed to give different colors set to red
adMed = c(0, 0, 0)
### Is used to generate the color for the central values in the range, this can be changed to give different colors set to black
){
  lsTmp <- funcColorHelper( dMax, dMin, dMed )
  dMax <- lsTmp$dMax
  dMin <- lsTmp$dMin
  dMed <- lsTmp$dMed
  if( is.na( dX ) )
  {
    dX <- dMed
  }
  if( dX > dMax )
  {
    dX <- dMax
  } else if( dX < dMin )
  {
    dX <- dMin }
  if( dX < dMed )
  {
    d <- ( dMed - dX ) / ( dMed - dMin )
    adCur <- ( adMed * ( 1 - d ) ) + ( adMin * d )
  } else {
    d <- ( dMax - dX ) / ( dMax - dMed )
    adCur <- ( adMed * d ) + ( adMax * ( 1 - d ) )
  }
  return( rgb( adCur[1], adCur[2], adCur[3] ) )
  ### RGB object
}

funcColors <- function(
### Generate a range of colors
dMax = 1,
### Max possible value
dMin = -1,
### Min possible value
dMed = NA,
### Central value if you don't want to be the average
adMax = c(1, 1, 0),
### Is used to generate the color for the higher values in the range, this can be changed to give different colors set to green
adMin = c(0, 0, 1),
### Is used to generate the color for the lower values in the range, this can be changed to give different colors set to red
adMed = c(0, 0, 0),
### Is used to generate the color for the central values in the range, this can be changed to give different colors set to black
iSteps = 64
### Number of intermediary colors made in the range of colors
){
  lsTmp <- funcColorHelper( dMax, dMin, dMed )
  dMax <- lsTmp$dMax
  dMin <- lsTmp$dMin
  dMed <- lsTmp$dMed
  aRet <- c ()
  for( dCur in seq( dMin, dMax, ( dMax - dMin ) / ( iSteps - 1 ) ) )
  {
    aRet <- c(aRet, funcColor( dCur, dMax, dMin, dMed, adMax, adMin, adMed ))
  }
  return( aRet )
  ### List of colors
}

funcGetColor <- function(
### Get a color based on col parameter
) {
  adCol <- col2rgb( par( "col" ) )
  return( sprintf( "#%02X%02X%02X", adCol[1], adCol[2], adCol[3] ) )
  ### Return hexadecimal color
}

funcTrim=function(
### Remove whitespace at the beginning or the end of a string
tempString
### tempString String to be trimmed.
){
  return(gsub("^\\s+|\\s+$","",tempString))
}

funcWrite <- function(
### Write a string or a table of data
### This transposes a table before it is written
pOut,
### String or table to write
strFile
### File to which to write
){
  if(!is.na(strFile))
  {
   if( length( intersect( class( pOut ), c("character", "numeric") ) ) )
    {
      write.table( t(pOut), strFile, quote = FALSE, sep = c_cTableDelimiter, col.names = FALSE, row.names = FALSE, na = "", append = TRUE )
    } else {
      capture.output( print( pOut ), file = strFile, append = TRUE )
    }
  }
}

funcWriteTable <- function(
### Log a table to a file
frmeTable,
### Table to write
strFile,
### File to which to write
fAppend = FALSE
### Append when writing
){
  if(!is.na(strFile))
  {
    write.table( frmeTable, strFile, quote = FALSE, sep = c_cTableDelimiter, na = "", col.names = NA, append = fAppend )
  }
}

funcWriteQCReport <- function(
### Write out the quality control report
strProcessFileName,
###  File name
lsQCData,
### List of QC data generated by maaslin to be written
liDataDim,
### Dimensions of the data matrix
liMetadataDim
### Dimensions of the metadata matrix
){
  unlink(strProcessFileName)
  funcWrite( paste("Initial Metadata Matrix Size: Rows ",liMetadataDim[1],"  Columns ",liMetadataDim[2],sep=""), strProcessFileName )
  funcWrite( paste("Initial Data Matrix Size: Rows ",liDataDim[1],"  Columns ",liDataDim[2],sep=""), strProcessFileName )
  funcWrite( paste("\nInitial Data Count: ",length(lsQCData$aiDataInitial),sep=""), strProcessFileName )
  funcWrite( paste("Initial Metadata Count: ",length(lsQCData$aiMetadataInitial),sep=""), strProcessFileName )
  funcWrite( paste("Data Count after preprocess: ",length(lsQCData$aiAfterPreprocess),sep=""), strProcessFileName )
  funcWrite( paste("Removed for missing metadata: ",length(lsQCData$iMissingMetadata),sep=""), strProcessFileName )
  funcWrite( paste("Removed for missing data: ",length(lsQCData$iMissingData),sep=""), strProcessFileName )
  funcWrite( paste("Number of data with outliers: ",length(which(lsQCData$aiDataSumOutlierPerDatum>0)),sep=""), strProcessFileName )
  funcWrite( paste("Number of metadata with outliers: ",length(which(lsQCData$aiMetadataSumOutlierPerDatum>0)),sep=""), strProcessFileName )
  funcWrite( paste("Metadata count which survived clean: ",length(lsQCData$aiMetadataCleaned),sep=""), strProcessFileName )
  funcWrite( paste("Data count which survived clean: ",length(lsQCData$aiDataCleaned),sep=""), strProcessFileName )
  funcWrite( paste("\nBoostings: ",lsQCData$iBoosts,sep=""), strProcessFileName )
  funcWrite( paste("Boosting Errors: ",lsQCData$iBoostErrors,sep=""), strProcessFileName )
  funcWrite( paste("LMs with no terms suriving boosting: ",lsQCData$iNoTerms,sep=""), strProcessFileName )
  funcWrite( paste("LMs performed: ",lsQCData$iLms,sep=""), strProcessFileName )
  if(!is.null(lsQCData$lsQCCustom))
  {
    funcWrite("Custom preprocess QC data: ", strProcessFileName )
    funcWrite(lsQCData$lsQCCustom, strProcessFileName )
  } else {
    funcWrite("No custom preprocess QC data.", strProcessFileName )
  }
  funcWrite( "\n#Details###########################", strProcessFileName )
  funcWrite("\nInitial Data Count: ", strProcessFileName )
  funcWrite(lsQCData$aiDataInitial, strProcessFileName )
  funcWrite("\nInitial Metadata Count: ", strProcessFileName )
  funcWrite(lsQCData$aiMetadataInitial, strProcessFileName )
  funcWrite("\nData Count after preprocess: ", strProcessFileName )
  funcWrite(lsQCData$aiAfterPreprocess, strProcessFileName )
  funcWrite("\nRemoved for missing metadata: ", strProcessFileName )
  funcWrite(lsQCData$iMissingMetadata, strProcessFileName )
  funcWrite("\nRemoved for missing data: ", strProcessFileName )
  funcWrite(lsQCData$iMissingData, strProcessFileName )
  funcWrite("\nDetailed outlier indices: ", strProcessFileName )
  for(sFeature in names(lsQCData$liOutliers))
  {
    funcWrite(paste("Feature",sFeature,"Outlier indice(s):", paste(lsQCData$liOutliers[[sFeature]],collapse=",")), strProcessFileName )
  }
  funcWrite("\nMetadata which survived clean: ", strProcessFileName )
  funcWrite(lsQCData$aiMetadataCleaned, strProcessFileName )
  funcWrite("\nData which survived clean: ", strProcessFileName )
  funcWrite(lsQCData$aiDataCleaned, strProcessFileName )
}

funcLMToNoNAFormula <-function(
lMod,
frmeTmp,
adCur
){
  dfCoef = coef(lMod)
  astrCoefNames = setdiff(names(dfCoef[as.vector(!is.na(dfCoef))==TRUE]),"(Intercept)")
  astrPredictors = unique(as.vector(sapply(astrCoefNames,funcCoef2Col, frmeData=frmeTmp)))
  strFormula = paste( "adCur ~", paste( sprintf( "`%s`", astrPredictors ), collapse = " + " ), sep = " " )
  return(try( lm(as.formula( strFormula ), data=frmeTmp )))
}

funcFormulaStrToList <- function(
#Takes a lm or mixed model formula and returns a list of covariate names in the formula
strFormula
#Formula to extract covariates from
){
  #Return list
  lsRetComparisons = c()

  #If you get a null or na just return
  if(is.null(strFormula)||is.na(strFormula)){return(lsRetComparisons)}

  #Get test comparisons (predictor names from formula string)
  asComparisons = gsub("`","",setdiff(unlist(strsplit(unlist(strsplit(strFormula,"~"))[2]," ")),c("","+")))

  #Change metadata in formula to univariate comparisons
  for(sComparison in asComparisons)
  {
    #Removed random covariate formating
    lsParse = unlist(strsplit(sComparison, "[\\(\\|\\)]", perl=FALSE))
    lsRetComparisons = c(lsRetComparisons,lsParse[length(lsParse)])
  }
  return(lsRetComparisons)
}

funcFormulaListToString <- function(
# Using covariate and random covariate names, creates a lm or mixed model formula
# returns a vector of c(strLM, strMixedModel), one will be NA given the existance of random covariates.
# On error c(NA,NA) is given
astrTerms,
#Fixed covariates or all covariates if using an lm
astrRandomCovariates = NULL
#Random covariates for a mixed model
){
  strRetLMFormula = NA
  strRetMMFormula = NA

  #If no covariates return NA
  if(is.null(astrTerms)){return(c(strRetLMFormula, strRetMMFormula))}

  #Get fixed covariates
  astrFixedCovariates = setdiff(astrTerms,astrRandomCovariates)

  #If no fixed coavariates return NA
  # Can not run a model with no fixed covariate, restriction of lmm
  if(length(astrFixedCovariates)==0){return(c(strRetLMFormula, strRetMMFormula))}

  # Fixed Covariates
  strFixedCovariates = paste( sprintf( "`%s`", astrFixedCovariates ), collapse = " + " )

  #If random covariates, set up a formula for mixed models
  if(length(astrRandomCovariates)>0)
  {
    #Format for lmer
    #strRetFormula <- paste( "adCur ~ ", paste( sprintf( "(1|`%s`))", intersect(astrRandomCovariates, astrTerms)), collapse = " + " ))
    #Format for glmmpql
    strRandomCovariates = paste( sprintf( "1|`%s`", setdiff(astrRandomCovariates, astrTerms)), collapse = " + " )
    strRetMMFormula <- paste( "adCur ~ ", strFixedCovariates, " + ", strRandomCovariates, sep="")
  } else {
    #This is either the formula for all covariates in an lm or fixed covariates in the lmm
    strRetLMFormula <- paste( "adCur ~ ", strFixedCovariates, sep="")
  }
  return(c(strRetLMFormula, strRetMMFormula))
}