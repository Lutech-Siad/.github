---
description: "Use when creating, reading, or referencing plan/prompt files (.prompt.md) in any repository. Covers naming convention, location, and content structure for development plan files."
applyTo: "**/.github/prompts/**"
---

# Convenzione file di piano (prompt)

## Percorso

Tutti i file di piano vanno nella cartella `.github/prompts/` del repository a cui si riferiscono.

## Naming

Formato: `plan-AAAAMMGG-hhmm-<descrizione>.prompt.md`

- `AAAAMMGG-hhmm`: data e ora di creazione (ora locale della macchina)
- `<descrizione>`: slug in camelCase che descrive il contenuto

Esempi:
- `plan-20260424-1530-duplicateDraftDbTransaction.prompt.md`
- `plan-20260611-0945-angularMigrationStep1.prompt.md`

Per ottenere data e ora correnti:
```powershell
Get-Date -Format "yyyyMMdd-HHmm"
```

## Contenuto

- **Prima riga**: `**Data:** GG/MM/AAAA` (data di creazione o ultima modifica)
- Quando il file viene modificato in giorni successivi alla creazione, aggiornare la data (ricavata da: `Get-Date -Format "dd/MM/yyyy"`)

## Struttura consigliata

```markdown
**Data:** GG/MM/AAAA

## Contesto

<perché questo plan esiste, issue di riferimento>

## Obiettivo

<cosa deve essere realizzato>

## File coinvolti

<lista file da modificare/creare>

## Piano di implementazione

<step dettagliati>

## Acceptance criteria

<condizioni per considerare il lavoro completato>
```
