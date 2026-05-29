---
description: "Use when making git commits, composing commit messages, staging files, reviewing changes, or checking git status in any repository of the Lutech-Siad organization. Covers Conventional Commits format, allowed types and scopes, git user configuration, and commit size guidelines."
applyTo: "**"
---

# Convenzione commit — Lutech-Siad

## Git user

Ogni sviluppatore configura il proprio utente localmente (senza `--global`, così vale solo per il repo corrente):

```bash
git config user.name "<tuo-username-github>"
git config user.email "<tua-email@lutech.it>"
```

## Formato

```
<type>(<scope>): <description>

[body opzionale]

[footer obbligatorio se esiste una issue]
```

## Tipi consentiti

| Tipo | Quando usarlo |
|------|---------------|
| `feat` | Nuova funzionalità |
| `fix` | Correzione bug |
| `refactor` | Riscrittura senza cambi funzionali |
| `perf` | Miglioramento performance |
| `test` | Aggiunta o modifica test |
| `docs` | Solo documentazione |
| `build` | Build system, dipendenze (npm, NuGet) |
| `ci` | GitHub Actions e pipeline |
| `chore` | Configurazione, naming, operazioni di manutenzione |

## Scope consigliati

Scope comuni a tutti i repo:

`repo` · `security` · `deps` · `docs` · `ci` · `config`

Scope specifici per repo frontend (Angular):

`migrazione` · `components` · `services` · `routing` · `state` · `ui`

Scope specifici per repo backend (.NET):

`migrazione` · `api` · `auth` · `dal` · `jobs` · `models` · `security`

## Body

Il body è opzionale. Aggiungilo quando il titolo da solo non basta a capire il contesto.

### Commit atomici (lavoro ordinario)

**Convenzioni:**

- Separare sempre il body dal titolo con **una riga vuota**
- Lunghezza massima per riga: **72 caratteri** (limite standard git per leggibilità in terminale e diff)
- Spiegare il **perché** della modifica, non il cosa (il cosa è già nel titolo)
- Usare l'infinito o il presente: "aggiunge", "corregge", "rimuove" — non "aggiunto", "corretto"
- Più paragrafi separati da una riga vuota sono ok

**Quando aggiungere il body:**
- La modifica ha un motivo non ovvio (es. workaround per un bug di libreria)
- Ci sono effetti collaterali o limitazioni da segnalare
- La modifica tocca più moduli e vale la pena elencarli
- Decisione tecnica che potrebbe essere rivalutata in futuro

**Quando NON serve:**
- La modifica è autoesplicativa dal titolo
- Si tratta di `chore`, `docs` o piccoli `fix` banali

**Esempio:**

```
fix(api): gestisci risposta null in customer service

Il backend può restituire null invece di un array vuoto
quando il cliente non ha impianti associati.
Aggiunta guardia esplicita per evitare errori runtime.
```

### Merge commit / squash commit (chiusura PR)

Quando si chiude una PR con merge commit o squash, il body riassume l'intera feature o fix.

**Regole diverse:**

- **Nessun limite di 72 caratteri per riga** — GitHub renderizza il testo automaticamente
- Il body può essere più lungo e descrittivo
- Elencare i commit principali inclusi, le decisioni prese, i rischi noti
- Utile per chi fa la code review o consulta lo storico dopo mesi

**Esempio:**

```
feat(components): aggiungi filtro avanzato nella lista offerte

Introduce un pannello di filtro con selezione multipla per stato,
tipologia offerta e intervallo di date. Il componente è standalone
e riutilizzabile anche nella lista richieste.

Modifiche principali:
- FilterPanelComponent con form reattivo
- OfferListComponent aggiornato per ricevere i filtri via @Input
- OfferService aggiornato per passare i parametri all'endpoint

Refs: #8
```

## Footer — riferimento issue

Quando esiste una issue GitHub correlata, aggiungere nel footer:

- `Refs: #<numero>` — riferimento alla issue collegata (regola generale per i commit)

- `Closes: #<numero>` si usa **solo nelle PR**, mai nei commit. La chiusura automatica della issue avviene tramite il footer della PR al merge su `main`.

**Eccezione repo `.github` (org-level)**: il repo `Lutech-Siad/.github` non ha branch `develop` e non usa PR. Se un commit completa interamente una issue, si può usare `Closes: #<numero>` direttamente nel commit footer.

Il primo commit di baseline (`chore(repo)`) non richiede riferimento a issue.

## Regole

- Il titolo è sempre obbligatorio; body e footer solo quando aggiungono informazioni utili
- Commit piccoli e con uno scopo unico — se una modifica include aggiornamenti non correlati, dividerla in più commit
- Lingua: **italiano** per la descrizione, **inglese** per tipo e scope
- Non usare il punto finale nel titolo

## Azioni di workflow GitFlow

Quando l'utente chiede di lavorare su una feature, fix o refactor, applicare questa logica prima di iniziare qualsiasi operazione git.

### Decisione branch

Controllare sempre su quale branch si è prima di committare:

```bash
git branch --show-current
```

| Situazione | Azione |
|---|---|
| Su `main` o `develop`, lavoro in corso | Avvisare, proporre `git checkout -b feature/<n>_<nome-kebab>` |
| Su `feature/*` | Procedere normalmente |
| Su `release/*` o `hotfix/*` | Procedere normalmente |
| Primo commit del repo (baseline) | Eccezione: committare su `main` è corretto |

### Naming branch

Formato: `<tipo>/<n>_<slug>`

- `<n>` = numero della issue GitHub collegata
- `<slug>` = titolo breve in kebab-case minuscolo (solo lettere e trattini)
- Separatore tra numero e slug: underscore `_`

Esempi: `feature/42_angular-migration`, `hotfix/7_csp-header-missing`, `release/1_v1-0-0`

Ogni branch `feature/*`, `release/*`, `hotfix/*` deve avere una issue collegata. Se non esiste, crearla prima di staccare il branch.
