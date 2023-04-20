####
# Launching the application with the prefired keyboard layout
#   
# @author Jonas Otter https://github.com/kriakiku
####

# Application link. For example picked Steam: CoD Modern Warfare II
# You can find the path by looking at the shortcut property of the application you need
$configApplicationPath = $args[0]

# Locale region pattern to avoid creating a fallback locale
# Value examples: en (English: en-US, en-GB), - (leave the value blank if you need a locale without a region (such as uk, ru))
$configLocalePattern = $args[1]

# The locale that will be added to the system if there is no existing one
# Value examples: en-US (English), de-DE (German), uk (Ukranian), ru (Russian)
$configFallbackLocale = $args[2]


####
# Switch current keyboard layout
####

# Try to find already exist locale
function Get-PrefiredLanguage {
    $languageList = Get-WinUserLanguageList

    foreach ($language in $languageList) {
        if (($language.LanguageTag -clike "$configLocalePattern-*") -or ($language.LanguageTag -eq $configFallbackLocale)) {
            Write-Output $language
            break
        }
    }
}

# Force add locale if not found by pattern
if ($null -eq (Get-PrefiredLanguage)) {
    $languageList = Get-WinUserLanguageList
    [void]$languageList.Add($configFallbackLocale)
    Set-WinUserLanguageList $languageList -Force
}


# Switch keyboard language if has needed locale using language list update trick
$prefiredLanguage = Get-PrefiredLanguage
if ($null -ne $prefiredLanguage) {
    $languageList = Get-WinUserLanguageList
    $sortedLanguageList = [System.Collections.Generic.List[string]]::new()

    # Add prefired language to start of language list
    [void]$sortedLanguageList.Add($prefiredLanguage.LanguageTag);

    # Fill sorted language list (ignoring force picked locale)
    foreach ($language in $languageList) {
        if ($language.LanguageTag -ne $prefiredLanguage.LanguageTag) {
            [void]$sortedLanguageList.Add($language.LanguageTag);
        }
    }

    # Set default input method
    $InputMethodTips = $prefiredLanguage.InputMethodTips
    Set-WinDefaultInputMethodOverride -InputTip "$InputMethodTips"

    # Update user available input methods (trick to reset currently picked keyboard layout)
    Set-WinUserLanguageList $sortedLanguageList -Force
}

###
# Launch application
###
Start-Process $configApplicationPath
