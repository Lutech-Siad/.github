---
description: "Use when: opening, drafting, reviewing or updating a pull request, writing its title or body, choosing the issue footer (Closes or Refs), choosing the reviewer, assignee, milestone or project of a pull request, in any repository of the Lutech-Siad organization."
---

# Convenzioni pull request — Lutech-Siad

| | |
|---|---|
| **Creato** | 11/11/2026 |
| **Aggiornato** | 12/11/2026 |
| **Revisione** | 2 |

Regole per titolo, corpo, footer, reviewer e metadati delle pull request. La procedura (bozza, conferma, creazione) è nel custom agent `gitflow`. Branch di partenza e di destinazione, metodo di merge, versioni e milestone: [`git.instructions.md`](git.instructions.md). Glossario, lingua e persone: [`docs/conventions.md`](../../docs/conventions.md).

## 1. Titolo

Stesso formato del titolo di un commit ([`git.instructions.md §3`](git.instructions.md)): `<type>(<scope>): <descrizione>`, imperativo, senza punto finale, al massimo 72 caratteri. Diventa il titolo del commit di squash su `main`.

| Pull request | Titolo |
|---|---|
| `feature`, `fix`, `hotfix` | `<type>(<scope>): <descrizione>` |
| `release` | `release: v<major>.<minor>.<patch>` |
| `backmerge` | `chore(repo): riallinea develop con main dopo la release v<major>.<minor>.<patch>` |

## 2. Corpo

Il corpo segue il template [`pull_request_template.md`](../pull_request_template.md), che GitHub precompila dal browser e il custom agent `gitflow` legge a runtime. Regole:

- Tutte le sezioni sono **sempre presenti**, nello stesso ordine, con intestazione `##`. Una sezione senza contenuto riporta `Non applicabile`, non si cancella.
- Lingua italiana, niente abbreviazioni; frecce con `→`.
- Le issue si citano con `#<n>`; i commit con il loro titolo.

| Sezione | Contenuto |
|---|---|
| `## Modifiche` | elenco puntato di cosa è stato fatto, una voce per modifica significativa. Nella release: una voce per issue inclusa, nella forma `<titolo della issue> (#<n>)`. Nel backmerge: `Riallinea develop con main dopo la release v<versione> (pull request #<numero>)`. |
| `## Test eseguiti` | elenco puntato dei test eseguiti e del loro esito (unitari, integrazione, manuali); se nessuno, `Non applicabile`. |
| `## Breaking changes` | modifiche che rompono la retrocompatibilità, coerenti con i footer `BREAKING CHANGE` dei commit; altrimenti `Non applicabile`. |
| `## Note` | informazioni operative: dipendenze da altre pull request, ordine di rilascio, script da eseguire; altrimenti `Non applicabile`. |

## 3. Footer

Il footer chiude il corpo, sempre presente: una riga per issue, di norma una sola. Mai più issue sulla stessa riga: GitHub riconosce la parola chiave solo se ripetuta per ogni issue.

| Footer | Quando |
|---|---|
| `Closes: #<n>` | la pull request completa la issue. Nella release: un `Closes:` per la issue di release e uno per ogni issue inclusa. |
| `Refs: #<n>` | la pull request contribuisce alla issue senza completarla. Nel backmerge: `Refs:` alla issue di release o dell'hotfix. |

GitHub chiude le issue di un `Closes:` solo al merge sul branch predefinito (`main`): una pull request verso `develop` con `Closes:` collega la issue nel riquadro Development ma la lascia aperta fino al merge della release. Per questo `Closes:` è corretto anche verso `develop`.

Nessun'altra riga nel footer: niente firme né «Generated with». Per i co-autori vale [`git.instructions.md §3`](git.instructions.md).

## 4. Metadati

| Metadato | Regola |
|---|---|
| Assegnatario | chi apre la pull request |
| Reviewer | solo per le pull request verso i branch protetti (`main`, `develop`): `jenny11lutech` in tutti i repository; se la apre Jennifer, `fabioped76` per `nexusq-backend` e `jonathanvillafana` per `nexusq-frontend` e gli altri repository. Verso altri branch (per esempio una sub-issue verso il branch della issue genitore) nessun reviewer, salvo richiesta di chi apre la pull request. Si imposta con `--reviewer`, non si scrive nel corpo. |
| Milestone | la stessa della issue collegata |
| Project | lo stesso della issue collegata |
| Label | nessuna, salvo quelle di [`docs/conventions.md §6`](../../docs/conventions.md) |

Una pull request senza issue collegata non si apre: prima la issue (custom agent `issues`), poi il branch, poi la pull request.
