---
title: "À propos de nous"
date: 2026-08-11
draft: false
sidebar: false
translationKey: "about"
disableCharacterlimit: true
---

Aurora est une plateforme d'hébergement d'applications sécurisée et en libre-service, propulsée par une sélection soignée de technologies de la Cloud Native Computing Foundation (CNCF), qui permet aux concepteurs de solutions de créer et de déployer rapidement des solutions natives du cloud dans un environnement cohérent et bien gouverné. Construite par les ministères, pour les ministères, à travers le gouvernement du Canada et faisant partie de l'initiative GC Cloud One, elle simplifie l'exploitation d'environnements Kubernetes multilocataires à l'échelle de l'entreprise, permettant aux équipes de se concentrer sur la livraison d'applications plutôt que sur la construction et l'exploitation de plateformes.

Aurora est agnostique au cloud et fonctionne sur les services Kubernetes gérés offerts par les fournisseurs de services infonuagiques (FSI), notamment Azure Kubernetes Service (AKS), Amazon Elastic Kubernetes Service (EKS), Google Kubernetes Engine (GKE) et le Nuage privé du GC. Ce modèle délègue la gestion du cycle de vie du plan de contrôle au fournisseur, tandis qu'Aurora conserve le contrôle architectural sur la composition des clusters, la mise en réseau et les services de plateforme.

## Notre mission

Nous permettons des services numériques sécurisés, évolutifs et interopérables : pilotés par la communauté, guidés par les normes et fondés sur l'expérience opérationnelle.

Mettre en place un environnement Kubernetes de qualité production et conforme aux exigences de sécurité demande beaucoup de temps et une expertise spécialisée. Plutôt que de laisser chaque équipe concevoir, construire et exploiter son propre cluster et sa propre pile de plateforme, Aurora centralise cet effort dans une base partagée. Cela réduit le travail en double, comble les lacunes de sécurité et aide le gouvernement du Canada à avancer ensemble.

## Architecture de la plateforme

La plateforme est organisée en trois couches architecturales :

- **Cadre de déploiement.** L'outillage d'infrastructure en tant que code (IaC) et de configuration en tant que code (CaC) qui provisionne l'infrastructure infonuagique et réconcilie la configuration des clusters, définissant comment les clusters et leurs ressources de soutien sont créés et comment la configuration est livrée au moyen du GitOps.
- **Couche d'exécution de la plateforme.** Les clusters gérés et les composants de plateforme qui transforment un cluster Kubernetes brut en une plateforme d'hébergement gouvernée, alignée sur le profil Protégé B, intégrité moyenne, disponibilité moyenne (PBMM), offrant des capacités de mise en réseau, de sécurité, d'observabilité et de livraison.
- **Couche de services de plateforme.** Les capacités en libre-service exposées aux propriétaires de charges de travail : espaces de noms, flux de déploiement, journalisation, surveillance ainsi que des fonctionnalités avancées de mise en réseau et de sécurité.

## Pourquoi Aurora

Les propriétaires de charges de travail hébergées sur Aurora bénéficient de ce qui suit :

- **Une plateforme alignée sur le gouvernement du Canada**, conçue pour fonctionner selon le profil PBMM et pour satisfaire aux contrôles de sécurité associés.
- **Une sécurité appliquée du noyau jusqu'à la charge de travail.** Aurora combine la mise en réseau au niveau du noyau et l'application des règles à l'exécution (Cilium et Tetragon), le TLS mutuel du maillage de services (Istio) et les contrôles de politiques au moment de l'admission afin d'offrir une posture de confiance zéro par défaut.
- **La portabilité entre les environnements.** Les fondations à code source ouvert maintiennent la portabilité des charges de travail et réduisent la dépendance envers un fournisseur unique.
- **Un modèle opérationnel unifié.** Les activités du cycle de vie, telles que les mises à niveau de version, la surveillance, la sauvegarde et l'application des politiques, sont gérées de façon centralisée et cohérente à travers le parc, offrant aux propriétaires de charges de travail une base opérationnelle prévisible.

## Ce en quoi nous croyons

- **Ouvert par défaut.** Aurora est, et sera toujours, entièrement à code source ouvert. Nous construisons de façon ouverte et partageons notre travail avec la communauté.
- **Construit avec nos utilisateurs.** Nous façonnons la plateforme aux côtés des ministères qui l'utilisent, guidés par des groupes consultatifs techniques (TAG) dans des domaines comme l'architecture, la mise en réseau et la sécurité.
- **Investis dans l'expertise interne.** Nous développons et certifions les talents au sein du gouvernement du Canada, réduisant la dépendance envers les fournisseurs externes et bâtissant un savoir institutionnel durable.

## Qui nous sommes

Aurora est livrée par l'entremise de Services partagés Canada, en collaboration avec des concepteurs de solutions et des architectes de plateforme provenant de ministères de l'ensemble du gouvernement. Elle s'inspire de plateformes éprouvées du secteur public, notamment la plateforme DevOps du gouvernement de la Colombie-Britannique, la plateforme Cloud Native de Statistique Canada et la plateforme « Platform One » du Département de la Défense des États-Unis.

Pour en apprendre davantage sur la vision, le raisonnement et la feuille de route derrière la plateforme, consultez notre <gcds-link href="{{< relref "/proposition" >}}">Proposition stratégique</gcds-link>, ou découvrez comment <gcds-link href="{{< relref "/impliquez-vous" >}}">vous impliquer</gcds-link>.
