---
title: "GitHub Issues for TAG Actions"
linkTitle: "GitHub Issues for TAG Actions"
weight: 20
type: "sigs"
draft: false
lang: "en"
---

To **effectively manage the work** of the **Aurora Technical Advisory Group (TAG)** and ensure decisions lead to **tangible actions**, **GitHub Issues** should be used as a tracking tool. This ensures that meeting agendas, outcomes, and follow-ups are well-documented, easily searchable, and linked to relevant discussions.

By leveraging **GitHub Issues and Project Boards**, we can integrate TAG decisions into **workflows**, making them actionable and trackable across the Aurora ecosystem.

---

## 1. Creating a GitHub Issue for Each TAG Meeting

Each TAG meeting should have a **corresponding GitHub Issue** as the **single source of truth** for the meeting agenda, discussions, and follow-ups.

- **Before the Meeting**:
  - Create a **GitHub Issue** titled:**“Aurora TAG Meeting – YYYY-MM-DD”**
  - Use the **issue template** (see Section 6) and pre-fill the agenda.
  - Add links to relevant **OneNote, Loop pages, GitHub issues, or pre-reading materials** to prepare participants.
- **After the Meeting**:
  - Update the same issue with a **summary of key discussions, decisions, and follow-ups**.
  - Convert **action items** into separate **linked issues** (see Section 3).

This ensures **all TAG meetings are properly recorded** in a **centralized, trackable way**.

---

## 2. Using Consistent Labels and Project Boards for Easy Tracking

To improve organization and searchability:

- Use a **GitHub Label** such as `TAG-Meeting` to categorize all TAG-related issues.
- If using **GitHub Project Boards**, create one called:
  - **“Aurora TAG Governance”**
  - Add all individual **TAG meeting issues** under this board.

This makes it easy to query all **decisions, action items, and meeting records** for long-term reference.

---

## 3. Sub-Issues for Action Items and Decisions

Whenever the TAG makes a decision that requires action, create a **separate GitHub Issue** and link it to the **meeting issue** using `#<issue-number>`.

- **Example**:
  - **TAG Meeting Decision**: Implement a new backup solution.
  - **New Issue Created**:
    - Title: “Implement backup solution X – Action from TAG 2025-04-10”
    - Assigned To: Responsible person/team
    - Due Date: Added as part of the milestone or sprint backlog

Using this approach ensures every decision has a **corresponding action item** that is **assigned, tracked, and completed** like any other GitHub Issue.

---

## 4. Linking to Documentation

To keep all relevant information in one place, **link documentation** directly in each issue:

- **Meeting Notes** (OneNote, Loop, SharePoint)
- **Finalized meeting minutes** (if published separately)
- **Past TAG meeting notes** for historical context

By keeping everything **in the meeting issue**, anyone can **access full context** without searching across multiple tools.

---

## 5. Integrating TAG Actions into Workflows

TAG decisions should **translate into actionable work items** rather than remain isolated in meeting notes.

- **Best Practice**:
  - Ensure that **TAG-related issues** appear in the **Cloud Native Solutions team’s GitHub Project Board or Milestones**, making them **visible and trackable**.
  - Link issues to **relevant repositories**, ensuring that decisions impact development work.
  - This mirrors **how open-source projects track architecture decisions via GitHub Issues and RoADs (Records of Architectural Decisions)**.

By integrating **TAG actions into existing workflows**, they remain **visible beyond the meeting itself**.

---

## 6. Recommended GitHub Issue Template

### Title

- **“Aurora TAG Meeting – YYYY-MM-DD”**

### Description

### Overview

- Short introduction or goal of the meeting.

### Agenda

- Copy the agenda bullet points (from the meeting template).

### Next Meeting Agenda Items

- Placeholder for items earmarked for discussion in the next session.

### Action Items and Records of Architectural Decisions (RoADs)

- List action items with assigned owners and due dates.

### Links

- OneNote, SharePoint, past meeting notes, or other references.
