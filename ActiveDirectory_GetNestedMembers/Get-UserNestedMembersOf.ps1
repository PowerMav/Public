<#
.SYNOPSIS
Get all groups that a user is member of

.DESCRIPTION
Long description....

.PARAMETER DistinguishedName
DN of the User for who you want to list all Groups (like gpresult /r on local computer)

.PARAMETER Groups
Used to perform recursive MemberOf (Only used Internally in the Function)

.EXAMPLE
 Get-ADUserNestedGroups -DistinguishedName (Get-ADUser -Identity ballin).DistinguishedName | Select-Object Name
 
.NOTES
Thanks to http://blog.tofte-it.dk/powershell-get-all-nested-groups-for-a-user-in-active-directory/ that did all the work, I just made it faster and Adv Func
#>

Function Get-ADUserNestedGroups {
    [cmdletbinding()]
    Param
    (
        # Distinguished Name of the AD user
        [Parameter(Mandatory = $true)]
        [string]$DistinguishedName,

        # Nested groups are being aggregated through this parameter
        [Parameter(Mandatory = $false)]
        [array]$Groups = @()
    )

    # Get the AD object, and get group membership.
    $ADObject = Get-ADObject -Filter "DistinguishedName -eq '$DistinguishedName'" -Properties memberOf, DistinguishedName
    
    # If object exists.
    If($ADObject)
    {
        # Enummurate through each of the groups.
        Foreach($GroupDistinguishedName in $ADObject.memberOf)
        {
            # Get member of groups from the enummerated group.
            $CurrentGroup = Get-ADObject -Filter "DistinguishedName -eq '$GroupDistinguishedName'" -Properties memberOf, DistinguishedName
            # Check if the group is already in the array.
            If($groups -notcontains $GroupDistinguishedName)
            {
                # Add group to array.
                $Groups +=  $CurrentGroup
                # Get recursive groups.
                $Groups = Get-ADUserNestedGroups -DistinguishedName $GroupDistinguishedName -Groups $Groups
            }
        }
    }

    # Return groups.
    Return $Groups
}