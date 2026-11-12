---
description: "Use when: creating, reading, updating, executing or moving a development plan file (.prompt.md) under .github/prompts/ in any repository of the Lutech-Siad organization. Covers location, states, naming, header, section order and content, and how the Stato checklist is kept up to date."
applyTo: "**/.github/prompts/**"
---

# Convenzioni file di piano — Lutech-Siad

| | |
|---|---|
| **Creato** | 11/06/2026 |
| **Aggiornato** | 12/11/2026 |
| **Revisione** | 4 |

Regole per percorso, nome, intestazione e contenuto dei piani di sviluppo, e per il loro aggiornamento durante l'esecuzione. La procedura di scrittura (analisi, stesura, revisione nell'editor, commit) è nel custom agent `planning`. Glossario: [`docs/conventions.md §1`](../../docs/conventions.md); struttura di `.github/` e data nei file: [`docs/conventions.md §8`](../../docs/conventions.md).

## 1. Percorso e stato

I piani stanno in `.github/prompts/` del repository a cui si riferiscono, in una sottocartella per stato:

| Sottocartella | Stato |
|---|---|
| `active/` | in lavorazione |
| `done/` | completato: tutte le caselle dello Stato e dei Criteri di accettazione spuntate. Lo spostamento avviene **sul branch di lavoro, prima della pull request**: dopo il merge il branch non esiste più |
| `superseded/` | sostituito da un piano successivo, che lo indica in **Sostituisce** |

Un piano cambia stato spostando il file, senza rinominarlo. Il file lo scrive un agent (il custom agent `planning`), mai il comando «Save as prompt file» di VS Code, che non rispetta nome e percorso.

## 2. Nome

`plan-<AAAAMMGG>-<hhmm>-<slug>.prompt.md`

- `<AAAAMMGG>-<hhmm>`: data e ora locali di creazione (`Get-Date -Format "yyyyMMdd-HHmm"`); non cambiano più.
- `<slug>`: kebab-case minuscolo in inglese, di norma lo slug del branch.

Esempio: `plan-20260923-1712-optimize-gasitem-list-sp.prompt.md`

## 3. Intestazione

Prima riga il titolo, poi la tabella dei metadati:

```markdown
# Piano: <titolo>

| | |
|---|---|
| **Creato** | GG/MM/AAAA |
| **Aggiornato** | GG/MM/AAAA |
| **Revisione** | <n> |
| **Issue** | [#<n> — <titolo della issue>](<url della issue>) |
| **Branch** | `<tipo>/<n>_<slug>` |
| **Commit automatico** | <sì o no> |
| **Dipende da** | `<nome del piano prerequisito>` |
| **Sostituisce** | `<nome del piano superato>` |
```

| Campo | Obbligatorio | Regola |
|---|---|---|
| **Creato** | sì | data di creazione; non cambia più |
| **Aggiornato** | sì | data dell'ultima modifica (`Get-Date -Format "dd/MM/yyyy"`); alla creazione è uguale a Creato |
| **Revisione** | sì | `1` alla creazione, `+1` a ogni modifica salvata |
| **Issue** | sì | la issue del lavoro, con link; se esiste, fra parentesi anche il riferimento esterno (Issue Tracker o JIRA) |
| **Branch** | sì | il branch del lavoro |
| **Commit automatico** | sì | scelto dall'utente quando il piano si scrive; vale per il commit del piano e per quello del lavoro a fine esecuzione (vedi §5). `sì`: i commit li esegue il custom agent `planning` senza chiedere conferma. `no`: i commit passano dal custom agent `gitflow`, che mostra la bozza e aspetta conferma. In nessun caso si fa push |
| **Dipende da** | solo se esiste | piano prerequisito, per esempio il piano di coordinamento di una wave |
| **Sostituisce** | solo se esiste | piano spostato in `superseded/` da questo |

## 4. Sezioni

Tutte le sezioni, nell'ordine in cui compaiono; le facoltative si omettono se non servono, mai si spostano.

| # | Sezione | Obbligatoria | Contenuto e forma |
|---|---|---|---|
| 1 | `## Contesto` | no | come funziona oggi il codice coinvolto e perché si interviene; prosa breve |
| 2 | `## Obiettivo` | sì | cosa si vuole ottenere, in modo verificabile; una frase, più un elenco se gli obiettivi sono più di uno |
| 3 | `## Stato` | sì | checklist delle modifiche principali (`- [ ]` / `- [x]`), una voce per `### Modifica n`; per un piano di coordinamento, una voce per piano figlio con il link. Tenuta aggiornata durante l'esecuzione (vedi §5) |
| 4 | `## Fuori scope` | no | elenco di cosa non toccare; indispensabile su codice legacy o refactoring |
| 5 | `## Analisi` | no | evidenze raccolte, con sottosezioni per argomento: `### Codice coinvolto`, `### Chiamanti`, `### Dati`, `### Test esistenti`; tabelle o elenchi, non prosa |
| 6 | `## Strategia` | no | `### Approccio scelto` (e perché) e `### Alternative scartate` (una riga ciascuna, con il motivo) |
| 7 | `## Istruzioni vincolanti` | no | instructions e skill del repository da applicare durante l'esecuzione, con link, e regole di precedenza in caso di conflitto |
| 8 | `## Modifiche` | sì | una `### Modifica n — <titolo>` per intervento, nell'ordine di esecuzione; dentro: **File**, **Intervento**, **Motivazione**, eventuali frammenti indispensabili |
| 9 | `## File da modificare` | no | tabella file → modifiche, utile quando le modifiche toccano molti file |
| 10 | `## Rischi e mitigazioni` | no | tabella rischio → mitigazione |
| 11 | `## Verifica` | no | `### Build e test automatici` (comandi e risultato atteso) e `### Prove manuali` (scenario, ambiente, chi prova) |
| 12 | `## Criteri di accettazione` | sì | checklist `- [ ]` di condizioni oggettive che chiudono il piano: build, test, invarianti attese |
| 13 | `## Considerazioni aperte` | no | elenco `- <domanda> → <chi decide> → <entro quando>` |
| 14 | `## Registro delle decisioni` | no | elenco `- GG/MM/AAAA — <decisione> (<chi>)`, in ordine cronologico |
| 15 | `## Riferimenti` | no | elenco nella forma dei Riferimenti delle issue ([`issues.instructions.md §6`](issues.instructions.md)): `Issue`, `File`, `Fonte`, più `Piano: [nome](percorso)` per i piani collegati |

Regole di scrittura: lingua italiana, niente abbreviazioni, frecce con `→`; percorsi e identificatori di codice fra apici inversi; il piano descrive il lavoro, non lo esegue (firme o frammenti indispensabili, mai codice completo).

## 5. Esecuzione e aggiornamento

- Per ogni voce dello Stato: eseguire → se esiste un modo per verificarne l'esito (build, test, controllo pertinente) verificare → spuntare la casella → passare alla successiva. Una voce con verifica oggettiva non si spunta prima della verifica.
- Ogni modifica al piano aggiorna **Aggiornato** e **Revisione**; **Creato** e il nome del file non cambiano.
- Chi esegue non committa mai. Finita l'ultima voce dello Stato, verifica i Criteri di accettazione, li spunta e invita l'utente a tornare al custom agent `planning`, che chiude il piano: sposta il file in `done/` e fa un solo commit con tutto il lavoro, piano compreso, con il messaggio secondo [`git.instructions.md §3`](git.instructions.md) e `Refs: #<n>`. Con **Commit automatico** `sì` lo esegue `planning` senza chiedere; con `no` lo fa `gitflow` con bozza e conferma. Mai push: il push e la pull request si fanno con `gitflow`.
- Un piano grande che coordina più piani (per esempio un audit in wave) elenca i piani figli nello Stato, con il link; ogni figlio indica il padre in **Dipende da**.
- Se un piano ne sostituisce un altro, il vecchio passa in `superseded/` e il nuovo lo indica in **Sostituisce**. Un piano interrotto senza sostituto resta in `active/` finché non si decide cosa farne.
