---
description: "Use when: creating, drafting, editing or reviewing a GitHub issue, choosing its Issue Type, fields, project or milestone, writing its title, body or Riferimenti section, linking sub-issues, writing a comment on an issue, in any repository of the Lutech-Siad organization."
---

# Convenzioni issue — Lutech-Siad

| | |
|---|---|
| **Creato** | 11/11/2026 |
| **Aggiornato** | 12/11/2026 |
| **Revisione** | 2 |

Regole per tipo, campi, project, milestone, titolo, corpo, relazioni e commenti delle issue. La procedura (inferenza, domande, bozza, creazione) è nel custom agent `issues`. Milestone: [`git.instructions.md §6`](git.instructions.md). Glossario, lingua, label e persone: [`docs/conventions.md`](../../docs/conventions.md).

## 1. Issue Type

Uno per issue, sempre, a livello di organizzazione. Il tipo sceglie il template e le sezioni del corpo (vedi §5).

| Tipo | Quando | Template |
|---|---|---|
| `Bug` | difetto in qualcosa **non ancora in produzione**: trovato sviluppando o collaudando un lavoro nuovo | `bug.yml` |
| `Problem` | malfunzionamento **già in produzione**, non urgente; può emergere anche collaudando altro | `problem.yml` |
| `Hotfix` | malfunzionamento **in produzione, urgente**: si corregge su `main` | `hotfix.yml` |
| `Feature` | nuova funzionalità | `feature.yml` |
| `CR` | modifica richiesta da SIAD con il **documento di CR**, che ha completato l'iter approvativo SIAD | `cr.yml` |
| `RFC` | proposta di modifica **senza documento di CR** e senza iter approvativo: si discute e si decide; se accettata, il lavoro prosegue | `rfc.yml` |
| `Refactoring` | riscrittura senza cambi funzionali | `refactoring.yml` |
| `Migration` | cambio di versione o di tecnologia | `migration.yml` |
| `Task` | attività operativa (configurazione, documentazione, infrastruttura, rilascio) e tutto ciò che non rientra negli altri tipi | `task.yml`; per il rilascio `release.yml` |

## 2. Campi

Campi di organizzazione (Issue Fields), da impostare su ogni issue.

| Campo | Valori | Obbligatorio |
|---|---|---|
| `Priority` | `Urgent`, `High`, `Medium`, `Low` | sempre |
| `Effort` | `XS`, `S`, `M`, `L`, `XL` (vedi sotto) | sempre |
| `Activity` | `development`, `docs`, `infrastructure`, `configuration` | sempre |
| `Component` | `frontend`, `backend`, `jobs`, `translations`, `multi-projects` | sempre |
| `External References` | URL del riferimento esterno principale (Issue Tracker o JIRA, vedi §6) | per Bug, Problem, Hotfix, Feature, RFC, CR |
| `Start date` | data ISO `AAAA-MM-GG`; se non indicata, la data odierna | sempre |
| `Target date` | data ISO `AAAA-MM-GG`; se non indicata, si propone dall'Effort (vedi sotto) | no |
| `Estimate Hours` | ore stimate; se non indicate, si propongono dall'Effort (vedi sotto) | no |

### Effort, Target date ed Estimate Hours

| Effort | Significato | Estimate Hours proposte | Target date proposta |
|---|---|---|---|
| `XS` | meno di 2 ore: modifica banale o documentazione | 2 | Start date |
| `S` | mezza giornata: piccola correzione o aggiunta minore | 4 | Start date |
| `M` | 1–2 giorni: funzionalità semplice o refactoring limitato | 16 | Start date + 2 giorni lavorativi |
| `L` | 3–5 giorni: funzionalità complessa o migrazione parziale | 40 | Start date + 5 giorni lavorativi |
| `XL` | più di una settimana: lavoro architetturale o milestone intera | si chiede | si chiede |

I giorni lavorativi escludono sabati, domeniche e festività nazionali italiane (1 gennaio, 6 gennaio, lunedì dell'Angelo, 25 aprile, 1 maggio, 2 giugno, 15 agosto, 1 novembre, 8 dicembre, 25 e 26 dicembre). Se Target date o Estimate Hours arrivano con la richiesta, si verifica che siano coerenti con l'Effort (ore dentro la fascia, data non prima di quella calcolata); se non lo sono, si segnala e si chiede quale dei due correggere.

`Component` è il repository della issue (`nexusq-backend` → `backend`); `multi-projects` quando la issue riguarda più repository, anche solo backend e frontend.

Assegnatario: chi crea la issue, salvo indicazione diversa. Label: nessuna, salvo quelle di [`docs/conventions.md §6`](../../docs/conventions.md).

## 3. Project

| Lavoro | Project |
|---|---|
| Produzione: correzioni (Problem, Hotfix) e piccole feature o CR non progettuali, rendicontate sulla commessa di manutenzione | `NexusQ - AM` |
| Repository `.github`, governance, configurazione dell'organizzazione | `SIAD - Governance` |
| Sviluppo progettuale | il project di sviluppo attivo (oggi `NexusQ - Migration & Security` e `NexusQ - CRM`); se ne esistono più di uno, si chiede quale |

I project `[TEMPLATE] …` non ricevono issue. Issue e sub-issue di uno stesso lavoro stanno nello stesso project. Il repository `.github` ospita solo issue di governance dell'organizzazione: mai issue di progetto o di prodotto.

## 4. Titolo

Formato: `<Contesto>: <Titolo>`, con Contesto facoltativo

| Regola | Dettaglio |
|---|---|
| Bug, Problem, Hotfix | il **sintomo**, come lo vede chi lo incontra: `Errore 500 al salvataggio di un'offerta con righe gas miste` |
| Tutti gli altri tipi | **verbo all'infinito + oggetto**: `Aggiungere il filtro per stato nella lista offerte`; la issue di release si intitola sempre `Rilasciare la versione v<major>.<minor>.<patch>` |
| Contesto | facoltativo, un'area dell'applicazione da un elenco chiuso (in via di definizione), seguito da `: ` |
| Forma | Sentence case, senza punto finale, al massimo 80 caratteri |
| Vietato | prefissi `[BE]`, `[FE]`, sigle, formato conventional commit |

## 5. Corpo

Il corpo segue il template del tipo (`.github/ISSUE_TEMPLATE/<tipo>.yml` del repository `.github`): stesse sezioni, stesso ordine, intestazioni `##` con l'etichetta del template. Le issue create dal browser nascono con `###` e vengono riportate a `##` da Warden, il controllore di stile.

Sezioni comuni a tutti i tipi:

| Sezione | Contenuto |
|---|---|
| `## Obiettivo` | perché esiste la issue: il problema o il bisogno, non la soluzione |
| `## Scope` | elenco puntato di cosa va fatto; passi di verifica compresi, ma non lavoro che richiede un proprio branch (quello è una sub-issue, vedi §7) |
| `## Riferimenti` | vedi §6 |
| `## Note` | vincoli, dipendenze, stato; `Non applicabile` se vuota |

Sezioni specifiche, fra Obiettivo e Scope o fra Scope e Riferimenti nell'ordine del template:

| Tipi | Sezioni specifiche |
|---|---|
| Bug, Problem | `## Passi per riprodurre`, `## Comportamento atteso e attuale`, `## Ambiente`, `## Impatto` |
| Hotfix | `## Passi per riprodurre`, `## Comportamento atteso e attuale`, `## Impatto` (l'ambiente è sempre la produzione) |
| Feature, RFC, CR | `## Impatto su funzionalità esistenti`, `## Criteri di accettazione`, `## Opzioni considerate`, `## Decisione proposta` |
| Migration | `## Versione attuale`, `## Versione target`, `## Impatto su funzionalità esistenti`, `## Piano di rollback` |
| Refactoring | `## Codice impattato`, `## Rischio di regressione`, `## Impatto su funzionalità esistenti` |
| Task (release) | `## Versione target`, `## Issue incluse` |

Lingua italiana, niente abbreviazioni, frecce con `→`. Le sezioni facoltative del template, se vuote, riportano `Non applicabile`.

## 6. Riferimenti

Elenco puntato, sempre presente, in quest'ordine, ogni voce con il link; `Non applicabile` solo se non esiste nessun riferimento.

| Voce | Formato | Quando |
|---|---|---|
| Issue Tracker | `- Issue Tracker: [#71307](https://track-disc.lutech.it/issues/71307)` | segnalazione nell'Issue Tracker Lutech |
| JIRA | `- JIRA: [NX-123](https://siadjiraprod.atlassian.net/browse/NX-123)` | ticket JIRA SIAD |
| Issue | `- Issue: #42 — motivo del collegamento` oppure `- Issue: Lutech-Siad/nexusq-frontend#184 — controparte frontend` | issue collegate che **non** sono genitore né figlie (quelle sono sub-issue, vedi §7) |
| File | `- File: [nome](percorso nel repository)` | documento o file del repository, per esempio il documento di CR |
| Fonte | `- Fonte: [titolo](url)` | documento esterno |

Mai una riga `Parent:`: la relazione con la issue genitore è la sub-issue nativa di GitHub.

## 7. Sub-issue e gerarchia

- Una **sub-issue** è lavoro che richiede un proprio branch e una propria pull request. Un passo che non li richiede è una voce dello Scope.
- Ogni issue appartiene a **un solo repository** e la sua gerarchia resta in quel repository. GitHub permette sub-issue fra repository della stessa organizzazione; noi non le usiamo. Un lavoro che tocca backend e frontend ha una issue per repository, ciascuna nel proprio albero; le due si citano nei Riferimenti (`Issue: …#n — controparte …`).
- Per un progetto grande: in ogni repository una issue radice, sotto le issue di area, sotto le sub-issue del lavoro. Non esiste una issue radice unica sopra i repository: il contenitore trasversale del progetto è il GitHub Project.
- La **issue di release** non ha sub-issue: elenca le issue incluse in `## Issue incluse`, perché quel lavoro ha già la sua issue.

## 8. Commenti e chiusura

Nessun commento automatico: branch e pull request compaiono da soli nel riquadro Development della issue. I commenti li scrivono le persone, quando serve, in questa forma: prima riga con l'etichetta in grassetto, poi il testo; un argomento per commento; issue e pull request citate con `#<n>`.

| Etichetta | Quando |
|---|---|
| `**Decisione:**` | scelta presa che cambia scope, soluzione o priorità, con il motivo |
| `**Domanda:**` | chiarimento richiesto a qualcuno, citato con `@username` |
| `**Stato:**` | avanzamento o esito di un collaudo, quando non è già visibile da branch e pull request |
| `**Blocco:**` | cosa impedisce di procedere e da chi o cosa dipende |
| `**Chiusura:**` | motivo della chiusura, obbligatorio se `not planned` |

Una issue si chiude solo con il lavoro finito (`completed`, di norma al merge su `main` tramite `Closes:`) o con una decisione esplicita (`not planned`, con label `wontfix`, `duplicate` o `invalid` e un commento `**Chiusura:**`).
