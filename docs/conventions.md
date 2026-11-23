# Convenzioni — Lutech-Siad

| | |
|---|---|
| **Creato** | 29/05/2026 |
| **Aggiornato** | 12/11/2026 |
| **Revisione** | 6 |

> Indice delle convenzioni dell'organizzazione `Lutech-Siad` e convenzioni non legate a un compito specifico.
> Ogni regola vive in un solo file: qui trovi dove. Gli altri file rimandano, non copiano.

---

## Dove vive ogni regola

| Argomento | File |
|---|---|
| Utente git, branch, commit, versioni e tag, release e backmerge, milestone | [`.github/instructions/git.instructions.md`](../.github/instructions/git.instructions.md) |
| Issue: tipi, campi, project, titolo, corpo, Riferimenti, sub-issue, commenti e chiusura | [`.github/instructions/issues.instructions.md`](../.github/instructions/issues.instructions.md) |
| Pull request: titolo, corpo, reviewer, footer | [`.github/instructions/pull-requests.instructions.md`](../.github/instructions/pull-requests.instructions.md) |
| File di piano | [`.github/instructions/plan-files.instructions.md`](../.github/instructions/plan-files.instructions.md) |
| Procedure guidate (proposta, conferma, esecuzione) | custom agent in [`.github/agents/`](../.github/agents/): `gitflow`, `issues`, `backlog`, `planning` |
| Tutto il resto (glossario, lingua, persone, repository e loro custom properties, label, ambienti, struttura di `.github/`, passaggio fra custom agent) | questo documento |

---

## 1. Glossario

Termini di GitHub Copilot in VS Code. Si usano sempre questi, in inglese e invariati anche nei testi in italiano; niente sinonimi («agente», «orchestratore», «sotto-agente», «modalità», «delega»).

| Termine | Definizione |
|---|---|
| **agent** | Chi esegue una richiesta in chat in autonomia, con gli strumenti che ha. È quello che si sceglie nel menu degli agent. Ne esistono di **built-in** (`Agent`, `Plan`) e di **custom**. |
| **custom agent** | Un agent definito da noi in un file `.agent.md` (frontmatter e istruzioni). È l'unica cosa che scriviamo: ogni file in `.github/agents/` è un custom agent. Usato in conversazione: propone, anche con una bozza, e chiede conferma prima di eseguire. |
| **subagent** | Non un file ma un **modo di esecuzione**: un agent, built-in o custom, avviato da un altro agent tramite lo strumento `agent`. Gira in un contesto proprio e restituisce un risultato all'agent che lo ha chiamato. È il modo in cui i nostri custom agent si passano il lavoro (§9). |
| **handoff** | Pulsante a fine risposta che passava la conversazione a un altro agent. Esisteva solo nell'harness Local di VS Code, deprecato: non si usa (§9). |
| **instructions** | File `.instructions.md` con regole, senza procedura. Copilot lo carica sempre (`applyTo: "**"`), per file (`applyTo` con pattern) o a richiesta (in base alla `description`). |

In Claude Code i nomi cambiano: il custom agent usato in conversazione corrisponde alla **skill**, il subagent al **subagent**, anche per il passaggio fra agent di §9. Il dettaglio è nel piano del plugin Claude Code.

---

## 2. Lingua

| Cosa | Lingua |
|---|---|
| Testi: titoli e corpo di issue e pull request, descrizione dei commit, piani, documentazione, istruzioni degli agent | italiano |
| Identificatori: nomi di file, branch, scope dei commit, nomi di agent, label, valori dei campi, nomi di repository | inglese |

Niente abbreviazioni, in nessuna lingua: «Non applicabile», non «N/A»; «Issue Tracker», non «Track».

---

## 3. Persone

| Persona | Username GitHub | Ruolo |
|---|---|---|
| Jennifer Bottarelli | `jenny11lutech` | Owner, full stack, pianificazione |
| Fabio Pedretti | `fabioped76` | Project manager tecnico, backend |
| Jonathan Anatoly Vasquez Villafana | `jonathanvillafana` | Write, full stack (soprattutto frontend) |

L'utente corrente si rileva a runtime con `gh api user --jq .login`. Chi fa la review delle pull request è definito in [`pull-requests.instructions.md`](../.github/instructions/pull-requests.instructions.md).

---

## 4. Repository

| Regola | Dettaglio |
|---|---|
| Pattern | `nexusq-<componente>` |
| Case | minuscolo |
| Separatore | trattino `-` |
| Remote | `https://github.com/Lutech-Siad/<repository>.git` |

| Repository | Contenuto | Branch | Rilascio |
|---|---|---|---|
| `.github` | Agent, instructions, template e documenti dell'organizzazione | solo `main` | nessuno |
| `nexusq-backend` | API .NET | `main`, `develop` | tag e GitHub Release |
| `nexusq-frontend` | Applicazione Angular | `main`, `develop` | tag e GitHub Release |
| `nexusq-infrastructure` | Infrastruttura e configurazione | da definire | da definire |
| `nexusq-translations` | Traduzioni | da definire | da definire |

Il repository corrente è indicato nel `copilot-instructions.md` del repository attivo.

---

## 5. Repository custom properties

| Regola | Dettaglio |
|---|---|
| Case nomi | kebab-case minuscolo |
| Case valori | minuscolo tecnico (eccezione: nomi di prodotto con il loro case, per esempio `NexusQ`) |

Properties: `project`, `component`, `repository-type`, `technology`, `language`, `status`, `exposure`, `criticality`

---

## 6. Label

| Regola | Dettaglio |
|---|---|
| Set | minimo: solo stati speciali o decisionali |
| Case | minuscolo |

Label standard: `invalid`, `duplicate`, `wontfix`

Le label non duplicano mai i campi delle issue o dei project.

---

## 7. Ambienti

| Regola | Dettaglio |
|---|---|
| Case | minuscolo |
| Nomi | `develop`, `dev`, `test`, `prod` |

---

## 8. Struttura di `.github/` e nomi dei file

### Repository `.github` (organizzazione)

```
.github/
├── agents/
│   └── <nome>.agent.md
├── instructions/
│   └── <nome>.instructions.md
├── ISSUE_TEMPLATE/
│   ├── <tipo>.yml            (uno per Issue Type)
│   └── config.yml
└── pull_request_template.md
docs/
└── conventions.md            (questo documento)
profile/
└── README.md                 (pagina dell'organizzazione)
```

Agent, instructions e template valgono per tutti i repository dell'organizzazione.

### Repository applicativi

```
.github/
├── copilot-instructions.md   (contesto del repository: stack, struttura, rimandi)
├── instructions/
│   └── <nome>.instructions.md  (solo regole specifiche del repository)
├── skills/
│   └── <nome>/SKILL.md         (procedure ripetibili specifiche del repository)
└── prompts/
    ├── active/
    ├── done/
    └── superseded/
        └── plan-<AAAAMMGG>-<hhmm>-<slug>.prompt.md
<repository>.code-workspace   (con `chat.includeReferencedInstructions: true`)
```

### Nomi dei file

| Tipo | Pattern | Esempio |
|---|---|---|
| Custom agent | `<nome>.agent.md`, con `name` nel frontmatter uguale a `<nome>` | `gitflow.agent.md`, `name: gitflow` |
| Instructions | `<nome>.instructions.md` | `git.instructions.md` |
| Skill | `<nome>/SKILL.md` | `dao-dbtransaction-refactor/SKILL.md` |
| Piano | `plan-<AAAAMMGG>-<hhmm>-<slug>.prompt.md` | `plan-20260519-1708-net10-migration.prompt.md` |
| Template issue | `<tipo>.yml`, tipo in minuscolo | `bug.yml` |

I nomi sono in inglese, minuscoli, in kebab-case, senza abbreviazioni. Il nome di un custom agent è il nome del file senza estensione: così nel menu degli agent e nei rimandi si chiama allo stesso modo.

### Data nei file

Ogni file di regole o documentazione riporta in una tabella tre righe: la data di creazione, la data dell'ultima modifica e il numero di revisione.

| Riga | Regola |
|---|---|
| `**Creato**` | data di creazione; non cambia più |
| `**Aggiornato**` | data dell'ultima modifica, da `Get-Date -Format "dd/MM/yyyy"`; alla creazione è uguale a Creato |
| `**Revisione**` | `1` alla creazione, `+1` a ogni modifica salvata |

```markdown
| | |
|---|---|
| **Creato** | GG/MM/AAAA |
| **Aggiornato** | GG/MM/AAAA |
| **Revisione** | 1 |
```

| Tipo di file | Dove sta la tabella |
|---|---|
| Piano | metadati sotto il titolo, insieme a Issue, Branch e piani collegati (vedi [`plan-files.instructions.md §3`](../.github/instructions/plan-files.instructions.md)) |
| Instructions, custom agent, skill | subito dopo il frontmatter (dopo il titolo, se c'è) |
| Documento (`docs/`) | subito dopo il titolo |

Un file rinominato o riscritto conserva Creato e continua la numerazione: la storia è quella del file, non del nome.

### Template

- **Issue**: un file `.yml` per Issue Type; GitHub mostra il menu di scelta quando si crea una issue dal browser, `config.yml` lo personalizza. Il formato del corpo, anche per le issue create dal browser, è in [`issues.instructions.md`](../.github/instructions/issues.instructions.md).
- **Pull request**: un solo file, precompilato quando si apre una pull request dal browser; il custom agent `gitflow` compila lo stesso formato. Il formato è in [`pull-requests.instructions.md`](../.github/instructions/pull-requests.instructions.md).
- **Project**: non è un file nel repository; si configura nell'interfaccia web dell'organizzazione (Settings → Projects → Project templates) e va replicato a mano per i nuovi project.

---

## 9. Passaggio fra custom agent

Nell'harness Copilot di VS Code non esistono handoff e non si cambia agent dentro una sessione. Un custom agent passa il lavoro a un altro **invocandolo con lo strumento `agent`**, nella stessa chat: l'agent invocato esegue la propria procedura, con le sue bozze e le sue conferme, e restituisce il risultato a chi lo ha chiamato, che prosegue. Ogni agent fa solo il proprio lavoro: non legge né ripete la procedura di un altro.

| Regola | Dettaglio |
|---|---|
| Quando | sempre dopo una domanda all'utente («Procedo con la creazione del branch?»), mai da sola |
| Prompt di invocazione | contiene tutto quello che l'agent invocato non può ricavare da solo: numero della issue, repository, elenco confermato; il resto lo ricava da issue e branch |
| Risultato | chi invoca lo riporta all'utente e continua |
| Lavoro autonomo | l'esecuzione di un piano si invoca allo stesso modo sull'agent built-in `Agent` |

Ogni custom agent ha `agent` fra i suoi tools. Il frontmatter non usa `handoffs`: esisteva solo nell'harness Local, deprecato e in rimozione a febbraio 2027.
