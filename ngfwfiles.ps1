$global:ruleId = 100005

function Menu {
    param (
        [string]$Title = 'Untangle NGFW File Creator'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "Choose the type of file you want to make:"
    Write-Host "1: Firewall Rule"
    Write-Host "2: NAT Rule"
    Write-Host "3: Filter Rule"
    Write-Host "Q: Press 'Q' to quit."
}

function Firewall_Rule {
    $csvLocation = read-host -Prompt "Enter the path to your IPs CSV (ex. 'C:\Users\admin\Documents\IPsforUntangle.csv')"
    $jsonOutput = read-host -Prompt "Enter the ouput path to your Firewall Rule JSON (ex. 'C:\Users\admin\Documents\FirewallRules.json')"   
    #Select Rows with this value in the CSV column Type
    $type = "Block"
     
    $ipscsv = Import-Csv $csvLocation
     
    #Declare empty array with an empty custom object inside. JSON wants an array [square brackes] with {curly brackets inside} so like this [{}]
    $firewallRules = @([PSCustomObject]@{})
     
    #Run the following for each row in the CSV
    foreach ($ips in $ipscsv) {
     
        #If the Type Column of the CSV contains the the Type set above.
        if($ips."Type" -eq $type){
     
            #Template for the firewall rule exported from Untangle and converted into a Powershell Custom Object.
            $firewallRule = [PSCustomObject]@{
                "flag"= $true
                "javaClass"= "com.untangle.app.firewall.FirewallRule"
                "description"= $ips."Description"
                "block"= $true
                "conditions"= [PSCustomObject]@{
                    "javaClass"= "java.util.LinkedList"
                    "list"= @([PSCustomObject]@{
                         
                            "invert"= $false
                            "javaClass"= "com.untangle.app.firewall.FirewallRuleCondition"
                            "conditionType"= "SRC_ADDR"
                            "value"= $ips."Ips"
                    }  
                    )
                }
                "ruleId"= $ruleId
                "enabled"= $false
            }
            #Add rule to a list of rules
            $firewallRules += $firewallRule
     
            #Add one to the rule ID for the next rule
            $ruleId = $ruleId + 1
        }
    }
     
    #Skip the first object which is an empty {} from declaring the custom object at the beginning.
    $firewallRules = $firewallRules | Select-Object -Skip 1
     
    #Convert to JSON
    $firewallRulesJSON = $firewallRules | ConvertTo-Json -Depth 4
     
    #Export to File
    $firewallRulesJSON | Out-File $jsonOutput
}

function NAT_Rule {
    $csvLocation = read-host -Prompt "Enter the path to your IPs CSV (ex. 'C:\Users\admin\Documents\IPsforUntangle.csv')"
    $jsonOutput = read-host -Prompt "Enter the ouput path to your NAT Rule JSON (ex. 'C:\Users\admin\Documents\NATRules.json')"
    
    $type = "NAT"
    
    #Enter the outbound bound IP, or New Source IP for these rules. 
    $newSource = read-host -Prompt "What new source IP do you want for this rule?  "
    
    $ipscsv = Import-Csv $csvLocation
    
    $NatRules = @([PSCustomObject]@{})
    
    foreach ($ips in $ipscsv) {
    
        if($ips."Type" -eq $type){
    
            $NatRule = [PSCustomObject]@{
                "auto"= $false
                "newSource"= $newSource
                "javaClass"= "com.untangle.uvm.network.NatRule"
                "description"= $ips."Description"
                "conditions"= [PSCustomObject]@{
                    "javaClass"= "java.util.LinkedList"
                    "list"= @([PSCustomObject]@{
                        
                            "invert"= $false
                            "javaClass"= "com.untangle.uvm.network.NatRuleCondition"
                            "conditionType"= "SRC_ADDR"
                            "value"= $ips."Ips"
                    }  
                    )
                }
                "ruleId"= $ruleId
                "enabled"= $false
            }
            $NatRules += $NatRule
            $ruleId = $ruleId + 1
        }
    }

    $NatRules = $NatRules | Select-Object -Skip 1

    $NatRulesJSON = $NatRules | ConvertTo-Json -Depth 4
 
    $NatRulesJSON | Out-File $jsonOutput
}

function Filter_Rule {
    $csvLocation = read-host -Prompt "Enter the path to your IPs CSV (ex. 'C:\Users\admin\Documents\IPsforUntangle.csv')"
    $jsonOutput = read-host -Prompt "Enter the ouput path to your Filter Rule JSON (ex. 'C:\Users\admin\Documents\FilterRules.json')"
   
    $type = "Filter"
    
    $ipscsv = Import-Csv $csvLocation
    
    $filterRules = @([PSCustomObject]@{})
    
    foreach ($ips in $ipscsv) {
    
        if($ips."Type" -eq $type){
    
            $filterRule = [PSCustomObject]@{
                "blocked"= $true
                "javaClass"= "com.untangle.uvm.network.FilterRule"
                "description"= $ips."Description"
                "readOnly"= $null
                "ipvsEnabled"= $true
                "conditions"= [PSCustomObject]@{
                    "javaClass"= "java.util.LinkedList"
                    "list"= @([PSCustomObject]@{
                        
                            "invert"= $false
                            "javaClass"= "com.untangle.uvm.network.FilterRuleCondition"
                            "conditionType"= "SRC_ADDR"
                            "value"= $ips."Ips"
                    }  
                    )
                }
                "ruleId"= $ruleId
                "enabled"= $true
            }
            $filterRules += $filterRule
    
            $ruleId = $ruleId + 1
        }
}
 
$filterRules = $filterRules | Select-Object -Skip 1
 
$filterRulesJSON = $filterRules | ConvertTo-Json -Depth 4
 
$filterRulesJSON | Out-File $jsonOutput
}

do
{
     Menu
     $choice = Read-Host "Please make a selection"
     switch ($choice)
     {
           '1' {
                Clear-Host
                Firewall_Rule
           } '2' {
                Clear-Host
                NAT_Rule
           } '3' {
                Clear-Host
                Filter_Rule
           } 'q' {
                return
           }
     }
     pause
}
until ($choice -eq 'q')