---
title: "Proposition Stratégique"
date: 2024-10-21
draft: false
sidebar: false
showToc: true
translationKey: "proposal"
---

<gcds-alert alert-role="danger" container="full" heading="Avis de traduction" hide-close-btn="true" hide-role-icon="false" is-fixed="false" class="hydrated mb-400">
<gcds-text>Veuillez noter que ce document est actuellement en cours de développement actif et pourrait être sujet à des révisions. Une fois terminé, il sera entièrement traduit en français et mis à disposition dans sa version finale.</gcds-text>
</gcds-alert>

## Aperçu du projet

Aurora représente l'état futur possible d'une plate-forme unifiée d'hébergement d'applications pour le gouvernement du Canada (GC). La plateforme intègre des offres Kubernetes en open source (OSS) sur des services cloud gérés et des offres Kubernetes propriétaires (dans certains aspects) livrées en tant que plateforme en tant que service (PaaS), fournissant une solution d'hébergement standardisée, évolutive et sécurisée. L'objectif d'Aurora est d'éliminer la fragmentation qui résulte de la gestion de sa propre plateforme par chaque département, assurant ainsi que le gouvernement du Canada opère avec une cohérence en matière de conformité, de sécurité et d'efficacité opérationnelle.

En se concentrant sur un modèle de gouvernance centralisée, Aurora s'alignera sur le modèle d'exploitation Cloud One du GC, promouvant une approche unifiée pour l'intégration, le support et la sécurité. S'inspirant d'initiatives réussies comme la plateforme DevOps du gouvernement de Colombie-Britannique, la plateforme Cloud Native de Statistique Canada et la plateforme "Platform One" du Département de la Défense américain, Aurora cherche à donner aux départements à la fois flexibilité et standardisation. La plateforme fournira aux ministères une boîte à outils complète et des modèles de logiciels pré-approuvés, leur permettant d'optimiser leurs processus de développement tout en accélérant l'innovation.

Aurora se concentrera également sur le développement d'une expertise interne, en créant des équipes équipées des compétences et des certifications nécessaires pour gérer la plateforme en interne, réduisant ainsi la dépendance à l'égard des fournisseurs externes. Cette approche positionne Aurora comme la solution à long terme pour l'hébergement d'applications à travers le gouvernement du Canada, permettant aux ministères de se concentrer sur la prestation de services publics de haute qualité sans le fardeau de la gestion d'environnements fragmentés et en silos.

## Raisonnement

Alors que les technologies natives du cloud deviennent de plus en plus courantes au sein du gouvernement du Canada, le déploiement indépendant des environnements Kubernetes par les ministères individuels, que ce soit par le biais de services cloud gérés ou de plates-formes propriétaires, est peut-être devenu intenable, sinon coûteux. Cette approche fragmentée conduit à des inefficacités, une conformité incohérente, et des lacunes potentielles de sécurité à travers les départements. Alors que certains ministères ont mis en place leurs propres plates-formes Kubernetes, beaucoup dépendent souvent de solutions propriétaires et sollicitent l'aide des fournisseurs externes pour le support, augmentant ainsi les coûts à long terme et limitant le développement de l'expertise interne nécessaire pour construire et maintenir ces plates-formes.

Certains des ministères qui ont leurs propres environnements Kubernetes (au moins dans une certaine mesure) incluent :

* Statistique Canada
* Agence de la santé publique du Canada
* Agence du revenu du Canada
* Emploi et Développement social Canada
* Ministère de la Défense nationale
* Ministère des Pêches et des Océans
* Et beaucoup d'autres...

Pendant plus de deux décennies, les organisations logicielles ont été confrontées au défi de gérer l'infrastructure partagée, le code et les outils à travers plusieurs équipes. Des équipes centralisées ont souvent été créées pour gérer ces demandes partagées, mais elles ont fréquemment rencontré des problèmes tels que le déphasage par rapport aux besoins de leurs utilisateurs, le développement de solutions trop complexes ou instables, ou le manque de flexibilité. D'un autre côté, la décentralisation complète et directe des outils de cloud et du logiciel open source a exposé ceux-ci à une complexité opérationnelle, conduisant à des inefficacités et à la nécessité d'ingénieurs de fiabilité ou de spécialistes DevOps coûteux.

Cependant, Aurora adopte une approche différente en se concentrant sur la construction d'une plateforme qui tire le meilleur des modèles centralisés et décentralisés. Aurora veille à ce que le talent d'ingénierie interne soit développé au sein du gouvernement du Canada, réduisant la dépendance à l'égard des consultants externes. Les équipes au sein d'Aurora seront compétentes à la fois sur les systèmes Kubernetes open-source et les environnements PaaS propriétaires, équipés de certifications telles que Certified Kubernetes Administrator (CKA), Certified Kubernetes Security Specialist (CKS), et Certified Kubernetes Application Developer (CKAD). Cette expertise en interne assurera un support solide à la fois au niveau de la plate-forme et au niveau de l'application, tout en maintenant stabilité, évolutivité et sécurité.

En établissant un standard et des normes partagés à travers les ministères, Aurora s'assurera que un large ensemble de professionnels formés est disponible pour supporter tous les ministères. Cette approche non seulement bénéficie aux ministères en leur donnant accès à des architectes et employés compétents, mais elle stimule également les employés gouvernementaux à travailler à travers les ministères, favoriser la collaboration et la flexibilité. Avec une formation, des normes et une expertise cohérentes, les professionnels au sein d'Aurora peuvent aider de multiples départements, s'assurer que le gouvernement du Canada avance ensemble dans ses efforts de modernisation.

Aurora réussit en créant une plateforme partagée qui permet aux équipes d'applications de se construire sur une base stable et flexible. La plateforme privilégie la collaboration avec ses utilisateurs, s'assurant que les ministères à travers le gouvernement ont les outils et le support dont ils ont besoin pour innover de manière efficace et sécurisée. Cette approche favorise l'efficacité, les économies de coûts et l'innovation tout en réduisant la complexité opérationnelle. En s'appuyant sur l'expertise existante au sein des ministères, Aurora fournit une base solide pour l'expansion de la plateforme à travers le gouvernement du Canada.

## Parties prenantes clés

**Andrew Sinkinson** : Directeur général des services d'hébergement en nuage chez Services partagés Canada, responsable de la supervision de l'alignement stratégique d'Aurora, parmi de nombreux autres projets, avec l'initiative GC Cloud One.

**Serge Leblanc** : Directeur des services d'hébergement en nuage chez Services partagés Canada, responsable de la gestion des opérations quotidiennes à travers plusieurs initiatives cloud, incluant mais pas limité à la plate-forme Aurora.

## Vision du projet

L'objectif d'Aurora est de s'établir comme une plateforme fondamentale pour l'hébergement d'applications à travers le gouvernement du Canada, permettant une intégration transparente entre divers environnements natifs du cloud. En s'inspirant de plateformes réussies comme celles du gouvernement de la Colombie-Britannique, Statistique Canada et Platform One, Aurora agira en tant que plateforme DevSecOps centralisée, offrant aux ministères à la fois l'outillage et les modèles de logiciels pré-approuvés nécessaires pour accélérer l'innovation et rationaliser les processus de développement.

Au cœur de cette initiative se trouve l'ingénierie de plateforme, une discipline conçue pour répondre à la complexité croissante des environnements logiciels modernes. L'ingénierie de plateforme va au-delà de la simple attribution d'une équipe pour résoudre des défis techniques, elle nécessite une stratégie globale qui intègre la gestion de produits, le développement de logiciels et l'excellence opérationnelle, tout en assurant une compréhension profonde de l'infrastructure plus large. Les équipes doivent non seulement résoudre des problèmes techniques, mais aussi adopter l'ensemble du cycle de vie du produit, assurant que les solutions sont évolutives, fiables et conçues pour une maturité opérationnelle à long terme.

En standardisant les outils, l'infrastructure et les processus de travail, Aurora simplifie le développement, réduit la charge cognitive pour les développeurs et favorise la collaboration entre les ministères. Cette clarté d'approche garantit que la plateforme livre sur sa promesse d'agilité, de fiabilité et de sécurité à travers tous les ministères, tout en restant suffisamment flexible pour répondre aux besoins uniques de chaque ministère.

Avec son fondation sécurisée et conforme - incluant la sécurité intégrée zero trust, la sécurité en tant que code et l'automatisation de la conformité - Aurora donne aux ministères le pouvoir d'adopter en toute confiance les outils modernes du cloud et de livrer des applications à grande échelle et critiques pour la mission. Aurora n'est pas seulement l'épine dorsale technique de l'innovation, elle est conçue pour évoluer parallèlement aux besoins toujours changeants du gouvernement du Canada, soutenant la croissance et assurant une maturité opérationnelle à long terme.

## Objectifs primaires

1. **Unifier les environnements open source et propriétaires** à travers les ministères du GC pour éliminer la fragmentation tout en fournissant des options d'hébergement flexibles et évolutives qui s'adaptent aux besoins spécifiques de chaque ministère.
2. **Standardiser les processus d'intégration** en alignement avec le modèle d'exploitation GC Cloud One, assurant une intégration transparente et une adoption accélérée à travers les ministères, tout en améliorant la satisfaction des utilisateurs et l'efficacité opérationnelle.
3. **Développer une architecture cloud-native orientée vers l'avenir** qui intègre la connectivité sur site (SCED), la sécurité zero trust et les modèles de défense en profondeur, assurant une durabilité à long terme, la conformité de sécurité et l'adaptabilité.
4. **Construire une structure de support centralisée** avec une équipe unifiée dédiée à la fois aux plates-formes Kubernetes propriétaires et OSS, renforcée par des groupes d'intérêt spéciaux (SIG) dans des domaines clés comme l'architecture, le réseau, et la sécurité pour stimuler la collaboration et l'innovation à travers les ministères.

## Contraintes stratégiques

1. **La neutralité du fournisseur** en relation avec les décisions sur les fournisseurs de cloud restera en suspens jusqu'à ce que les marchés publics à l'échelle du gouvernement du Canada soient finalisés.
2. **Intégration des environnements open-source et propriétaires** où les offres Kubernetes open-source sur les services cloud gérés et les offres Kubernetes propriétaires seront alignées sur des normes communes, assurant l'interopérabilité à travers les plates-formes. Cette approche répond aux diverses exigences des différents ministères tout en maintenant une intégration, une compatibilité et une cohérence opérationnelle sans faille.
3. **Structure de gouvernance** où un modèle de gouvernance solide doit être établi dès le début, incorporant des stratégies éprouvées du gouvernement de la Colombie-Britannique, des Services numériques canadiens et de Platform One pour façonner l'organisation d'équipe et favoriser la collaboration.
4. **Conformité SCED (Secure Cloud Enablement and Defence)** où toutes les connections sur site et cloud privé doivent respecter les exigences SCED pour assurer un accès sécurisé aux services cloud.

## Risques et atténuation

L'un des défis clés dans la construction et l'exploitation d'une plateforme comme Aurora est d'équilibrer la flexibilité avec la gouvernance. Ci-dessous sont présentés certains des risques identifiés ainsi que certaines mitigations proposées :

**Équipes de plateforme sans le pouvoir de dire "non"**

Risque : Lorsque les équipes de plateforme n'ont pas l'autorité pour prendre des décisions critiques, notamment la capacité de dire "non", cela peut conduire à une complexité accrue, un élargissement du périmètre et des inefficacités. Sans cette autorité, la plateforme risque de devenir trop personnalisée, encombrée ou mal alignée sur ses objectifs principaux, ralentissant ainsi le développement et augmentant le fardeau à la fois sur l'équipe de la plateforme et ses utilisateurs.

Atténuation : Les équipes de plateforme doivent avoir le pouvoir politique de définir leurs utilisateurs idéaux et de prendre des décisions sur la meilleure façon de résoudre leurs problèmes. Cela inclut la capacité de minimiser le choix si nécessaire pour simplifier la plateforme, réduire la charge cognitive et accélérer le développement. Donner le pouvoir à ces équipes de se concentrer sur les fonctionnalités principales assurera la durabilité et l'efficacité à long terme.

**Besoins des clients partenaires pour un contrôle centralisé**

Risque : Les clients partenaires, tels que les équipes de cybersécurité ou même de FinOps, nécessitent un contrôle et un reporting centralisés pour assurer la conformité, la sécurité et l'efficacité financière. Un échec à répondre à ces besoins pourrait conduit à la fragmentation, aux inefficacités, et à un manque de confiance en la gouvernance de la plateforme.

Atténuation : Aurora doit fournir des outils standardisés et des processus à travers les ministères pour répondre aux besoins de contrôle centralisé. En s'assurant que toutes les équipes utilisent les mêmes services de plateforme de base, Aurora peut simplifier le reporting, la conformité, et la gestion de la sécurité.

**Manque de maturité opérationnelle en ingénierie de plateforme**

Risque : L'ingénierie de plateforme est intrinsèquement difficile, et sans une maturité organisationnelle appropriée, les équipes risquent de construire des solutions qui manquent de valeur à long terme, de durabilité et de préparation opérationnelle.

Atténuation : Une ingénierie de plateforme réussie nécessite un déplacement vers une maturité organisationnelle, où les équipes construisent avec une intention claire et alignent leurs efforts avec les besoins réels des utilisateurs et les objectifs opérationnels. La structure de gouvernance d'Aurora doit imposer ces principes, assurant que chaque décision technique est soutenue par une stratégie opérationnelle claire.

## Répondre aux préoccupations

À mesure qu'Aurora grandit et évolue, des questions sur sa portée, sa vitesse et son alignement avec d'autres initiatives cloud sont naturelles.

**Pourquoi l'organisation de la plateforme est-elle si grande lorsque nous avons également [insérer le cloud] ?**

La taille d'Aurora reflète son rôle dans la fourniture d'une plate-forme standardisée, évolutive et sécurisée qui s'étend sur plusieurs ministères. Aurora intègre plusieurs environnements natifs du cloud, équilibrant des besoins divers avec une gouvernance et un support centralisés pour des stratégies de cloud hybrides.

**Pourquoi notre plateforme a-t-elle tout cet effectif mais avance toujours si lentement ?**

L'ingénierie de plateforme est un domaine complexe et en constante évolution. Alors que le développement initial peut sembler lent en raison du travail fondamental nécessaire, les bénéfices à long terme comprennent une agilité accrue, une meilleure allocation des ressources, et une réduction de la charge cognitive pour les développeurs. En construisant une plateforme stable et standardisée, Aurora vise à accélérer le développement à long terme, mais cela nécessite un investissement dans la maturité opérationnelle.

**Pourquoi notre adoption récente de [cloud public/SRE/expérience développeur] n'a-t-elle pas résolu cela ?**

L'adoption d'outils et de méthodologies comme le cloud public, le SRE, ou l'amélioration de l'expérience développeur peut résoudre des points de douleur spécifiques mais ne sont pas des solutions miracles. 

L'ingénierie de plateforme va au-delà des outils ; elle consiste en un alignement organisationnel, une standardisation, et la création d'un environnement sécurisé, flexible et interopérable pour tous les clients partenaires/départements. L'accent d'Aurora est mis sur l'intégration de ces éléments dans une plate-forme cohérente qui soutient l'innovation et répond aux besoins uniques du gouvernement du Canada.
