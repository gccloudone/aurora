---
title: "Aurore"
description: "Aurora est une plateforme d’hébergement d’applications sécurisée et en libre-service, propulsée par une sélection soignée de technologies de la Cloud Native Computing Foundation (CNCF), qui permet aux concepteurs de solutions de créer et de déployer rapidement des solutions natives du cloud dans un environnement cohérent et bien gouverné."
date: 2026-08-11
draft: false
translationKey: homePage
---

## Commencez à évaluer la plateforme

<!-- markdownlint-disable MD033 -->

<article class="py-500 bg-primary text-light bg-full-width">
  <gcds-grid tag="ul" columns="1fr" columns-tablet="1fr 1fr" gap="450" class="hydrated">
    <li class="list-none md:mb-0 mb-500">
      <h3 class="mb-400">Chartes de la plateforme</h3>
      <p class="mb-400">Aurora est et restera toujours entièrement à code source ouvert. Explorez les chartes Helm qui définissent la plateforme, découvrez le code et contribuez à la façonner. Ces chartes gèrent l’état continu de la plateforme au moyen du GitOps.</p>
      <gcds-link href="https://github.com/gccloudone-aurora/aurora-platform-charts" class="hydrated" variant="light">Voir les chartes de la plateforme</gcds-link>
    </li>
    <li class="list-none">
      <h3 class="mb-400">Bootstrap Terraform</h3>
      <p class="mb-400">Nécessaire uniquement en l’absence d’un cluster de gestion préexistant. Cette étape en amorce un, en installant Argo CD et en déployant la plateforme Aurora, après quoi les chartes de la plateforme prennent en charge le contrôle continu.</p>
      <gcds-link href="https://github.com/gccloudone-aurora/bootstrap-terraform" class="hydrated" variant="light">Voir Bootstrap Terraform</gcds-link>
    </li>
  </gcds-grid>
</article>

<article class="py-450">
  <h2 class="mb-400">Conçue pour répondre à vos besoins opérationnels.</h2>
  <p class="mb-500">Explorez notre architecture proposée et <gcds-link href="/fr/contact" class="hydrated">partagez vos commentaires</gcds-link>.</p>
  <gcds-grid tag="ul" columns="1fr" columns-tablet="1fr 1fr" columns-desktop="1fr 1fr 1fr" gap="450" class="hydrated">
    <li class="list-none">
      <h3 class="mb-400">Composantes</h3>
      <p class="mb-400">Découvrez les composantes modulaires qui assurent les fonctionnalités de base de la plateforme.</p>
      <p class="mb-400">Outils CNCF comme Cilium pour la sécurité réseau avancée et l’observabilité, et Argo CD pour la livraison continue basée sur GitOps.</p>
      <gcds-link href="/fr/components/" class="hydrated">Voir les composantes</gcds-link>
    </li>
    <li class="list-none">
      <h3 class="mb-400">Architecture</h3>
      <p class="mb-400">Consultez le plan architectural de la plateforme qui décrit les principes de conception, l’architecture système et les décisions encodées.</p>
      <p class="mb-400">Cela inclut la gestion de l’infrastructure, le modèle zéro confiance, l’isolation des charges de travail, le renforcement de la sécurité, la gestion multi-locataires et le DevSecOps.</p>
      <gcds-link href="/fr/architecture/introduction/azure/" class="hydrated">Voir le plan architectural</gcds-link>
    </li>
    <li class="list-none">
      <h3 class="mb-400">Conseil technique</h3>
      <p class="mb-400">Contribuez à l’avenir d’Aurora en vous joignant à notre groupe consultatif technique.</p>
      <p class="mb-400">Nous invitons les concepteurs de solutions et les architectes de plateformes à partager leurs idées et à contribuer à l’évolution de l’architecture, des outils et des services natifs du cloud d’Aurora.</p>
      <gcds-link href="/fr/technical-advisory-group/" class="hydrated">Voir la charte du groupe</gcds-link>
    </li>
  </gcds-grid>
</article>

<article class="py-500 bg-light bg-full-width">
  <h2 class="mb-400">Quoi de neuf</h2>
  <gcds-grid tag="ul" columns="1fr" columns-tablet="1fr 1fr" gap="450" class="hydrated">
    <li class="list-none bg-white p-450 b-radius-md">
      <h3 class="mb-400">
        <gcds-link href="/fr/impliquez-vous" class="hydrated">Contribuez à l’avenir</gcds-link>
      </h3>
      <p>Découvrez les travaux en cours et ajoutez votre expertise.</p>
    </li>
    <li class="list-none bg-white px-250 py-450 b-radius-md">
      <h3 class="mb-400">
        <gcds-link external="" href="https://github.com/gccloudone-aurora/aurora-platform-charts/blob/main/CHANGELOG.md" class="hydrated">Notes de version</gcds-link>
      </h3>
      <p>Restez à jour avec les dernières nouveautés.</p>
    </li>
  </gcds-grid>
</article>

<!-- markdownlint-enable MD033 -->

{{< components >}}

{{< feedback
heading="Aidez-nous à nous améliorer"
paragraph="Avez-vous des questions, des suggestions ou des idées d'amélioration ? Partagez vos commentaires pour nous aider à raffiner Aurora et mieux répondre à vos besoins."
buttonText="Donnez votre avis"
buttonLink="/fr/contact"
>}}
