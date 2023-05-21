
$DefaultUnsafeCharacters = [ordered]@{
  # Windows PowerShell versions up to v5.1 misinterprets UTF-8 as ANSI-encoded
  # unless BOM is included.
  # Avoiding this potential leeway to copy + paste errors --
  # using character codes
  Umlauts = [ordered]@{
    $([char]196) = "Ae"
    $([char]214) = "Oe"
    $([char]220) = "Ue"
    $([char]228) = "ae"
    $([char]246) = "oe"
    $([char]252) = "ue"
  }
  Ligatures = [ordered]@{
    $([char]223) = "ss"
    $([char]7838) = "SS"
  }
  # to find more character code pages, run in powershell:
  # 128..256 | %{"$_ $([char]$_)"} | grep <special character>

}

function Get-TitleCase {
  param(
    [Parameter(ValueFromPipeline = $true)]
    [string]
    $String = ""
  )
  [cultureinfo]::GetCultureInfo("en-US").TextInfo.ToTitleCase($String)

}
function Remove-UnsafeCharacters {
  param(
    [Parameter(ValueFromPipeline = $true)]
    [string]
    $String = "",

    [Parameter()]
    [hashtable]
    $UnsafeCharacters = $DefaultUnsafeCharacters['Umlauts'] + $DefaultUnsafeCharacters['Ligatures']
  )
  foreach ($char in $UnsafeCharacters.keys) {
    $String = $String -replace $char,$UnsafeCharacters[$char]
  }

  $String
}

function Reduce ($initial,$sb) {
  begin {
    $result = $initial
  }

  process {
    $result = & $sb $result $_
  }

  end {
    $result
  }
}


filter Acronymize {
  param(
    [Parameter(ValueFromPipeline = $true)]
    [string]
    $String = "",

    [Parameter()]
    [hashtable]
    $UnsafeCharacters = $DefaultUnsafeCharacters['Umlauts'] + $DefaultUnsafeCharacters['Ligatures'],

    [Parameter()]
    [array]
    $VovelLikeCharacters = $DefaultUnsafeCharacters['Umlauts'].keys + ("a","e","u","o","i")
  )

  if ($String.Length -eq 1) {
    return $String | `
       Remove-UnsafeCharacters -UnsafeCharacters $UnsafeCharacters | `
       Get-TitleCase
  }
  $Vovels = $VovelLikeCharacters -join ""
  $Consonants = (65..90 + 223 + 7838 | `
       ForEach-Object { "$([char]$_)" } `
    ) -join "" -replace "[$Vovels]",""

  $regex = @"
        (?i)
        ^
        [\s\-]*
        (?<token>
            # pick one of the different ways to determine which token to derive from
            # the currently proceessed part:

            # if it is not followed by another part:
                (?!.+[\-\s]+.+$)
                (
                    (?=.{4,}$)([$Consonants][$Vovels] | [$Vovels][$Consonants])
                    |
                    [$Vovels]
                    |
                    [$Consonants]
                )
            |

            # else:
                [\S^\-][$Consonants]((?=\S+[\s\-]+[$Consonants])[$Vovels])?
            |
                [\S^\-][$Vovels]((?=\S+[\s\-]+[$Vovels])[$Consonants])?
            |

            # if none of the above applies:
            [\S^\-]?
        )

        # it should be followed by something that doesn't contribute to the token.
        # Non-Greedy as indicated by question mark
        [\S^\-]+?

        # the remainder is determined beginning after any kind of space or dash:
        ([\s\-]+
            (?<remainder>.+)
        )?
        $
"@ -replace '#[^\n]*','' -replace '[\n\s]+',''

  $Shorten = {
    param($x,$y)

    $remainder = $([regex]::Replace($y,$regex,'${remainder}'))
    $token = $([regex]::Replace($y,$regex,'${token}') | `
         Remove-UnsafeCharacters -UnsafeCharacters $UnsafeCharacters | `
         Get-TitleCase
    )

    if ($remainder) {
      return $remainder | Reduce ($x + $token) $Shorten
    }
    else {
      return ($x + $token)
    }
  }

  ($($String -replace '[\n]+',' ') | Reduce @() $Shorten) -join ""

}
