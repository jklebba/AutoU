#SingleInstance, force

;______________SETUP_____________
uncertPrefixChar := "u"
helpMsg = 
(
Press Ctrl + Shift + H at any time to see these instructions.
Press Ctrl + Escape to disable/enable all other keyboard shortcuts.

Automatic Uncertanity is a macro for automatic uncertainity propgation in MATLAB and GNU Octave.
______________________________________________________________________________
INSTRUCTIONS FOR USAGE

VARIABLE NAMING:
All uncertainty variables in your code must be named as the original variable preceeded by a lowercase '
)%uncertPrefixChar%
(
'.

For example, 
) '%uncertPrefixChar%
(
Temp' must be the name for the variable that stores the uncertainity in the variable 'Temp'.
) '%uncertPrefixChar%
(
P2' would be the uncertainity in 'P2', and so on.

PROPAGATING UNCERTAINITY
If you want to propagate uncertainity into a variable then add a percent sign after the variable's equation. List the  names of the variables to propagate uncertanity from to the right of the percent sign as a comment. Separate the variables with commas, and leave a comma at the end of the variable list. Do all this on a single line and use no spaces in the variable list. 

Then press Ctrl-u while your cursor is on that line, and code will be generated to calculate the uncertanity.

EXAMPLE:

     rho = P2/(R*T2)`%P2,T2,


Pressing Ctrl-u with your cursor at the end of the above line of code will propagate uncertainty from P2 and T2 into rho.
)

MsgBox, 0, Automatic Uncertanity, % helpMsg
;__________________ENDSETUP____________________


;___________________HOTKEYS______________________

^+h::
MsgBox, 0, Automatic Uncertainty, % helpMsg
return

^Esc:: Suspend

^q::Reload

;Uncertanity Propagation hotkey (Numerical Approx. Method)
^u::
Blockinput, On

;retrieve input line using the clipboard and store as variable
inputStr := readInUserInput()

leadingVar:="",equation:="",variables:="",ErrorFlag:=false
ExtractDataFromInput(inputStr, leadingVar, equation, variables, ErrorFlag)
if (ErrorFlag)
{
     return
}
outputStr := getOutputString(inputStr, uncertPrefixChar, leadingVar, equation, variables, ErrorFlag)
if (ErrorFlag)
{
     return
}

;write output text to editor
writeOutput(outputStr)
BlockInput, Off
return

;Uncertanity Propagation hotkey (Symbolic Method)
^+u::
Blockinput, On

;retrieve input line using the clipboard and store as variable
inputStr := readInUserInput()

leadingVar:="",equation:="",variables:="",ErrorFlag:=false
ExtractDataFromInput(inputStr, leadingVar, equation, variables, ErrorFlag)
if (ErrorFlag)
{
     return
}
outputStr := getOutputStringSym(inputStr, uncertPrefixChar, leadingVar, equation, variables, ErrorFlag)
if (ErrorFlag)
{
     return
}

;write output text to editor
writeOutput(outputStr)
BlockInput, Off
return

;____________________END HOTKEYS_____________________


;_____________________FUNCTIONS___________________
readInUserInput()
{
     Sendinput, {Home}
     sleep, 10
     Sendinput, {shift down}{End}{shift up}
     sleep, 10
     emptyClipboard()
     Sendinput, ^c
     Clipwait
     return clipboard
}

writeOutput(outputStr)
{
     Sendinput, {End}
     sleep,10
     Sendinput, {Enter}
     emptyClipboard()
     Clipboard := outputStr
     Clipwait
     Sendinput, ^v
     sleep, 10
     Sendinput, {Enter}
}

^p::


return

getSymsList(varList)
{
     symPostfix := "_sym"
     length := varList.MaxIndex()
     symsList := []
     loop %length%
     {

          currVar := varList[A_Index]
          sym = %currVar%%symPostfix%
          symsList[A_Index] := sym
     }
     return symsList
}

getOutputString(inputStr, uncertPrefixChar, leadingVar, equation, variables, ByRef ErrorFlag)
{
     ;create the output string
     outputStr = %uncertPrefixChar%%leadingVar%= sqrt( ... `n   ((
     varCount := variables.MaxIndex()
     loop, %varCount%
     {
          currVar := variables[A_Index]
          replacement = (%currVar%+%uncertPrefixChar%%currVar%)

          startPos := 0  ;Parse the string from right to left when replacing variables
          newEq := replaceVarName(equation,currVar,startPos,replacement)

          if (newEq == equation)
          {
               Sendinput, {End}
               ErrorFlag := true
               MsgBox Error. The variable name "%currVar%" was not found in the equation. Check for typos in the equation or the list of variables to propagate uncertainity from. `n Ctrl+Shift+H for help.
               return ""
          }
          

          if(A_Index == varCount)
     {
          outputstr = %outputstr%%newEq%) - %leadingVar%)^2);
     }
     else
     {
          outputstr = %outputstr%%newEq%) - %leadingVar%)^2 ... `n + ((
     }

     }
     return outputstr
}

getOutputStringSym(inputStr, uncertPrefixChar, leadingVar, equation, variables, ByRef ErrorFlag)
{
     ;create the output string
     symPostfix := "_sym"
     leadingVarSym = %leadingVar%%symPostfix%
     
     uLeadLine = %uncertPrefixChar%%leadingVarSym%= sqrt( ... `n   (
     

     symVars := getSymsList(variables)
     symLine := "syms"
     doubleLine = %uncertPrefixChar%%leadingVar% = double(subs(%uncertPrefixChar%%leadingVarSym%,{

     varCount := variables.MaxIndex()
     loop, %varCount%
     {
          currVarSym := symVars[A_Index]
          spc := " "
          symLine = %symLine%%spc%%currVarSym%
          
          
          currVar := variables[A_Index]    
          startPos := 0  ;Parse the string from right to left when replacing variables
          newEq := replaceVarName(equation,currVar,startPos,currVarSym)
          if (newEq == equation)
          {
               Sendinput, {End}
               ErrorFlag := true
               MsgBox Error. The variable name "%currVar%" was not found in the equation. Check for typos in the equation or the list of variables to propagate uncertainity from. `n Ctrl+Shift+H for help.
               return ""
          }
          equation :=newEq

          

          if(A_Index == varCount)
          {
               uLeadLine = %uLeadLine%%uncertPrefixChar%%currVar%*diff(%leadingVarSym%,%currVarSym%))^2)
               doubleLine = %doubleLine%%currVarSym%},{
               loop %varCount%
               {
                    currVar := variables[A_Index]
                    if(A_Index == varCount)
                    {
                         doubleLine = %doubleLine%%currVar%}))
                    }
                    else
                    {
                         doubleLine = %doubleLine%%currVar%,
                    }

               }
          }
          else
          {
               uLeadLine = %uLeadLine%%uncertPrefixChar%%currVar%*diff(%leadingVarSym%,%currVarSym%))^2 ... `n + (
               doubleLine = %doubleLine%%currVarSym%,
               
          }

     }
     eqLine = %leadingVar%_sym = %equation%


     outputStr = %symLine%`n%eqLine%`n%uLeadLine%`n%doubleLine%
     return outputstr
}

ExtractDataFromInput(inputStr, ByRef leadingVar, ByRef equation, ByRef variables, ByRef ErrorFlag)
{
     ;Get name of variable to propagate uncertainity into
     leadingVar := getLeadingVar(inputStr)
     if (leadingVar == "")
     {
          Sendinput, {End}
          ErrorFlag := true
          MsgBox, Error. There needs to be an '=' in the equation line. `n Ctrl+Shift+H for help.
          return ""
     }

     ;get the equation for vName, handle ending semicolon if needed
     equation := getEqForLeadingVar(inputStr)
     if (equation = "")
     {
          Sendinput, {End}
          ErrorFlag := true
          MsgBox, Error. There needs to be an equals sign before the equation and a percent sign after the equation. `n Ctrl+Shift+H for help.
          return ""
     }

     ;make a list of the variables in the equation
     if(!isEndCharComma(inputStr))
     {
          Sendinput, {End}
          ErrorFlag := true
          MsgBox, Error. Make sure to put a comma at the end of the variable list. `n Ctrl+Shift+H for help.
          return ""
     }
     variables := makePropVarList(inputStr)
     if(variables=="")
     {
          Sendinput, {End}
          ErrorFlag := true
          MsgBox, Error. Whitespace to the right of the percent sign is not allowed. `n Ctrl+Shift+H for help.
          return ""
     }
}

makePropVarList(Line)
{
     ;remove trailing whitespace
     lastChar := SubStr(Line,0)
     while (lastChar == " ")
     {    
          Line :=SubStr(Line,1,StrLen(Line)-1)
          lastChar := SubStr(Line,0)
     }

     ;check for whitespace formatting in var list
     p1 := InStr(Line,"%")
     if (InStr(Line," ",false,p1))
     {
          return ""
     }
     
     p2 := InStr(Line,",",false, p1)
     varCount := 0
     variables:= []
     while (p1 != 0 and p2 != 0 and p1 != p2)
     {
          var := % SubStr(Line,p1+1,p2-p1-1)
          if (var != "")
          {
               varCount++
               variables[varCount] :=  var
          }
          p1 := p2
          p2 := InStr(Line,",",false, p1+1,1)
     }
     if (variables.MaxIndex()==0)
     {
          return ""
     }
     return variables
}

getEqForLeadingVar(Line)
{
     equalSpot := InStr(Line,"=")
     if (equalSpot == 0)
     {
          return ""
     }
     percentSpot := InStr(Line,"%")
     if (percentSpot == 0)
     {
          return ""
     }
     equation := SubStr(Line,equalSpot+1,percentSpot-equalSpot-1)
     lastChar := SubStr(equation,0)
     while (lastChar == " " OR lastChar == ";")
     {    
          equation :=SubStr(equation,1,StrLen(equation)-1)
          lastChar := SubStr(equation,0)
     }
     firstChar := SubStr(equation,1,1)
     while (firstChar == " ")
     {
          
          equation :=SubStr(equation,2,StrLen(equation))
          firstChar := SubStr(equation,1,1)
     }
     return equation
}

getLeadingVar(Line)
{
EqualSpot := InStr(Line,"=")
if (EqualSpot == 0)
{
     return ""
}
vName := % SubStr(Line,1,EqualSpot-1)
vName := StrReplace(vName," ","")
return vName
}

;determine if ending char is comma, ignoring trailing space
isEndCharComma(Line)
{
     endchar := SubStr(Line,0)

     if(endchar == ",")
     {
          return true
     }
     else if (endchar == " ")
     {
          return isEndCharComma(SubStr(Line,1,(StrLen(Line)-1)))  
     }
     else 
     {
          return false
     }
}

replaceVarName(Whole,  varToReplace, searchStartPos, replacementText)
{    
     ;find position of variable name occurence
     varLoc := InStr(Whole,varToReplace,True,searchStartPos)
     if (varLoc=0)
     {
          return Whole
     }
     
     ;Determine if leading/trailing chars are alphaNumeric
     p2 := varLoc + StrLen(varToReplace)
     p1 := varLoc - 1
     leadingChar := SubStr(Whole,p1,1)
     trailingChar := SubStr(Whole,p2,1)

     if (p1<1)      ;adjust for string occurences at beginning/end of Whole
     {
          leadingChar := " "
     }
     if (p2>StrLen(Whole))
     {
          trailingChar := " "
     }

     isLeadingAlNum := 0, isTrailingAlNum := 0
     if leadingChar is AlNum
     {
          isLeadingAlNum := 1
     }
     if trailingChar is Alnum
     {
          isTrailingAlNum := 1
     }

     ;Replace the string only if the leading/trailing chars are not alphanumeric or underscores
     underscore := "_"
     if ((isLeadingAlNum OR  ("" .  leadingChar = underscore)) OR (isTrailingAlNum OR  ("" .  trailingChar = underscore)))
     {
          searchStartPos := varLoc-StrLen(Whole)-1
          return replaceVarName(Whole,varToReplace,searchStartPos,replacementText)
     }
     else
     {
          rightSide := SubStr(Whole, varLoc)
          StringCaseSense, On 
          rightSide := StrReplace(rightSide,varToReplace,replacementText,,1)
          Whole := SubStr(Whole, 1, varLoc-1) 
          Whole := Whole . rightSide
          searchStartPos := varLoc-StrLen(Whole)-1
          return replaceVarName(Whole,varToReplace,searchStartPos,replacementText)
     }
}

exitOnError(errorflag)
{
     if (errorflag)
     {
          ExitApp
     }
}

emptyClipboard()
{
     clipboard:=""
     While clipboard
     {
          Sleep 10 
     }
}

;__________________END FUNCTIONS______________________







