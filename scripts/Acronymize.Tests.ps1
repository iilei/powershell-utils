BeforeAll {
  .$PSCommandPath.Replace('.Tests.ps1','.ps1')
}


Describe 'Acronymize' {
  It 'yields a quirky Acronym for a ridiculoulsy long name string even when it contains newlines' {
    @"
  Clarabella
  Wei$([char]223)enfein-K$([char]252)benhoff
  $([char]196)llenbarg
  Krantz
"@ `
       | Acronymize | Should -Be 'ClaWeKuebAelK'
  }

  It 'yields Acronym "JoRo" for "Jon Rocknose"' {
    "Jon Rocknose" | Acronymize | Should -Be 'JoRo'
  }

  It 'yields Acronym "JohOl" for "John Olson"' {
    "John Olson" | Acronymize | Should -Be 'JohOl'
  }

  It 'yields Acronym "JoBo" for "Jon Borison"' {
    "Jon Borison" | Acronymize | Should -Be 'JoBo'
  }
  It 'yields Acronym "" for ""' {
    "" | Acronymize | Should -Be ''
  }
  It "yields Acronym `"Oe`" for `"$([char]214)`"" {
    "$([char]214)" | Acronymize | Should -Be 'Oe'
  }
  It 'yields Acronym "B" for "Bob"' {
    "Bob" | Acronymize | Should -Be 'B'
  }
  It 'yields Acronym "E" for "Eo"' {
    "Eo" | Acronymize | Should -Be 'E'
  }
}
