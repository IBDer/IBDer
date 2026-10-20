# Biologic regimens, as verified on 2026-10-20

Status: **working note, not a decision.** The maintainer decides which drugs ship and which words
appear (AGENTS.md section 4). This file records what was checked, where, and what remains unknown.

## How this was checked

The Chinese NMPA labels are PDFs on manufacturer sites, and this workspace cannot read PDFs. The
regimens below therefore come from the **US originator label on DailyMed** (National Library of
Medicine), which is the same product and the same dosing programme. **This is not the Chinese
insurance-catalogue label.** Where the Chinese label differs in wording or approved indication, the
Chinese label wins and this table is wrong.

## Verified

The zh-Hans display names are product strings and live in the String Catalog, not here.

| Drug | Route | Start of treatment | Then |
| --- | --- | --- | --- |
| Infliximab | IV | 5 mg/kg at weeks 0, 2, 6 | every 8 weeks |
| Vedolizumab | IV | 300 mg at weeks 0, 2, 6 | every 8 weeks |
| Adalimumab | SC | 160 mg on day 1, 80 mg on day 15 | 40 mg every other week from day 29 |
| Risankizumab | IV then SC | 600 mg IV at weeks 0, 4, 8 | 180 mg SC at week 12, then every 8 weeks |

Sources, read on 2026-10-20:

- Remicade: <https://dailymed.nlm.nih.gov/dailymed/search.cfm?query=REMICADE>
- Entyvio: <https://dailymed.nlm.nih.gov/dailymed/search.cfm?query=ENTYVIO>
- Humira: <https://dailymed.nlm.nih.gov/dailymed/search.cfm?query=HUMIRA>
- Skyrizi: <https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=7148c8eb-b39e-e20a-6494-a6df82392858>

The risankizumab programme matches what the maintainer described: three intravenous doses four weeks
apart, the fourth dose subcutaneous, then subcutaneous every eight weeks.

## Not verified here

| Drug | What is missing |
| --- | --- |
| Ustekinumab | The Crohn's induction dose (weight-banded) and the maintenance interval; the label section was beyond what the fetch returned. |
| Guselkumab | The Crohn's and ulcerative colitis induction and maintenance programme, for the same reason. |
| Any biosimilar | Not checked at all; the brand name matters for the patient's own record. |

## What this means for the app

- A plan is **a sequence of dated doses**, not one interval: induction and maintenance differ in
  amount, route and spacing. Hard-coding "every 8 weeks" would be wrong for three of the four.
- The record of a dose carries the amount the patient was actually given, which the hospital decides;
  the app never calculates a dose from body weight.
- The drug list ships only what has been verified, until the maintainer decides otherwise.
