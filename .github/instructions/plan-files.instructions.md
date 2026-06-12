---
description: "Use when creating, reading, or referencing plan/prompt files (.prompt.md) in any repository. Covers naming convention, location, and content structure for development plan files."
applyTo: "**/.github/prompts/**"
---

# Convenzione file di piano (prompt)

## Percorso e sottocartelle

I file di piano vanno nella cartella `.github/prompts/` del repository a cui si riferiscono, organizzati in sottocartelle per stato:

| Sottocartella | Quando usarla |
|---|---|
| `active/` | Plan in corso di esecuzione |
| `done/` | Plan completati |
| `superseded/` | Plan sostituiti da versioni successive |

Esempio: `.github/prompts/active/plan-20260612-0951-printexclude-regression.prompt.md`

## Naming

Formato: `plan-AAAAMMGG-hhmm-<descrizione>.prompt.md`

- `AAAAMMGG-hhmm`: data e ora di creazione (ora locale della macchina)
- `<descrizione>`: slug in kebab-case che descrive il contenuto

Esempi:
- `plan-20260508-1439-save-offer-db-transaction.prompt.md`
- `plan-20260612-0951-printexclude-regression.prompt.md`

Per ottenere data e ora correnti:
```powershell
Get-Date -Format "yyyyMMdd-HHmm"
```

## Contenuto

- **Prima riga**: `**Data:** GG/MM/AAAA` (data di creazione o ultima modifica)
- Quando il file viene modificato in giorni successivi alla creazione, aggiornare la data (ricavata da: ``Get-Date -Format "dd/MM/yyyy"``)

## Struttura

La struttura dipende dal tipo di plan:

### Plan esecutivo (standard)

```markdown
**Data:** GG/MM/AAAA

# Piano: <titolo>

**Classe/File:** `<percorso>`
**Metodo/Scope:** `<nome>`

---

## 1. Analisi

<tabelle o elenchi con analisi del codice coinvolto>

## 2. Strategia

<approccio scelto con motivazione>

## 3. File da modificare

| File | Modifiche |
|------|-----------|
| ``path/to/File.cs`` | Descrizione modifiche |

## 4. Rischi e mitigazioni

| Rischio | Mitigazione |
|---------|-------------|

## 5. Acceptance criteria

- [ ] <condizione verificabile>
```

### Macro-plan (piano di coordinamento multi-step)

```markdown
**Data:** GG/MM/AAAA

# Macro-Plan: <titolo>

| | |
|---|---|
| **Data** | GG/MM/AAAA |
| **Area** | <area tecnica> |
| **Dipende da** | ``<altri plan>`` |

> Questo e un macro-plan. Definisce strategia e ordine; per ogni step verra creato un sub-plan dedicato.

## Contesto

## Pattern di lavoro

## Piano di esecuzione

| # | Plan | Classe | Metodi | Test |
|---|------|--------|--------|------|

## Riferimenti
```
