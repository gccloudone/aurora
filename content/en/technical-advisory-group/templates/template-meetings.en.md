---
title: "Meetings"
linkTitle: "Meetings"
weight: 15
type: "sigs"
draft: false
lang: "en"
date: 2025-01-01
---

Consistent meeting practices are essential for ensuring transparency, efficiency, and accountability within the Aurora TAG. Establishing standardized templates for meeting agendas, minutes, and decision records helps streamline meetings, improve collaboration, and ensure that key information is captured systematically. Below are recommended templates and best practices.

---

## Meeting Agenda Template

Each meeting invite or agenda document should follow a standardized structure to ensure clarity and preparedness among attendees.

### 1. Meeting Details

- Meeting Name: Aurora TAG
- Date and Time: YYYY-MM-DD, HH:MM – HH:MM (Time Zone)
- Location/Platform: Specify physical meeting location or virtual link
- Facilitator/Chair: Name
- Note Taker: Name (if pre-assigned)

### 2. Meeting Objectives (Optional)

If the meeting has a specific focus, include a brief statement outlining key objectives. Example:

- *“Finalize the decision on Proposal X.”*
- *“Review outstanding security architecture concerns.”*

### 3. Proposed Agenda Items

List topics in a structured format to ensure all key points are covered. A typical agenda structure may include:

1. Review of Pending Architectural Items (design proposals, issues, etc.)
2. Outstanding Decisions to Ratify (items requiring formal agreement)
3. Roundtable Discussion (open floor for additional contributions)
4. Final Remarks (summary, action item review, next steps)
5. Setting the Next Meeting’s Agenda

### 4. References and Pre-Reading (If Applicable)

To enhance preparedness, include links to relevant documents, GitHub issues, OneNote pages, or other pre-reading materials. Example:

- *“See GitHub issue AUR-123 for background on Item 1.”*

This ensures that all participants arrive informed and discussions remain focused.

---

## Meeting Minutes Template

Meeting minutes should follow a structured format to capture key discussions, decisions, and action items efficiently.

### 1. Attendance

Maintaining an accurate attendance record is important for accountability and tracking expertise present.

- Present:
  - [x]  John Doe – Senior Architect
  - [ ]  Jane Smith – Product Lead
- Regrets: (List names and roles of those unable to attend)

### 2. Agenda Items and Discussion Summary

Each agenda item should be accompanied by a brief summary of discussions and key takeaways. Example format:

Item 1: Review of Security Architecture

- Discussion: The team reviewed the updated security design, identifying key risks and potential mitigations.
- Decision: Adopt Solution B for user authentication.

Each agenda item should follow a similar structure to ensure clarity.

### 3. Decisions Made

Decisions should be explicitly recorded and formatted for visibility. Example:

- Decision: Implement a Kubernetes-based deployment model for Service X.
- Decision: Align data encryption policies with GoC standards by Q3 2025.

If formal voting occurs, record the outcome, e.g.:

- *“Decision: Move forward with Proposal X (5 in favor, 2 against).”*

### 4. Action Items

Tracking assigned actions ensures follow-up. A structured table is recommended:

| Action Item                  | Responsible | Deadline   |
|----------------------------------|-----------------|----------------|
| Prototype new logging solution   | Alice (DevOps)  | May 15, 2025   |
| Schedule security review meeting | Bob (Security)  | April 30, 2025 |

Even if no new actions arise, this section should remain (noted as “N/A”) to maintain consistency.

### 5. Record of Decisions (RoD)

If decisions are not recorded inline, maintain a separate summary table:

| Decision      | Responsible   | Notes                   |
|-------------------|-------------------|-----------------------------|
| Migrate to AWS    | Cloud Team        | Phase 1 complete by Q3 2025 |
| Standardize  APIs | API Working Group | Finalize specs by Q2 2025   |

For architectural decisions, reference corresponding Records of Architectural Decisions (RoADs).

### 6. Roundtable Notes

Capture additional points raised that were not part of the structured agenda. This helps document unstructured discussions and ensures no insights are lost.

### 7. Next Steps and Next Meeting

Clearly document follow-up tasks and topics earmarked for the next meeting. Example:

- *“Discuss data governance framework in the next session.”*
- *“Present an update on Service X testing results.”*

### 8. Note Taker Acknowledgment

Specify who took the notes for accountability. Example:

- *“Meeting notes were taken by .”*

---

## Best Practices for Meeting Documentation and Circulation

To ensure effective documentation and transparency:

1. Draft minutes promptly – Ideally within 2-3 business days after the meeting.
2. Circulate for review – Share the draft with attendees via Teams, GitHub, or email for feedback before finalizing.
3. Official storage – Official decision records will be stored in markdown within gccloudone, while internal documentation and discussions may be maintained in SharePoint or GCdocs as needed.

Using these standardized templates helps maintain clarity, accountability, and alignment with best practices in technical governance.
