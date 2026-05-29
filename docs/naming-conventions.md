# NexusQ — Documento Nomenclatura

> Convenzioni di naming per organization `Lutech-Siad`, valide per tutti i repository NexusQ.  
> Documento di riferimento per agenti, skill e sviluppatori.

---

## 1. Repository

| Regola | Dettaglio |
|---|---|
| Pattern | `nexusq-<componente>` |
| Case | lowercase |
| Separatore | trattino `-` |

Esempi: `nexusq-frontend`, `nexusq-backend`, `nexusq-jobs`, `nexusq-translations`, `nexusq-infrastructure`

---

## 2. Branch

| Regola | Dettaglio |
|---|---|
| Pattern | `<tipo>/<n>_<slug>` |
| Tipo | `feature`, `release`, `hotfix` |
| `<n>` | Numero della issue GitHub collegata |
| `<slug>` | Titolo breve in kebab-case minuscolo (solo lettere e trattini) |
| Separatore n/slug | underscore `_` |

Esempi:
- `feature/42_angular-migration`
- `hotfix/7_csp-header-missing`
- `release/1_v1-0-0`

Branch fissi (non seguono il pattern):
- `main` — produzione
- `develop` — integrazione

Regola operativa: ogni branch `feature/*`, `release/*`, `hotfix/*` deve avere una issue collegata. Se non esiste, crearla prima di staccare il branch.

---

## 3. Commit Message

Standard: **Conventional Commits 1.0.0**

| Regola | Dettaglio |
|---|---|
| Formato | `<type>(<scope>): <descrizione in italiano>` |
| Lingua | Italiano |
| Case type/scope | lowercase |

### Tipi consentiti

`feat` · `fix` · `refactor` · `perf` · `test` · `docs` · `build` · `ci` · `chore`

### Scope consigliati

`repo` · `migrazione` · `components` · `services` · `routing` · `state` · `ui` · `security` · `deps` · `docs`

### Footer

| Situazione | Footer |
|---|---|
| Commit collegato a issue | `Refs: #<n>` |
| Commit che chiude issue (solo repo `.github`) | `Closes: #<n>` |
| Bootstrap repo (nessuna issue) | Nessun footer richiesto |

> **Regola generale**: nei commit si usa `Refs:`, il footer `Closes: #<n>` va **solo nelle PR** (GitHub chiude la issue al merge della PR).
>
> **Eccezione repo `.github` (org-level)**: il repo `Lutech-Siad/.github` non ha branch `develop` e non usa PR. Se un commit completa interamente una issue, si può usare `Closes: #<n>` direttamente nel footer del commit.

Eccezione: `chore(repo)` per operazioni di bootstrap del repository non richiede footer issue.

---

## 4. Versioning e Tag

Standard: **SemVer 2.0.0**

| Regola | Dettaglio |
|---|---|
| Formato tag | `vMAJOR.MINOR.PATCH` |
| Prefisso | `v` (sempre) |

Semantica:
- **MAJOR**: breaking change architetturale, cambio API non retrocompatibile
- **MINOR**: nuove funzionalità retrocompatibili
- **PATCH**: bug fix, hotfix, piccole correzioni

Regole operative:
- Tag creati automaticamente dal CI al merge su `main`
- `release/*` → MINOR o MAJOR
- `hotfix/*` → PATCH
- Fallback: tag manuale da Jennifer se CI non attiva

---

## 5. Milestone

| Regola | Dettaglio |
|---|---|
| Case | kebab-case lowercase |
| Separatore | trattino `-` |
| Contenuto | Descrizione sintetica della fase di lavoro |

Esempi: `setup-governance`, `ci-cd`, `docker-dev`, `migrazione-angular`, `migrazione-adminlte`, `rbac`

---

## 6. Labels

| Regola | Dettaglio |
|---|---|
| Set | Minimo (solo stati speciali/decisionali) |
| Case | lowercase |

Labels standard: `invalid`, `duplicate`, `wontfix`

Regola: le label NON devono duplicare i Project Fields o gli Issue Fields.

---

## 7. Issue Types

| Regola | Dettaglio |
|---|---|
| Case | Iniziale maiuscola (Pascal Case singolo) |
| Livello | Organization |

Tipi: `Bug`, `Problem`, `Hotfix`, `Feature`, `RFC`, `CR`, `Refactoring`, `Migration`, `Task`

---

## 8. Organization Issue Fields

| Regola | Dettaglio |
|---|---|
| Case nomi | Human-readable, Pascal Case con spazi |
| Livello | Organization |

Campi: `Activity`, `Component`, `Effort`, `Estimate Hours`, `External References`, `Priority`, `Start date`, `Target date`

### Valori dei campi Single Select

| Campo | Valori |
|---|---|
| Priority | `Urgent`, `High`, `Medium`, `Low` |
| Effort | `XS`, `S`, `M`, `L`, `XL` |
| Activity | `development`, `docs`, `infrastructure`, `configuration` |
| Component | `frontend`, `backend`, `jobs`, `translations`, `multi-projects` |

Nota: i valori di Priority e Effort usano iniziale maiuscola; i valori di Activity e Component usano lowercase.

---

## 9. Project Fields

| Regola | Dettaglio |
|---|---|
| Case | Human-readable, Pascal Case con spazi |
| Livello | Project |

Campi nel Project: `Status`, `Sub-issues progress`

Valori Status: `Backlog`, `In Analysis`, `In Progress`, `Blocked`, `In Review`, `Done`

---

## 10. Repository Custom Properties

| Regola | Dettaglio |
|---|---|
| Case nomi | lowercase-kebab-case |
| Separatore | trattino `-` |
| Case valori | lowercase tecnico (eccezione: nomi prodotto con case reale, es. `NexusQ`) |

Properties: `project`, `component`, `repository-type`, `technology`, `language`, `status`, `exposure`, `criticality`

---

## 11. File e Cartelle GitHub (`.github/`)

### Struttura

```
.github/
├── copilot-instructions.md
├── agents/
│   └── <nome>.agent.md
├── instructions/
│   └── <nome>.instructions.md
├── skills/
│   └── <nome>/
│       └── SKILL.md
├── prompts/
│   ├── active/
│   │   └── plan-<YYYYMMDD>-<HHmm>-<slug>.prompt.md
│   ├── done/
│   │   └── plan-<YYYYMMDD>-<HHmm>-<slug>.prompt.md
│   └── superseded/
│       └── plan-<YYYYMMDD>-<HHmm>-<slug>.prompt.md
├── ISSUE_TEMPLATE/
│   ├── bug.yml
│   ├── feature.yml
│   ├── migration.yml
│   ├── ...
│   └── config.yml
└── pull_request_template.md
```

### Naming file

| Tipo | Pattern | Esempio |
|---|---|---|
| Agent | `<nome>.agent.md` | `gitflow.agent.md` |
| Instruction | `<nome>.instructions.md` | `git-commit.instructions.md` |
| Skill | `SKILL.md` dentro `.github/skills/<nome>/` | `.github/skills/git-commit/SKILL.md` |
| Prompt/Plan | `plan-<YYYYMMDD>-<HHmm>-<slug>.prompt.md` | `plan-20260519-1708-net10-migration.prompt.md` |

### Note sui template

**Issue template** (`ISSUE_TEMPLATE/`): cartella con più file `.yml` (uno per tipo di issue). GitHub mostra un menu di selezione quando si crea una issue dal browser. Il file `config.yml` personalizza il menu (es. link esterni, blank issue abilitata/disabilitata).

**PR template** (`pull_request_template.md`): singolo file. Il contenuto viene pre-compilato automaticamente quando si apre una PR dal browser. File singolo perché l'agent GitFlow gestirà la creazione delle PR e compilerà la description secondo il formato standard (sezione 13). Il template serve come fallback per aperture manuali.

**Project template**: non è un file nel repository. Si configura nell'interfaccia web dell'organization (Settings → Projects → Project templates). Definisce campi, view, filtri e workflow riutilizzabili. La configurazione standard è documentata nel master document (sezione 9) e va replicata manualmente per nuovi Project.

---

## 12. Issue Description

Formato standard:

```markdown
## Obiettivo

[Perché esiste questa issue]

## Scope

- [Bullet list di cosa va fatto]

## Riferimenti

- [Link a report, documenti, issue collegate]

## Note

- [Branch strategy, vincoli, dipendenze, stato]
```

---

## 13. Pull Request Description

Formato standard (corrisponde al template in `.github/pull_request_template.md`):

```markdown
## Modifiche

- [Bullet list di cosa è stato fatto]

## Screenshot / Preview

<!-- Inserire screenshot prima/dopo per modifiche UI (rimuovere la sezione se non applicabile) -->

## Test eseguiti

- [ ] Test unitari passano
- [ ] Test di integrazione passano

## Breaking changes

<!-- Descrivere eventuali modifiche che rompono la retrocompatibilità (rimuovere la sezione se non ce ne sono) -->

## Checklist

- [ ] Il codice compila senza errori
- [ ] I test esistenti passano
- [ ] Nuovi test aggiunti (se applicabile)
- [ ] Documentazione aggiornata (se applicabile)
- [ ] Nessun breaking change non documentato

## Note

- [Info operative, branch flow]

<!-- Footer: Closes: #N (sostituire N con il numero della issue collegata) -->
```

Il footer `Closes: #N` va sempre in fondo alla description della PR (parsato da GitHub per chiudere la issue al merge). **Mai usare `Closes:` nei commit** — nei commit si usa `Refs:`.

---

## 14. Ambienti

| Regola | Dettaglio |
|---|---|
| Case | lowercase |
| Nomi | `develop`, `dev`, `test`, `prod` |

---

## 15. Titoli Issue e PR

| Regola | Dettaglio |
|---|---|
| Lingua | Italiano |
| Case | Sentence case (iniziale maiuscola, resto minuscolo) |
| PR title | Deve coincidere con il titolo della issue collegata |

Distinzione semantica:
- **Migrazione** = cambio architetturale significativo, multi-version o multi-componente
- **Upgrade** = aggiornamento incrementale da una major alla successiva
