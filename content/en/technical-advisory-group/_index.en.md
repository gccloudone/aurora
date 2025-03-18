---
title: "Technical Advisory Group (TAG) Charter"
linkTitle: "Technical Advisory Group"
weight: 10
type: "tag"
draft: false
showToc: true
lang: "en"
date: 2025-01-01
---

## 1. Overview and Mandate

The **Aurora Technical Advisory Group (TAG)** is an **advisory body** that provides expert guidance and recommendations on the Aurora project’s architecture, standards, security, and best practices. By convening architects, technical leads, and relevant stakeholders within Shared Services Canada (SSC) and broader Government of Canada (GoC) contexts, the Aurora TAG:

- Evaluates **technical proposals** and **enhancement requests**, ensuring alignment with GoC policies and SSC enterprise standards.
- Recommends **best practices** and **compliance** approaches for security, architecture, and operational workflows.
- Facilitates **collaboration** across different teams and domains, maintaining transparency and shared accountability.
- Advises on **risk mitigation** strategies—particularly around new or changing technologies that might introduce security concerns.

Although the TAG’s role is advisory, its recommendations carry significant influence. **Final decision-making authority** remains with designated executives or governance committees (e.g., Directors, Architecture Boards), but TAG endorsements generally guide Aurora’s technical direction.

---

## 2. Scope of Responsibilities

1. **Technical Architecture**

    Review proposals (e.g., new frameworks, solution designs, integration methods) and advise on compliance, scalability, and alignment with Aurora’s roadmap.

2. **Standards and Guidelines**

    Recommend coding standards, platform/tool usage policies, and reference architectures consistent with GoC cybersecurity policies and SSC architectural frameworks.

3. **Security Advisory**

    Identify and discuss potential **security vulnerabilities** arising from Aurora’s architecture or proposals. Where necessary, work privately (e.g., restricted channels) to address high-risk or “zero-day” vulnerabilities before public disclosure.

4. **Cross-Functional Coordination**

    Liaise with various teams—Security, DevOps, Operations, etc.—to ensure all technical aspects are factored into decisions.

5. **Governance and Documentation**

    Develop and maintain clear processes for architectural proposals (AEPs), decision logs, meeting minutes, and other documentation to ensure **transparency and continuity**.


---

## 3. Authority and Governance

1. **Sponsoring Executive**
    - The TAG is **sponsored by a Director** (EX level or Assistant Director) who oversees Aurora’s broader strategic direction.
    - The sponsor reviews escalations, assists with resource constraints, and can override or confirm TAG recommendations in exceptional circumstances.
2. **Advisory Nature**
    - The Aurora TAG **does not implement** solutions directly; rather, it **advises** on technical directions. Implementation falls to the appropriate project teams or operational groups.
3. **Decision Influence**
    - TAG recommendations typically guide project decisions. Where necessary, decisions are ratified by the sponsor, the Aurora Director, or an SSC/GoC governance body (e.g., an Architecture Review Board).
    - If the TAG is unable to reach consensus or a **veto** is invoked, the matter is escalated to the **Director** (or designated sponsor) for resolution.

---

## 4. Membership and Roles

### 4.1 Composition

- **Core Voting Members**:
    - Typically **IT-04** (Senior Architects, Lead Engineers) and/or **IT-05** (Principal Architect, Chief Engineer).
    - Additional specialized members can include **IT-03** (Technical Advisors) for domain expertise (e.g., Security, Cloud).
    - Membership size: ~8–12 people to ensure diverse perspectives but maintain efficient discussions.
- **Observers / Guests**:
    - Non-voting participants who attend specific meetings to share subject-matter input or learn about Aurora’s technical direction.
    - May include policy advisors, security analysts, or external consultants.
    - Observers can speak, but **only core members** count for consensus or formal voting.

### 4.2 Responsibilities by Role

1. **Executive Sponsor (Director or AD)**
    - **Approves the TAG Charter** and any major amendments.
    - Provides strategic alignment and is the ultimate escalation point if consensus cannot be reached.
    - Authorizes membership appointments, especially for veto-capable members.
2. **Chair (IT-04/IT-05)**
    - Facilitates TAG meetings, sets agendas, and ensures key discussions and decisions are documented.
    - Oversees the day-to-day governance of the TAG’s processes (meeting cadence, record-keeping, membership updates).
    - Maintains communication with the Executive Sponsor for escalations, urgent issues, or policy alignment.
    - Serves a term (e.g., 6–12 months) or as determined by the Sponsor.
3. **Co-Chair / Vice-Chair (IT-04/IT-05)**
    - Supports the Chair and steps in when the Chair is unavailable.
    - Shares administrative duties (e.g., timekeeping, tracking action items, liaising with other teams).
    - May assume or share the Chair role if the TAG decides on a rotating model.
4. **Senior Technical Leads (IT-04/IT-05)**
    - Core contributors to technical discussions.
    - Evaluate proposals thoroughly, considering architecture, performance, and security implications.
    - **Potential veto authority** (limited to 1–3 designated individuals; see Section 6).
5. **Technical Advisors (IT-03)**
    - Provide subject-matter expertise (e.g., cloud, cybersecurity, devops).
    - Offer informed opinions and assist with drafting proposals or analyzing issues.
    - Engage actively in discussions and follow up on assigned actions.
6. **Secretary / Coordinator** (optional)
    - Schedules meetings, circulates agendas, and records meeting minutes.
    - Maintains official records in GCdocs/SharePoint/Teams.
    - Can be a non-technical or junior technical staff (e.g., AS/CR or IT-02).

**While the IT-03 / IT-04 distinction is illustrative of general role expectations, in practice, individuals may take on higher responsibilities based on expertise and project needs.**

---

## 5. Meetings and Operations

1. **Frequency**
    - The TAG typically meets **bi-weekly** or **monthly**, depending on Aurora’s phase and urgency of open items.
    - Ad-hoc meetings may be convened if urgent security or architecture issues arise.
2. **Agenda**
    - The Chair sends out an agenda at least **3 business days** before each meeting, listing major discussion topics (e.g., new AEPs, unresolved action items, critical updates).
    - Agenda items may be proposed by any member but subject to Chair’s approval.
3. **Minutes and Records**
    - The Secretary (or designated note-taker) captures **key discussions, decisions, and action items**.
    - Minutes are shared in a central repository (e.g., Teams channel, GCdocs, or Microsoft Loop) within **2–3 business days** after the meeting.
    - For **security-sensitive** discussions, the Chair ensures minutes are stored in a **restricted-access location** and not circulated publicly until mitigations are in place.
4. **Participation and Attendance**
    - Each core member is expected to attend **at least 75%** of scheduled meetings per quarter.
    - If absent, members should review minutes and coordinate with the Chair or colleagues to stay up to date.
    - Observers may attend if invited, but do not vote or hold veto power.

---

## 6. Decision-Making and Veto Authority

1. **Consensus First**
    - The TAG strives to resolve issues via **consensus**. Most decisions should reflect agreement among attending core members.
    - If an informal consensus isn’t apparent, the Chair may call for a formal vote.
2. **Voting**
    - **Quorum** is a majority (>50%) of core voting members (including at least one Chair or Co-Chair).
    - A motion passes with a **two-thirds majority** of those present. Dissenting views should be recorded in the minutes to maintain transparency.
3. **Designated Veto Powers**
    - To avoid confusion, **1–3 designated Senior Technical Leads** (IT-04 or IT-05) may hold veto authority (explicitly assigned by the sponsor).
    - A veto can only be used when the proposed decision carries **critical risk** (e.g., severe security flaw, major architectural conflict).
    - If a veto is invoked, the proposal is **escalated** to the Director (Executive Sponsor) for final resolution. The rationale behind the veto must be documented.
4. **Escalation Path**
    - If the TAG cannot reach agreement or if a veto occurs, the Chair compiles a concise summary of the disagreement and rationale and forwards it to the Executive Sponsor.
    - The sponsor (or relevant governance body) may then decide, request more information, or direct an alternate path forward (e.g., external expert review).

---

## 7. Handling Security and Sensitive Disclosures

1. **Private Disclosure Approach**
    - If an architectural change **exposes a security vulnerability** similar to a zero-day, initial discussions happen in a **secure, private setting** (restricted GCdocs folder, dedicated restricted Teams channel, etc.) to avoid publicizing the vulnerability before it’s mitigated.
    - The Chair and relevant security leads coordinate with SSC Cybersecurity or relevant GoC security offices as needed.
2. **Timely Patching and Communication**
    - The TAG works to ensure vulnerabilities are addressed promptly.
    - Broader announcement or open documentation occurs **only after** sufficient mitigation is in place, following the principle of responsibly disclosing security issues.
3. **Record-Keeping**
    - Sensitive security items are documented in restricted logs, with non-sensitive summaries captured in general minutes to maintain accountability without jeopardizing security.
    - The Chair ensures compliance with GoC privacy and security regulations (e.g., Protected B/Secret classification where applicable).

---

## 8. Architectural Enhancement Proposals (AEPs)

1. **Proposal Submission**
    - Major changes or new solutions require an **AEP**. Submitters (any TAG member or project stakeholder) fill out the standard AEP template detailing scope, rationale, risks, pros/cons, etc.
2. **Review Process**
    - The TAG reviews the AEP, possibly over multiple meetings, providing feedback and recommended adjustments.
    - Once the AEP is **accepted** by consensus (or via formal vote), it becomes an official advisory recommendation for Aurora.
3. **Location and Access**
    - By default, AEPs are stored **internally** (e.g., in GCdocs, SharePoint, or an internal Git repository).
    - If there’s interest in publishing externally (e.g., GitHub), the TAG must confirm that **no security or proprietary constraints** are violated (in line with the private disclosure policy for vulnerabilities).
4. **Follow-Up and Implementation**
    - Implementation teams reference the approved AEP for execution details.
    - The TAG monitors progress and addresses any issues or clarifications in subsequent meetings.

---

## 9. Conflict of Interest and Code of Conduct

1. **GoC Values and Ethics**
    - All members must adhere to the **Values and Ethics Code** for the Public Sector, ensuring impartiality and integrity.
    - If a proposal involves tools, vendors, or solutions where a member has a conflict of interest (e.g., prior association, personal stake), they must **declare it** and may recuse themselves from related decisions.
2. **Professional Conduct**
    - Members treat each other with respect and maintain a **collegial** environment. Constructive debate is encouraged; harassment or discrimination is not tolerated.
    - The Chair is responsible for fostering an inclusive, respectful atmosphere during meetings.
3. **Handling Disagreements**
    - Disagreements are handled through open discussion, with the Chair mediating if needed.
    - In persistent conflicts, matters escalate to the sponsor for guidance.

---

## 10. Membership Updates and Attendance Guidelines

1. **Appointment and Turnover**
    - The **Director / Sponsor** formally appoints core members based on technical expertise, role, and Aurora’s needs.
    - If a member leaves or changes roles, the Chair consults with the sponsor to appoint a replacement with equivalent expertise.
2. **Attendance Requirements**
    - Core members are expected to attend at least 75% of scheduled meetings each quarter.
    - Missing multiple consecutive meetings without valid reason can lead to re-evaluation of membership status.
3. **Review of Membership**
    - Annually (or at major project milestones), the sponsor and Chair review the membership roster to ensure the right mix of skill sets and each member’s continued engagement.
    - Additional members or specialized observers can be added if new competencies are required (e.g., advanced data analytics, enterprise security).
4. **Removal of Members**
    - By sponsor discretion or majority TAG consensus, a member not fulfilling responsibilities or violating code of conduct can be removed.
    - Any removal is documented, including reasons and next steps to fill the vacancy.

---

## 11. Documentation and Transparency

1. **Official Repository**
    - All final meeting minutes, decisions, and AEPs (minus sensitive security details) are stored in an internal repository (**GCdocs, SharePoint, or Teams**) for ease of reference and compliance.
    - **Official decision records will be stored in markdown within gccloudone, while internal documentation and discussions may be maintained in SharePoint or GCdocs as needed.**
    - A high-level summary of TAG recommendations or decisions can be shared with the broader Aurora team as needed.
2. **Records of Decision (RoD)**
    - The TAG maintains a **Decision Log** capturing date, context, and outcome for major architectural or policy decisions (including votes/vetoes).
    - Summaries of key decisions are appended to meeting minutes to ensure a clear audit trail.
3. **Version Control**
    - Documents like the Charter, membership list, AEPs, and guidelines are maintained with version history. Substantive changes require TAG review and sponsor sign-off.
4. **Public vs. Restricted**
    - Non-sensitive documents may be made available on an internal portal for broader staff awareness.
    - Security-sensitive or procurement-related documents remain **restricted** until disclosure is safe or policy permits release.

---

## 12. Charter Review and Amendments

1. **Approval of this Charter**
    - This Charter is effective once signed by the sponsoring **Director** (EX level) and the TAG Chair.
    - Any major amendments (e.g., changes in veto rules, membership structure) require the TAG’s input and sponsor approval.
2. **Annual Review**
    - The TAG reviews the Charter annually (or as needed) to ensure it remains aligned with Aurora’s evolving context, GoC directives, and new technology trends.
3. **Minor Adjustments**
    - Minor edits (e.g., clarifications, formatting) can be made by the Chair with notice to TAG members. All changes are tracked in the Charter’s revision history.

---

## Signatures

| **Role**               | **Name and Classification** | **Signature** | **Date** |
|------------------------|-----------------------------|---------------|----------|
| **Director (Sponsor)** |                             |               |          |
| **TAG Chair**          |                             |               |          |

---

## Revision History

| **Version** | **Date**   | **Summary of Changes**                 | **Approved By**        |
|-------------|------------|----------------------------------------|------------------------|
| 1.0         | 2025-04-15 | Initial issuance of Aurora TAG Charter | Director and TAG Chair |

## References

The following authoritative references have been used to inform the structure, governance, and best practices of the **Aurora Technical Advisory Group (TAG)**.

These resources include industry-leading open-source governance models, Government of Canada policies, and technical frameworks that align with Aurora’s mission.

## TAG Best Practices and Charters (CNCF / Industry)

- **CNCF Technical Advisory Group (TAG) – Governance and Charter:**

    [https://github.com/cncf/tag-security/blob/main/governance](https://github.com/cncf/tag-security/blob/main/governance/charter.md)

- **CNCF TAG Contributor Strategy and Decision-Making Guide:**

    [https://github.com/cncf/tag-contributor-strategy/blob/main/governance](https://github.com/cncf/tag-security/blob/main/governance/charter.md)

- **Kubernetes Enhancement Proposal (KEP) Process:**

    [https://github.com/kubernetes/enhancements/blob/master/keps/README.md](https://github.com/kubernetes/enhancements/blob/master/keps/README.md)

- **Kubernetes Community Governance Model:**

    [https://github.com/kubernetes/community/tree/master/committee-steering](https://github.com/kubernetes/community/tree/master/committee-steering)

- **Microsoft Open Source – Technical Steering Committee and Governance Models:**

    [https://opensource.microsoft.com/programs/governance/](https://opensource.microsoft.com/programs/governance)

- **Google Open Source – Governance Guidelines and Advisory Groups:**

    [https://opensource.google/documentation/policies/governance/](https://opensource.google/documentation/policies/governance/)

- **GitLab’s Governance (Open Source and Advisory Groups):**

    [https://about.gitlab.com/company/governance/](https://about.gitlab.com/company/governance/)

---

## Government of Canada – Treasury Board and SSC

- **Treasury Board Digital Standards and Governance:**

    [https://www.canada.ca/en/government/system/digital-government/governance.html](https://www.canada.ca/en/government/system/digital-government/governance.html)

- **Treasury Board Directive on Service and Digital (Critical for Governance):**

    [https://www.tbs-sct.canada.ca/pol/doc-eng.aspx?id=32601](https://www.tbs-sct.canada.ca/pol/doc/doc-eng.aspx?id=32601)

- **Government of Canada Cyber Security Event Management Plan:**

    [https://www.canada.ca/en/government/system/digital-government/cyber-security/government-canada-cyber-security-event-management-plan.html](https://www.canada.ca/en/government/system/digital-government/digital-government/cyber-security/government-canada-cyber-security-event-management-plan.html)

- **Canadian Centre for Cyber Security - Security Guidelines:**

    [https://cyber.gc.ca/en/guidance](https://cyber.gc.ca/en/guidance)

- **Shared Services Canada Digital Operations Strategic Plan:**

    [https://www.canada.ca/en/shared-services/corporate/publications/digital-operations-strategic-plan.html](https://www.canada.ca/en/shared-services/corporate/publications/digital-operations-strategic-plan.html)

---

## BC Government – Digital Standards and Guidelines

- **BC Government Digital Principles and Standards (ideal for government-aligned governance):**

    [https://digital.gov.bc.ca/standards-and-guides/](https://digital.gov.bc.ca/standards-and-guides/)

- **BC Digital Government Policies and Procedures:**

    [https://www2.gov.bc.ca/gov/content/governments/services-for-government/policies-procedures/digital-data](https://digital.gov.bc.ca/resources/policies-and-standards/)

---

## Additional Industry amd Community References:

- **AWS Cloud Architecture Best Practices:**

    [https://docs.aws.amazon.com/wellarchitected/latest/framework/welcome.html](https://docs.aws.amazon.com/wellarchitected/latest/framework/welcome.html)

- **Microsoft Technical Governance Model (internal/external communication and standards):**

    [https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/organize/cloud-center-of-excellence](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/organize/cloud-strategy)
