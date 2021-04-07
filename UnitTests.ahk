;#Include AutoU statement is at the bottom of this script in order the suppress the Msgbox that appears when Auto Uncertainity is run.


;Testing function
Test(returned,expected,testname)
{
    if (returned != expected)
    {
        msgbox, 1,, Test failed: `n `n `t '%testname%'  `n `n Returned:     '%returned%' `n Expected:      '%expected%'
        IfMsgBox, Cancel
        {
            exitapp
        }
    }
}

arr2str(arr)
{   
    str := "| ", length :=arr.MaxIndex(), index = 1
    loop %length%
    {
        str := str arr[index] " | "
        index++
    }
    return str
}



;Tests for getSymsList(varList)
Test(arr2str(getSymsList(["Temp","p2","Pres_2"])),arr2str(["Temp_sym","p2_sym","Pres_2_sym"]),"getSymsList(varList) - standard")

;Tests for makePropVarList(Line)
Test(arr2str(makePropVarList("P=mass*R*temp/vol %mass,")),arr2str(["mass"]),"makePropVarList() - one var")
Test(arr2str(makePropVarList("P=mass*R*temp/vol %  mass  ,")),arr2str([]),"makePropVarList() - one var, spaces")
Test(arr2str(makePropVarList("P=mass*R*temp/vol %mass,temp,")),arr2str(["mass","temp"]),"makePropVarList() - two vars")
Test(arr2str(makePropVarList("P=mass*R*temp/vol % mass, temp ,")),arr2str([]),"makePropVarList() - two vars, spaces")
Test(arr2str(makePropVarList("P=mass*R*temp/vol %mass temp vol")),arr2str([]),"makePropVarList() - no commas")
Test(arr2str(makePropVarList("P=mass*R*temp/vol;mass,temp,vol,")),arr2str([]),"makePropVarList() - no percent")
Test(arr2str(makePropVarList("P4= Mass*Mas*Temp2/reg %,,,reg,,Mas,,")),arr2str(["reg","Mas"]),"makePropVarList() - extra commas")
Test(arr2str(makePropVarList("P=mass*R*temp/vol %mass,temp,vol,r,p_j,B,")),arr2str(["mass","temp","vol","r","p_j","B"])
,"makePropVarList() - many vars")

;Tests for getEqForLeadingVar(Line)
Test(getEqForLeadingVar("Pressure=mass*R*temp/Volume%mass,temp,R"),"mass*R*temp/Volume","getEqForLeadingVar() - standard")
Test(getEqForLeadingVar("Pressure=mass*R*temp/Volume;%mass,temp,R"),"mass*R*temp/Volume","getEqForLeadingVar() - ending semicolon")
Test(getEqForLeadingVar("Pressure=mass*R*temp/Volume  %mass,temp,R"),"mass*R*temp/Volume","getEqForLeadingVar() - trailing space")
Test(getEqForLeadingVar("Pressure=  mass*R*temp/Volume %mass,temp,R"),"mass*R*temp/Volume","getEqForLeadingVar() - leading space")
Test(getEqForLeadingVar("Pressure=mass*R*temp/Volume; %mass,temp,R"),"mass*R*temp/Volume","getEqForLeadingVar() - semicolon then space")
Test(getEqForLeadingVar("Pressure=mass*R*temp/Volume `; `;  %mass,temp,R"),"mass*R*temp/Volume","getEqForLeadingVar() - mutliple spaces/semicolons")
Test(getEqForLeadingVar("Pressure=mass*R*temp/Volumemass,temp,R"),"","getEqForLeadingVar() - no percent sign")
Test(getEqForLeadingVar("Pressure mass*R*temp/Volume%mass,temp,R"),"","getEqForLeadingVar() - no equal sign")

;Tests for getLeadingVar(Line)
Test(getLeadingVar("Pressure=mRT/V%P,m,"),"Pressure","getLeadingVar() - standard")
Test(getLeadingVar("Pressure =mRT/V%P,m,"),"Pressure","getLeadingVar() - trailing space")
Test(getLeadingVar(" Pressure =mRT/V%P,m,"),"Pressure","getLeadingVar() - leading space")
Test(getLeadingVar("PressuremRT/V%P,m,"),"","getLeadingVar() - no '=' in line)")

;Tests for isEndCharComma(Line)
Test(isEndCharComma("P=mRT/V%P,m,"),true,"isEndCharComma() - comma at end")
Test(isEndCharComma("P=mRT/V%P,m, "),true,"isEndCharComma() - trailing space")
Test(isEndCharComma("P=mRT/V%P,m,    "),true,"isEndCharComma() - multiple trailing spaces")
Test(isEndCharComma("P=mRT/V%P  ,  "),true,"isEndCharComma() - spaces before and after comma")
Test(isEndCharComma("P=mRT/V%P,m"),false,"isEndCharComma() - no comma at end")
Test(isEndCharComma("P=mRT/V%P,m "),false,"isEndCharComma() - no comma at end with trailing space")
Test(isEndCharComma("P=mRT/V%P,m   "),false,"isEndCharComma() - no comma at end with trailing spaces")


;Tests for replaceVarName(replaceVarName(Whole, varToReplace, searchStartPos, replacementText)
Test(replaceVarName("Mass*Masshat*R*Temperature/newMass*Volume","r",0,"(r+ur)")
,"Mass*Masshat*R*Temperature/newMass*Volume"
,"StrReplace() - No variable names to replace")

Test(replaceVarName("rrrrMass*Masshat*R*Temperrature/newMarrss*Volumerrrr","r",0,"(r+ur)")
,"rrrrMass*Masshat*R*Temperrature/newMarrss*Volumerrrr"
,"StrReplace() - No variable names to replace, adjacent occurences of proper substrings")

Test(replaceVarName("mass","mass",0,"(mass+umass)")
,"(mass+umass)"
,"StrReplace() - Single occurence of variable name")

Test(replaceVarName("temp_inf* Yt_temp / (temp_inf) /temp_inf_rdy)","temp_inf",0,"(temp_inf+utemp_inf)")
,"(temp_inf+utemp_inf)* Yt_temp / ((temp_inf+utemp_inf)) /temp_inf_rdy)"
,"StrReplace() - Underscore variable names")

Test(replaceVarName("Temp_inf / temp_inf*temp_inf*temp_inF","temp_inf",0,"(temp_inf+utemp_inf)")
,"Temp_inf / (temp_inf+utemp_inf)*(temp_inf+utemp_inf)*temp_inF"
,"StrReplace() - Confirm case sensitivity")

Test(replaceVarName("temp_inf / temp_Inf*temp_inf*temp_inf","temp_Inf",0,"(temp_Inf+utemp_Inf)")
,"temp_inf / (temp_Inf+utemp_Inf)*temp_inf*temp_inf"
,"StrReplace() - Confirm case sensitivity in second direction")

Test(replaceVarName("  Mass*Masshat  *R *Temperature/Volume  ","Mass",0,"(Mass+uMass)")
,"  (Mass+uMass)*Masshat  *R *Temperature/Volume  "
,"StrReplace() - Spaces in the equation")

Test(replaceVarName("exp(ama)+rand(ama - var)*mass/exp(ama)","ama",0,"(ama+uama)")
,"exp((ama+uama))+rand((ama+uama) - var)*mass/exp((ama+uama))"
,"StrReplace() - Overlapping proper substrings")

Test(replaceVarName("amamama*tempamamamama*amamama","ama",0,"(ama+uama)")
,"amamama*tempamamamama*amamama"
,"StrReplace() - Overlapping proper substrings")

Test(replaceVarName("Mass*Masshat*R*Temperature/newMass*Volume","Mass",0,"(Mass+uMass)")
,"(Mass+uMass)*Masshat*R*Temperature/newMass*Volume"
,"StrReplace() - Name of variable to be propagated is proper substring of variable name in equation")

Test(replaceVarName("amamama*tempamamamama*ama*amamama","ama",0,"(ama+uama)")
,"amamama*tempamamamama*(ama+uama)*amamama"
,"StrReplace() - Overlapping proper substrings")

Test(replaceVarName("Masshat*Mass*R*Temperature/Volume*eMass","Mass",0,"(Mass+uMass)")
,"Masshat*(Mass+uMass)*R*Temperature/Volume*eMass"
,"StrReplace() - Name of variable to be propagated is proper substring of variable name at beginning/end")

Test(replaceVarName("MassMass*Mass*R*MassMass/Volume*MassMass","Mass",0,"(Mass+uMass)")
,"MassMass*(Mass+uMass)*R*MassMass/Volume*MassMass"
,"StrReplace() - 2x repetition variable names to be propagated are proper substrings")

Test(replaceVarName("MassMassMass*Mass*R*MassMassMass/Volume*MassMassMass","Mass",0,"(Mass+uMass)")
,"MassMassMass*(Mass+uMass)*R*MassMassMass/Volume*MassMassMass"
,"StrReplace() - 3x repetition variable name proper substring")

Test(replaceVarName("(Mass(*(Mass)*R* Mass+ (Mass) /Volume*Mass)","Mass",0,"(Mass+uMass)")
,"((Mass+uMass)(*((Mass+uMass))*R* (Mass+uMass)+ ((Mass+uMass)) /Volume*(Mass+uMass))"
,"StrReplace() - Parentheses around variable names")

; TODO: Tests for getOutputStr()

msgbox, Tests completed.
ExitApp

#Include AutoU.ahk