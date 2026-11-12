---
description: "Use when: creating or naming branches, committing, composing commit messages and footers, pushing, versioning, tagging, releasing, backmerging, choosing a milestone, in any repository of the Lutech-Siad organization. Covers GitFlow branch types and flow, Conventional Commits types, scopes and footers, SemVer versions and tags, release and backmerge rules, milestones."
applyTo: "**"
---

# Convenzioni Git — Lutech-Siad

| | |
|---|---|
| **Creato** | 29/05/2026 |
| **Aggiornato** | 12/11/2026 |
| **Revisione** | 4 |

Regole per branch, commit, versioni, release e milestone. Le procedure (bozza, conferma, esecuzione) sono nel custom agent `gitflow`. Glossario, lingua, repository e persone: [`docs/conventions.md`](../../docs/conventions.md). Formato delle pull request: [`pull-requests.instructions.md`](pull-requests.instructions.md). Issue: [`issues.instructions.md`](issues.instructions.md).

## 1. Utente git

Configurazione locale al repository, senza `--global`:

```bash
git config user.name "Nome Cognome"
git config user.email "nome.cognome@lutech.it"
```

`user.name` è nome e cognome per esteso, non lo username GitHub: è quello che compare nello storico.

## 2. Branch

### Branch fissi

| Branch | Ruolo | Ruleset |
|---|---|---|
| `main` | produzione | pull request obbligatoria, 1 approvazione, conversazioni risolte, solo **squash** |
| `develop` | integrazione | pull request obbligatoria, 1 approvazione, conversazioni risolte, **merge commit** (o rebase) |

Il repository `.github` ha solo `main`, senza branch di lavoro né pull request (vedi Divieti).

### Branch di lavoro

Pattern: `<tipo>/<n>_<slug>`

| Tipo | Da | Verso | Quando |
|---|---|---|---|
| `feature` | `develop` | `develop` | nuova funzionalità, refactoring, migrazione, attività |
| `fix` | `develop` | `develop` | correzione non urgente (Bug, Problem) |
| `hotfix` | `main` | `main`, poi backmerge | correzione urgente in produzione |
| `release` | `develop` | `main`, poi backmerge | rilascio di una versione |
| `backmerge` | `main` | `develop` | riallineamento di `develop` dopo release o hotfix |

- `<n>` è il numero della issue collegata: per `feature`, `fix` e `hotfix` la issue del lavoro; per `release` e `backmerge` la issue di release (per il backmerge di un hotfix, la issue dell'hotfix). Nessun branch senza issue: se manca si crea prima.
- `<slug>` è in kebab-case minuscolo, in inglese, solo lettere, numeri e trattini. Per `release` e `backmerge` lo slug è la versione: `v<major>-<minor>-<patch>`.

Esempi: `feature/42_angular-migration`, `fix/19_gas-contract-null-reference`, `hotfix/7_csp-header-missing`, `release/147_v2-0-0`, `backmerge/147_v2-0-0`

### Divieti

- Mai committare direttamente su `main` o `develop` (eccezione: repository `.github`).
- Mai `push --force`, `reset --hard` o `rebase` di un branch condiviso senza richiesta esplicita.
- Mai push senza richiesta esplicita.

## 3. Commit

Standard: [Conventional Commits 1.0.0](https://www.conventionalcommits.org/it/v1.0.0/).

```
<type>(<scope>): <descrizione>

[body]

[footer]
```

### Titolo

- `type` e `scope` in inglese minuscolo; descrizione in italiano, con il verbo all'**imperativo** («aggiungi», «correggi», «rimuovi»), senza punto finale, al massimo 72 caratteri.
- Un commit, uno scopo: modifiche non correlate vanno in commit separati.

| Type | Quando |
|---|---|
| `feat` | nuova funzionalità |
| `fix` | correzione di un difetto |
| `refactor` | riscrittura senza cambi funzionali |
| `perf` | miglioramento delle prestazioni |
| `test` | aggiunta o modifica di test |
| `docs` | solo documentazione |
| `build` | build e dipendenze (npm, NuGet) |
| `ci` | GitHub Actions e pipeline |
| `chore` | configurazione, nomi, manutenzione |
| `release` | solo nel titolo della pull request di release (vedi §5) |

Scope: uno solo, il più specifico. Se nessuno è adatto: `repo`.

| Scope | Repository | Cosa tocca |
|---|---|---|
| `repo` | tutti | struttura e configurazione del repository: `.github/`, workspace, `.gitignore`, README, agent e instructions |
| `ci` | tutti | GitHub Actions e pipeline |
| `config` | tutti | configurazione dell'applicazione: `appsettings`, `environment`, variabili |
| `deps` | tutti | dipendenze: NuGet, npm |
| `docs` | tutti | documentazione |
| `security` | tutti | autorizzazioni, RBAC, IDOR, hardening, intestazioni di sicurezza |
| `migration` | tutti | cambio di versione o di tecnologia (framework, librerie, database) |
| `api` | backend | endpoint e controller di `WebServiceAPI` e `WebApp` |
| `auth` | backend | autenticazione: login, sessione, token |
| `dal` | backend | accesso ai dati: `DataAccess`, DAO, stored procedure, integrazioni ERP |
| `models` | backend | `DomainModel` e modelli di scambio |
| `jobs` | backend | elaborazioni pianificate |
| `components` | frontend | componenti Angular |
| `services` | frontend | servizi Angular e chiamate alle API |
| `routing` | frontend | rotte, guardie, navigazione |
| `state` | frontend | stato dell'applicazione e store |
| `ui` | frontend | layout, stili, template, traduzioni visibili |

### Body

Facoltativo: si aggiunge quando il titolo non basta a capire il **perché** (motivo non ovvio, effetti collaterali, decisione rivedibile, più moduli toccati). Separato dal titolo da una riga vuota; paragrafi ed elenchi senza andare a capo a mano, perché GitHub e VS Code mandano a capo da soli. Nel commit di squash o merge di una pull request il body riassume l'intero lavoro.

### Footer

| Footer | Regola |
|---|---|
| `Refs: #<n>` | **obbligatorio** in ogni commit, con la issue del branch. Unica eccezione: il primo commit di un repository (`chore(repo)`). |
| `Closes: #<n>` | solo nel repository `.github`, quando il commit completa la issue. Negli altri repository la chiusura passa dalla pull request. |
| `BREAKING CHANGE: <descrizione>` | quando la modifica rompe la retrocompatibilità; determina il major (vedi §4). |
| `Co-authored-by:` | solo per persone reali o per GitHub Copilot, nella forma che Copilot genera. **Mai** Claude né altri assistenti, mai righe «Generated with». |

I footer si sommano, una riga ciascuno, con `Refs:` sempre presente:

```
feat(api): cambia il formato della risposta di GetCustomer

BREAKING CHANGE: il campo `address` diventa un oggetto con via, città e CAP; i client che leggono una stringa vanno aggiornati.
Refs: #42
```

## 4. Versioni e tag

Standard: [SemVer 2.0.0](https://semver.org/lang/it/). Tag `v<major>.<minor>.<patch>`, protetti (niente cancellazione né spostamento).

| Parte | Quando cresce |
|---|---|
| `major` | almeno un commit con `BREAKING CHANGE`, o cambio non retrocompatibile dichiarato |
| `minor` | release ordinaria: funzionalità retrocompatibili |
| `patch` | hotfix |

### Chi crea tag e release

Il workflow `release.yml` di `nexusq-backend` e `nexusq-frontend`, al merge di una pull request su `main`:

1. legge la versione dal nome del branch, se finisce con `_v<major>-<minor>-<patch>`; altrimenti `hotfix/*` → patch, `release/*` → minor, altri branch → nessun rilascio;
2. si ferma se il tag esiste già;
3. compila, crea il tag e la GitHub Release con note generate e artefatti allegati.

Esiste anche l'avvio manuale (`workflow_dispatch`) con scelta del bump. Il workflow **non** apre la pull request di backmerge. Il repository `.github` non ha versioni né tag.

### Scelta della versione

- Base: ultimo tag (`git tag -l 'v*' --sort=-v:refname | head -1`).
- Release: minor successivo. Se fra l'ultimo tag e `develop` c'è almeno un `BREAKING CHANGE`, si propone il major successivo evidenziandolo: la decisione resta a chi rilascia.
- Hotfix: patch successivo.
- Prima di usarla, verificare che non esistano già un tag o un branch con quella versione.
- La stessa versione compare in branch, milestone, titolo della issue di release e titolo della pull request, ciascuno nel proprio formato (`v2-0-0` nel branch, `v2.0.0` altrove).

## 5. Release e backmerge

1. **Issue di release** (tipo Task, template Release, milestone = versione) con l'elenco puntato delle issue incluse: non sub-issue, perché quel lavoro ha già la sua issue, il suo branch e la sua pull request.
2. **Branch** `release/<n>_v<major>-<minor>-<patch>` da `develop`; le correzioni di rilascio si committano lì con `Refs: #<n>`.
3. **Pull request** verso `main`: titolo `release: v<major>.<minor>.<patch>`; footer `Closes: #<n>` per la issue di release e per ogni issue inclusa (si chiudono al merge su `main`, non prima); merge squash.
4. **Backmerge**: branch `backmerge/<n>_v<major>-<minor>-<patch>` da `main`, pull request verso `develop` con titolo `chore(repo): riallinea develop con main dopo la release v<major>.<minor>.<patch>` e footer `Refs: #<n>`; merge commit. Va aperto subito dopo il merge della release, a mano o con il custom agent `gitflow`.

Un **hotfix** segue gli stessi passi con la issue dell'hotfix al posto di quella di release: branch `hotfix/<n>_<slug>` da `main`, pull request verso `main` con titolo `fix(<scope>): ...` e `Closes: #<n>`, versione patch, poi backmerge con la versione nello slug.

## 6. Milestone

| Repository | Milestone |
|---|---|
| `nexusq-backend`, `nexusq-frontend` | la versione da rilasciare, `v<major>.<minor>.<patch>`, identica al tag. Per il lavoro nuovo: il minor successivo; per un hotfix: il patch successivo. Nessuna milestone descrittiva. |
| `.github` e gli altri repository | descrittiva, in kebab-case minuscolo (`setup-governance`, `ci-cd`) |

Issue, pull request e issue di release di uno stesso rilascio portano la stessa milestone; la milestone si chiude quando il tag esiste.
