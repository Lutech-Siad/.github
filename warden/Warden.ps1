<#
.SYNOPSIS
Warden: controllore di stile e di stato delle issue e delle pull request dell'organizzazione Lutech-Siad.

.DESCRIPTION
Legge tutte le issue e le pull request dei repository indicati, deriva lo Status del project e il campo di
organizzazione «Released In» dai fatti su GitHub (branch, pull request, deployment) e produce un report delle
non conformità alle regole di issues.instructions.md e pull-requests.instructions.md.

Senza -Apply non scrive nulla su GitHub: il report elenca le modifiche che farebbe.

.PARAMETER Repositories
Repository da controllare, senza organizzazione. Predefinito: nexusq-backend, nexusq-frontend, .github.

.PARAMETER Apply
Scrive su GitHub lo Status e il campo «Released In» calcolati.

.PARAMETER FixText
Calcola le correzioni meccaniche al corpo di issue e pull request (intestazioni ### → ##, «Obbiettivo», «->», «Jira»,
«N/A», checkbox → elenco, righe Parent → Riferimenti, sezione Checklist delle pull request) e le elenca nel report;
con -Apply le scrive.

.PARAMETER ClonesRoot
Cartella che contiene i cloni locali dei repository applicativi, usati per il calcolo degli antenati.

.EXAMPLE
pwsh -NoProfile -File warden/Warden.ps1
pwsh -NoProfile -File warden/Warden.ps1 -Apply
#>
[CmdletBinding()]
param(
    [string[]] $Repositories = @('nexusq-backend', 'nexusq-frontend', '.github'),
    [switch] $Apply,
    [switch] $FixText,
    [string] $ClonesRoot = 'C:\Projects\SIAD\nexusq',
    [string] $ReportsDirectory = (Join-Path $PSScriptRoot 'reports')
)

$ErrorActionPreference = 'Stop'
$Organization = 'Lutech-Siad'
$Environments = @('dev', 'test', 'prod')
$ProjectNumbers = @(1, 5, 7, 9)
$ReleasedInFieldId = 'IFT_kgDOAv-fSw'   # campo di organizzazione «Released In» (testo)
$WorkBranchPattern = '^(feature|fix|hotfix)/(\d+)_[a-z0-9-]+$'
$AnyBranchPattern = '^(feature|fix|hotfix|release|backmerge)/\d+_[a-z0-9-]+$'
$CommitTitlePattern = '^(feat|fix|refactor|perf|test|docs|build|ci|chore)\([a-z-]+\): .+|^release: v\d+\.\d+\.\d+$'

function Invoke-Gh {
    param([string[]] $Arguments)
    $output = & gh @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) { throw "gh $($Arguments -join ' ') → $output" }
    return ($output -join "`n")
}

function Get-JsonFromGh {
    param([string[]] $Arguments)
    $text = Invoke-Gh $Arguments
    if ([string]::IsNullOrWhiteSpace($text)) { return @() }
    return $text | ConvertFrom-Json -Depth 20
}

function Repair-Body {
    # Correzioni meccaniche al corpo, fuori dai blocchi di codice. Restituisce il testo corretto e l'elenco delle regole applicate.
    param([string] $Text, [bool] $AllowCheckboxes, [bool] $IsPullRequest)
    $applied = [System.Collections.Generic.List[string]]::new()
    if (-not $Text) { return [pscustomobject]@{ Text = $Text; Applied = @() } }
    $lines = $Text -split "`r?`n"
    $output = [System.Collections.Generic.List[string]]::new()
    $inFence = $false
    $skippingChecklist = $false
    foreach ($line in $lines) {
        if ($line -match '^\s*```') { $inFence = -not $inFence; $output.Add($line); continue }
        if ($inFence) { $output.Add($line); continue }
        if ($IsPullRequest) {
            if ($line -match '^##\s+Checklist\s*$') { $skippingChecklist = $true; $applied.Add('sezione Checklist rimossa'); continue }
            if ($skippingChecklist) {
                if ($line -match '^##\s' -or $line -match '^\s*(Closes|Refs):?\s+#') { $skippingChecklist = $false } else { continue }
            }
        }
        $new = $line
        if ($new -match '^###\s') { $new = $new -replace '^###\s', '## '; $applied.Add('### → ##') }
        if ($new -match 'Obbiettivo') { $new = $new -replace 'Obbiettivo', 'Obiettivo'; $applied.Add('«Obbiettivo» → «Obiettivo»') }
        if ($new -match '\bN/A\b') { $new = $new -replace '\bN/A\b', 'Non applicabile'; $applied.Add('«N/A» → «Non applicabile»') }
        if (-not $AllowCheckboxes -and $new -match '^(\s*)- \[[ xX]\] ') { $new = $new -replace '^(\s*)- \[[ xX]\] ', '$1- '; $applied.Add('checkbox → elenco') }
        if ($new -match '^\s*-?\s*\*{0,2}Parent( issue)?:?\*{0,2}\s*(\S.*)$') {
            $target = $Matches[2].Trim() -replace '\*', ''
            $new = "- Issue: $target — genitore storico"; $applied.Add('riga Parent → Riferimenti')
        }
        # Sostituzioni che devono evitare il codice inline: si lavora sui segmenti fuori dagli apici inversi.
        $segments = $new -split '(`[^`]*`)'
        for ($i = 0; $i -lt $segments.Count; $i += 2) {
            $segment = $segments[$i]
            if ($segment -match '->') { $segment = $segment -replace '->', '→'; $applied.Add('«->» → «→»') }
            if ($segment -match '\bJira\b') { $segment = $segment -replace '\bJira\b', 'JIRA'; $applied.Add('«Jira» → «JIRA»') }
            $segments[$i] = $segment
        }
        $output.Add(($segments -join ''))
    }
    return [pscustomobject]@{ Text = ($output -join "`n"); Applied = @($applied | Sort-Object -Unique) }
}

function Get-IssueNumbersFromText {
    param([string] $Text, [string] $Keyword)
    $numbers = @()
    if (-not $Text) { return $numbers }
    foreach ($match in [regex]::Matches($Text, "(?im)^\s*$Keyword:?\s+#(\d+)")) { $numbers += [int] $match.Groups[1].Value }
    return $numbers
}

# ---------- Project: campi, opzioni e item ----------
Write-Host 'Lettura dei project…'
$Projects = @{}
foreach ($number in $ProjectNumbers) {
    $view = Get-JsonFromGh @('project', 'view', "$number", '--owner', $Organization, '--format', 'json')
    $fields = Get-JsonFromGh @('project', 'field-list', "$number", '--owner', $Organization, '--format', 'json')
    $status = $fields.fields | Where-Object { $_.name -eq 'Status' }
    $items = Get-JsonFromGh @('project', 'item-list', "$number", '--owner', $Organization, '--limit', '1000', '--format', 'json')
    $Projects[$view.title] = [pscustomobject]@{
        Number = $number; Id = $view.id; Title = $view.title
        StatusFieldId = $status.id
        StatusOptions = @{}
        Items = $items.items
    }
    foreach ($option in $status.options) { $Projects[$view.title].StatusOptions[$option.name] = $option.id }
}

function Get-ProjectItem {
    param($Project, [string] $RepositoryUrl, [int] $Number)
    return $Project.Items | Where-Object { ($_.repository -eq $RepositoryUrl -or $_.content.repository -eq $RepositoryUrl -or "https://github.com/$($_.content.repository)" -eq $RepositoryUrl) -and $_.content.number -eq $Number } | Select-Object -First 1
}

function Get-ReleasedInValues {
    # Restituisce, per repository, una tabella numero → @{ NodeId; Value } con il valore corrente di «Released In».
    param([string] $Owner, [string] $Repository)
    $result = @{}
    $cursor = $null
    do {
        $after = if ($cursor) { ", after: `"$cursor`"" } else { '' }
        $query = "{ repository(owner: `"$Owner`", name: `"$Repository`") { issues(first: 100, states: [OPEN, CLOSED]$after) { pageInfo { hasNextPage endCursor } nodes { number id issueFieldValues(first: 20) { nodes { ... on IssueFieldTextValue { value field { ... on IssueFieldText { name } } } } } } } } }"
        $page = Get-JsonFromGh @('api', 'graphql', '-f', "query=$query")
        foreach ($node in $page.data.repository.issues.nodes) {
            $value = ''
            foreach ($fieldValue in $node.issueFieldValues.nodes) { if ($fieldValue.field.name -eq 'Released In') { $value = [string] $fieldValue.value } }
            $result[[int] $node.number] = @{ NodeId = $node.id; Value = $value }
        }
        $cursor = if ($page.data.repository.issues.pageInfo.hasNextPage) { $page.data.repository.issues.pageInfo.endCursor } else { $null }
    } while ($cursor)
    return $result
}

# ---------- Lettura dei repository ----------
$Report = [System.Text.StringBuilder]::new()
$Changes = @()
$Findings = @()
$TextFixes = @()
$Now = Get-Date
[void] $Report.AppendLine("# Warden: rapporto del $($Now.ToString('dd/MM/yyyy HH:mm'))")
[void] $Report.AppendLine()
[void] $Report.AppendLine(('Modalità: ' + $(if ($Apply) { 'applicazione' } else { 'sola lettura' })))
[void] $Report.AppendLine()

foreach ($repository in $Repositories) {
    $fullName = "$Organization/$repository"
    $repositoryUrl = "https://github.com/$fullName"
    Write-Host "Repository $fullName…"

    $issues = @(Get-JsonFromGh @('issue', 'list', '--repo', $fullName, '--state', 'all', '--limit', '1000', '--json', 'number,title,body,state,issueType,milestone,assignees,labels,projectItems,url'))
    $pulls = @(Get-JsonFromGh @('pr', 'list', '--repo', $fullName, '--state', 'all', '--limit', '1000', '--json', 'number,title,body,state,baseRefName,headRefName,mergedAt,mergeCommit,url,assignees,milestone,isDraft'))
    $branches = @((Invoke-Gh @('api', "repos/$fullName/branches", '--paginate', '--jq', '.[].name')) -split "`n" | Where-Object { $_ })
    $releasedValues = Get-ReleasedInValues $Organization $repository

    # Deployment attivi per ambiente
    $activeDeployments = @{}
    $clonePath = Join-Path $ClonesRoot $repository
    $hasClone = Test-Path (Join-Path $clonePath '.git')
    if ($repository -ne '.github') {
        foreach ($environment in $Environments) {
            $deployments = @(Get-JsonFromGh @('api', "repos/$fullName/deployments?environment=$environment&per_page=10"))
            foreach ($deployment in $deployments) {
                $statuses = @(Get-JsonFromGh @('api', "repos/$fullName/deployments/$($deployment.id)/statuses"))
                if ($statuses | Where-Object { $_.state -eq 'success' }) {
                    $activeDeployments[$environment] = [pscustomobject]@{ Ref = $deployment.ref; Sha = $deployment.sha; Date = $deployment.created_at }
                    break
                }
            }
        }
        if ($hasClone) { & git -C $clonePath fetch --quiet --prune origin 2>$null }
    }

    # Pull request collegate a ogni issue: dal nome del branch e dal footer
    $pullsByIssue = @{}
    foreach ($pull in $pulls) {
        $linked = @()
        if ($pull.headRefName -match $WorkBranchPattern) { $linked += [int] $Matches[2] }
        $linked += Get-IssueNumbersFromText $pull.body 'Closes'
        $linked += Get-IssueNumbersFromText $pull.body 'Refs'
        foreach ($number in ($linked | Sort-Object -Unique)) {
            if (-not $pullsByIssue.ContainsKey($number)) { $pullsByIssue[$number] = @() }
            $pullsByIssue[$number] += $pull
        }
    }

    [void] $Report.AppendLine("## $fullName")
    [void] $Report.AppendLine()
    [void] $Report.AppendLine("Issue lette: $($issues.Count). Pull request lette: $($pulls.Count).")
    if ($activeDeployments.Count -gt 0) {
        [void] $Report.AppendLine()
        [void] $Report.AppendLine('| Ambiente | Ref installata | Commit | Registrato il |')
        [void] $Report.AppendLine('|---|---|---|---|')
        foreach ($environment in $Environments) {
            $deployment = $activeDeployments[$environment]
            if ($deployment) { [void] $Report.AppendLine("| ``$environment`` | ``$($deployment.Ref)`` | ``$($deployment.Sha.Substring(0,7))`` | $(([datetime]$deployment.Date).ToString('dd/MM/yyyy')) |") }
            else { [void] $Report.AppendLine("| ``$environment`` | nessun deployment registrato | | |") }
        }
    }
    [void] $Report.AppendLine()

    # ---------- Issue ----------
    foreach ($issue in $issues) {
        $number = [int] $issue.number
        $reasons = @()

        # Stile
        if ($issue.title.Length -gt 80) { $reasons += 'titolo oltre 80 caratteri' }
        if ($issue.title -match '^\[(BE|FE)\]|^\[[^\]]+\]') { $reasons += 'titolo con prefisso fra parentesi quadre' }
        if (-not $issue.issueType) { $reasons += 'Issue Type mancante' }
        if (-not $issue.milestone) { $reasons += 'milestone mancante' }
        if (-not $issue.projectItems -or $issue.projectItems.Count -eq 0) { $reasons += 'project mancante' }
        if (-not $issue.assignees -or $issue.assignees.Count -eq 0) { $reasons += 'assegnatario mancante' }
        $body = [string] $issue.body
        if ($body -match '(?m)^###\s') { $reasons += 'intestazioni ### nel corpo' }
        if ($body -match '(?im)^\s*-?\s*\*{0,2}Parent( issue)?:?\*{0,2}\s') { $reasons += 'riga Parent: nel corpo' }
        if ($FixText) {
            $repair = Repair-Body -Text $body -AllowCheckboxes ($issue.issueType.name -in @('Feature', 'RFC', 'CR')) -IsPullRequest $false
            if ($repair.Text -ne $body) { $TextFixes += [pscustomobject]@{ Repository = $repository; Kind = 'issue'; Number = $number; Url = $issue.url; Applied = ($repair.Applied -join '; '); Text = $repair.Text } }
        }
        if ($body -notmatch '(?m)^##\s+Obiettivo') { $reasons += 'sezione Obiettivo mancante' }
        if ($body -notmatch '(?m)^##\s+Riferimenti') { $reasons += 'sezione Riferimenti mancante' }
        if ($body -match 'Obbiettivo') { $reasons += '«Obbiettivo»' }
        if ($body -match '\bN/A\b') { $reasons += '«N/A»' }
        if ($body -match '\bJira\b') { $reasons += '«Jira» invece di «JIRA»' }
        if ($body -match '->') { $reasons += '«->» invece di «→»' }
        if ($body -match '(?m)^\s*- \[[ x]\]' -and $issue.issueType.name -notin @('Feature', 'RFC', 'CR')) { $reasons += 'checkbox nel corpo' }

        # Stato derivato
        $linkedPulls = @($pullsByIssue[$number])
        $mergedPulls = @($linkedPulls | Where-Object { $_.mergedAt })
        $openPulls = @($linkedPulls | Where-Object { $_.state -eq 'OPEN' })
        $hasBranch = $branches | Where-Object { $_ -match "^(feature|fix|hotfix)/$number`_" } | Select-Object -First 1
        $derivedStatus = 'Backlog'
        if ($issue.state -eq 'CLOSED') { $derivedStatus = 'Done' }
        elseif ($mergedPulls.Count -gt 0) { $derivedStatus = 'Merged' }
        elseif ($openPulls.Count -gt 0) { $derivedStatus = 'In Review' }
        elseif ($hasBranch) { $derivedStatus = 'In Progress' }

        # Released In
        $releasedIn = @()
        if ($hasClone -and $mergedPulls.Count -gt 0) {
            foreach ($environment in $Environments) {
                $deployment = $activeDeployments[$environment]
                if (-not $deployment) { continue }
                foreach ($pull in $mergedPulls) {
                    if (-not $pull.mergeCommit.oid) { continue }
                    & git -C $clonePath merge-base --is-ancestor $pull.mergeCommit.oid $deployment.Sha 2>$null
                    if ($LASTEXITCODE -eq 0) { $releasedIn += $environment; break }
                }
            }
        }
        $releasedText = ($releasedIn -join ', ')
        $current = $releasedValues[$number]
        if ($current -and $current.Value -ne $releasedText -and -not ($current.Value -eq '' -and $releasedText -eq '')) {
            $Changes += [pscustomobject]@{ Repository = $repository; Number = $number; Project = '—'; Field = 'Released In'; From = $current.Value; To = $releasedText; ItemId = $null; ProjectId = $null; FieldId = $ReleasedInFieldId; OptionId = $null; Text = $releasedText; IssueNodeId = $current.NodeId }
        }

        # Confronto con i project
        foreach ($projectItem in $issue.projectItems) {
            $project = $Projects[$projectItem.title]
            if (-not $project) { continue }
            $item = Get-ProjectItem $project $repositoryUrl $number
            if (-not $item) { continue }
            $currentStatus = [string] $item.status
            $targetStatus = $derivedStatus
            if ($currentStatus -eq 'Blocked' -and $issue.state -ne 'CLOSED') { $targetStatus = 'Blocked' }
            if ($currentStatus -ne $targetStatus) {
                $Changes += [pscustomobject]@{ Repository = $repository; Number = $number; Project = $project.Title; Field = 'Status'; From = $currentStatus; To = $targetStatus; ItemId = $item.id; ProjectId = $project.Id; FieldId = $project.StatusFieldId; OptionId = $project.StatusOptions[$targetStatus]; Text = $null; IssueNodeId = $null }
            }
        }

        if ($reasons.Count -gt 0) {
            $Findings += [pscustomobject]@{ Repository = $repository; Kind = 'issue'; Number = $number; Title = $issue.title; Url = $issue.url; Reasons = ($reasons -join '; ') }
        }
    }

    # ---------- Pull request ----------
    foreach ($pull in $pulls) {
        $reasons = @()
        if ($pull.title -notmatch $CommitTitlePattern) { $reasons += 'titolo non nel formato commit' }
        if ($pull.title.Length -gt 72) { $reasons += 'titolo oltre 72 caratteri' }
        if ($pull.headRefName -notmatch $AnyBranchPattern) { $reasons += "branch ``$($pull.headRefName)`` fuori standard" }
        $body = [string] $pull.body
        foreach ($section in @('Modifiche', 'Test eseguiti', 'Breaking changes', 'Note')) {
            if ($body -notmatch "(?m)^##\s+$section") { $reasons += "sezione $section mancante" }
        }
        if ($body -notmatch '(?im)^\s*(Closes|Refs):?\s+#\d+') { $reasons += 'footer Closes o Refs mancante' }
        if ($body -match '(?m)^\s*- \[[ x]\]') { $reasons += 'checkbox nel corpo' }
        if ($body -match '(?m)^###\s') { $reasons += 'intestazioni ### nel corpo' }
        if (-not $pull.milestone -and $repository -ne '.github') { $reasons += 'milestone mancante' }
        if ($FixText) {
            $repair = Repair-Body -Text $body -AllowCheckboxes $false -IsPullRequest $true
            if ($repair.Text -ne $body) { $TextFixes += [pscustomobject]@{ Repository = $repository; Kind = 'pull request'; Number = [int] $pull.number; Url = $pull.url; Applied = ($repair.Applied -join '; '); Text = $repair.Text } }
        }
        if ($reasons.Count -gt 0) {
            $Findings += [pscustomobject]@{ Repository = $repository; Kind = 'pull request'; Number = [int] $pull.number; Title = $pull.title; Url = $pull.url; Reasons = ($reasons -join '; ') }
        }

        # Stato della pull request nei project: aperta → In Review, mergiata o chiusa → Done
        $pullStatus = if ($pull.state -eq 'OPEN') { 'In Review' } else { 'Done' }
        foreach ($project in $Projects.Values) {
            $item = $project.Items | Where-Object { $_.content.type -eq 'PullRequest' -and $_.content.number -eq [int] $pull.number -and ($_.repository -eq $repositoryUrl -or "https://github.com/$($_.content.repository)" -eq $repositoryUrl) } | Select-Object -First 1
            if (-not $item) { continue }
            if ([string] $item.status -ne $pullStatus) {
                $Changes += [pscustomobject]@{ Repository = $repository; Number = [int] $pull.number; Project = $project.Title; Field = 'Status (pull request)'; From = [string] $item.status; To = $pullStatus; ItemId = $item.id; ProjectId = $project.Id; FieldId = $project.StatusFieldId; OptionId = $project.StatusOptions[$pullStatus]; Text = $null; IssueNodeId = $null }
            }
        }
    }
}

# ---------- Applicazione ----------
if ($Apply -and $Changes.Count -gt 0) {
    Write-Host "Applicazione di $($Changes.Count) modifiche ai project…"
    $written = 0
    foreach ($change in $Changes) {
        # GitHub limita le scritture ravvicinate (limite secondario): una pausa fra una e l'altra e un nuovo tentativo dopo un minuto.
        Start-Sleep -Milliseconds 800
        if ($change.Field -like 'Status*') {
            if (-not $change.OptionId) { Write-Warning "Project $($change.Project): opzione «$($change.To)» assente, salto #$($change.Number)"; continue }
            $arguments = @('project', 'item-edit', '--project-id', $change.ProjectId, '--id', $change.ItemId, '--field-id', $change.FieldId, '--single-select-option-id', $change.OptionId)
            try { [void] (Invoke-Gh $arguments) }
            catch {
                if ("$_" -match 'rate limit') { Write-Host 'Limite API raggiunto: attendo 90 secondi…'; Start-Sleep -Seconds 90; [void] (Invoke-Gh $arguments) }
                else { Write-Warning "Status non scritto su #$($change.Number) ($($change.Project)): $_"; continue }
            }
            $written++
            if ($written % 50 -eq 0) { Write-Host "  $written modifiche scritte…" }
        }
        else {
            $escaped = $change.Text -replace '"', '\"'
            $mutation = "mutation { setIssueFieldValue(input: { issueId: `"$($change.IssueNodeId)`", issueFields: [ { fieldId: `"$($change.FieldId)`", textValue: `"$escaped`" } ] }) { issue { number } } }"
            try { [void] (Invoke-Gh @('api', 'graphql', '-f', "query=$mutation")) }
            catch { Write-Warning "Released In non scritto su #$($change.Number) ($($change.Repository)): $_" }
        }
    }
}

if ($Apply -and $FixText -and $TextFixes.Count -gt 0) {
    Write-Host "Correzione del testo di $($TextFixes.Count) elementi…"
    $bodyFile = Join-Path ([System.IO.Path]::GetTempPath()) 'warden-body.md'
    foreach ($fix in $TextFixes) {
        Start-Sleep -Milliseconds 800
        [System.IO.File]::WriteAllText($bodyFile, $fix.Text, [System.Text.UTF8Encoding]::new($false))
        $command = if ($fix.Kind -eq 'issue') { 'issue' } else { 'pr' }
        $arguments = @($command, 'edit', "$($fix.Number)", '--repo', "$Organization/$($fix.Repository)", '--body-file', $bodyFile)
        try { [void] (Invoke-Gh $arguments) }
        catch {
            if ("$_" -match 'rate limit') { Write-Host 'Limite API raggiunto: attendo 90 secondi…'; Start-Sleep -Seconds 90; [void] (Invoke-Gh $arguments) }
            else { Write-Warning "Testo non scritto su $($fix.Kind) #$($fix.Number) ($($fix.Repository)): $_" }
        }
    }
    Remove-Item $bodyFile -ErrorAction SilentlyContinue
}

# ---------- Report ----------
if ($FixText) {
    [void] $Report.AppendLine('## Correzioni di testo ' + $(if ($Apply) { 'applicate' } else { 'da applicare' }))
    [void] $Report.AppendLine()
    if ($TextFixes.Count -eq 0) { [void] $Report.AppendLine('Nessuna.') }
    else {
        [void] $Report.AppendLine('| Repository | Elemento | Correzioni |')
        [void] $Report.AppendLine('|---|---|---|')
        foreach ($fix in $TextFixes | Sort-Object Repository, Kind, Number) { [void] $Report.AppendLine("| $($fix.Repository) | $($fix.Kind) [#$($fix.Number)]($($fix.Url)) | $($fix.Applied) |") }
    }
    [void] $Report.AppendLine()
}
[void] $Report.AppendLine('## Stato e ambienti: modifiche ' + $(if ($Apply) { 'applicate' } else { 'da applicare' }))
[void] $Report.AppendLine()
if ($Changes.Count -eq 0) { [void] $Report.AppendLine('Nessuna: i project sono allineati ai fatti.') }
else {
    [void] $Report.AppendLine('| Repository | Issue | Project | Campo | Da | A |')
    [void] $Report.AppendLine('|---|---|---|---|---|---|')
    foreach ($change in $Changes | Sort-Object Repository, Number, Field) {
        [void] $Report.AppendLine("| $($change.Repository) | #$($change.Number) | $($change.Project) | $($change.Field) | $(if ($change.From) { $change.From } else { '—' }) | $(if ($change.To) { $change.To } else { '—' }) |")
    }
}
[void] $Report.AppendLine()
[void] $Report.AppendLine('## Non conformità')
[void] $Report.AppendLine()
$grouped = $Findings | Group-Object Repository
foreach ($group in $grouped) {
    [void] $Report.AppendLine("### $Organization/$($group.Name): $($group.Count) elementi")
    [void] $Report.AppendLine()
    [void] $Report.AppendLine('| Elemento | Titolo | Difetti |')
    [void] $Report.AppendLine('|---|---|---|')
    foreach ($finding in $group.Group | Sort-Object Kind, Number) {
        $label = if ($finding.Kind -eq 'issue') { "issue [#$($finding.Number)]($($finding.Url))" } else { "pull request [#$($finding.Number)]($($finding.Url))" }
        $title = $finding.Title -replace '\|', '\|'
        [void] $Report.AppendLine("| $label | $title | $($finding.Reasons) |")
    }
    [void] $Report.AppendLine()
}
[void] $Report.AppendLine('## Difetti per tipo')
[void] $Report.AppendLine()
[void] $Report.AppendLine('| Difetto | Elementi |')
[void] $Report.AppendLine('|---|---|')
$byReason = @{}
foreach ($finding in $Findings) {
    foreach ($reason in ($finding.Reasons -split '; ')) {
        $key = $reason -replace '`[^`]*` ', ''
        $byReason[$key] = 1 + [int] $byReason[$key]
    }
}
foreach ($entry in $byReason.GetEnumerator() | Sort-Object Value -Descending) { [void] $Report.AppendLine("| $($entry.Key) | $($entry.Value) |") }

New-Item -ItemType Directory -Path $ReportsDirectory -Force | Out-Null
$reportPath = Join-Path $ReportsDirectory ("warden-" + $Now.ToString('yyyyMMdd-HHmm') + '.md')
$Report.ToString() | Set-Content -Path $reportPath -Encoding utf8
Write-Host "Report: $reportPath"
Write-Host "Modifiche $(if ($Apply) { 'applicate' } else { 'da applicare' }): $($Changes.Count). Elementi non conformi: $($Findings.Count)."
