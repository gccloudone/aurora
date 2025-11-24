---
title: "Onboarding"
date: 2025-11-15
draft: false
showToc: true
translationKey: "onboarding"
disableCharacterlimit: true
---

Ce document décrit comment vous intégrer au cluster AKS géré par Aurora.

Il est rédigé comme une source d’information unique. Toutes les valeurs sensibles ou propres à un ministère vous seront fournies séparément par un canal sécurisé et chiffré. Ce document utilise des espaces réservés (placeholders) pour indiquer où ces valeurs doivent être insérées.

## Avant de commencer

Vous aurez besoin des valeurs propres à votre cluster, qui vous auront été communiquées par un canal sécurisé.
Insérez ces valeurs à l’endroit indiqué par les espaces réservés dans ce document.

## Prérequis

Installez les outils suivants avant de commencer :

- `az`: Azure CLI pour l’authentification et la gestion des ressources Azure.
- `kubectl`: Outil CLI pour interagir avec le cluster Kubernetes.
- `k9s`: Optionnel, mais recommandé. Interface terminal pour explorer les ressources du cluster.
- `freelens`: Optionnel, mais recommandé. Client graphique pour visualiser et gérer les clusters Kubernetes.

## Ouvrir une session dans Azure

Exécutez la commande suivante pour vous authentifier auprès d’Azure :

```bash
az login --use-device-code
```

Une fenêtre de navigateur s’ouvrira, où vous pourrez entrer le code d’accès et compléter l’authentification.

Si votre ministère utilise des chemins d’accès gérés par SPC, ouvrez une session à partir d’un environnement approuvé.
SPC prend actuellement en charge :

- JumpBox
- Azure Virtual Desktop (AVD)
- Chemins d’accès authentifiés F5

Ces environnements offrent le pairage réseau et le routage requis pour Aurora.

Vérifiez l’abonnement actif :

```bash
# Affiche le nom de l’abonnement actuellement sélectionné
az account show --query "name"

# Définissez l’abonnement qui vous a été transmis de façon sécurisée
az account set --subscription "<INSERT_SUBSCRIPTION_NAME>"
```

### Pourquoi ces chemins d’accès sont requis

Les clusters Aurora fonctionnent dans la zone d’atterrissage sécurisée d’entreprise (ESLZ) de SPC.
L’accès au plan de contrôle et aux groupes de nœuds est restreint par des règles de pare-feu, des points de terminaison privés et du peering VNet.

Les chemins d’accès approuvés assurent :

- Un routage sortant approprié vers les points de terminaison de gestion Azure
- Des règles de pare-feu permettant l’accès aux API Kubernetes
- Des contrôles cohérents d’identité et de journalisation
- Une surface opérationnelle contrôlée et traçable

L’utilisation d’AVD, d’un JumpBox ou d’un chemin d’accès authentifié F5 garantit que votre session se situe à l’intérieur du périmètre réseau de confiance avec la connectivité appropriée.

## Obtenir les informations d’accès AKS

Utilisez la commande suivante pour configurer `kubectl` afin de vous connecter à votre cluster AKS Aurora assigné.
Insérez le groupe de ressources et le nom du cluster qui vous ont été fournis de façon sécurisée.

```bash
az aks get-credentials \
  --resource-group "<INSERT_CLUSTER_RESOURCE_GROUP>" \
  --name "<INSERT_CLUSTER_NAME>"
```

Cette commande ajoute la configuration du cluster à votre fichier `kubeconfig`.

Pour faciliter la gestion lorsque vous travaillez avec plusieurs clusters ou espaces de noms, envisagez d’installer :

- `kubectx` pour changer de contexte Kubernetes
- `kubens` pour changer d’espace de noms Kubernetes

### Valider votre connexion

Exécutez les commandes suivantes pour confirmer que votre connexion au cluster fonctionne :

```bash
kubectl get nodes
kubectl get ns
```

Si les deux commandes retournent des résultats sans erreurs, votre intégration est complétée avec succès.

## ArgoCD dans Aurora

Aurora utilise ArgoCD pour gérer toute la configuration et les charges de travail déployées dans la zone d’atterrissage sécurisée d’entreprise (ESLZ).

Chaque cluster de gestion Aurora (non production et production) contient **deux instances ArgoCD**, chacune ayant un rôle distinct dans le cycle de vie de la plateforme.

Les deux instances ArgoCD référencent le dépôt GitOps privé de votre ministère, suivant la convention de nommage Aurora :

```bash
https://github.com/gccloudone-aurora/project-<INSERT_PROJECT>
```

### Instance de gestion de la plateforme

L’instance de gestion de la plateforme sert à installer et maintenir la plateforme Aurora elle-même.

Cela inclut les modules complémentaires Kubernetes, les services horizontaux, les contrôleurs, la configuration réseau, la posture de sécurité et d’autres composants fondamentaux.

```bash
https://aur.aurora.<INSERT_MGMT_DEV_PLATFORM_ARGOCD> (Développement)
https://aur.aurora.<INSERT_MGMT_PROD_PLATFORM_ARGOCD> (Production)
```

La configuration de la plateforme provient du dépôt privé suivant :

- https://github.com/gccloudone-aurora/project-aurora-mgmt

Pour un exemple de structure et d’approche, consultez le modèle public :

- https://github.com/gccloudone-aurora/project-aurora-template

Les ministères ne déploient **pas** de charges de travail à partir de cette instance.

Elle est entièrement gérée par l’équipe Aurora pour assurer une exploitation uniforme, sécurisée et gouvernée de tous les clusters Aurora.

### Instance Solution Builder

L’instance Solution Builder est dédiée aux charges de travail propres à chaque ministère.

C’est ici que les concepteurs de solutions déploient et gèrent les composants requis dans leurs clusters AKS hébergés sur Aurora.

```bash
https://sol.aurora.<INSERT_MGMT_DEV_SOLUTION_ARGOCD> (Développement)
https://sol.aurora.<INSERT_MGMT_PROD_SOLUTION_ARGOCD> (Production)
```

La configuration des solutions provient du dépôt privé suivant :

- https://github.com/gccloudone-aurora/project-aurora-mgmt

Vous pouvez consulter la structure de référence dans le modèle public :

- https://github.com/gccloudone-aurora/project-aurora-template

## Soutien

Si vous rencontrez un problème durant l’intégration ou si vous avez besoin d’aide à n’importe quelle étape, plusieurs options de soutien sont disponibles.

### Documentation de la plateforme Aurora

Un aperçu de l’architecture de la plateforme Aurora est disponible ici :

- https://aurora.gccloudone.alpha.canada.ca/architecture/introduction/azure/

### Communiquer avec l’équipe Aurora

Pour des questions générales ou du soutien lié à l’intégration, communiquez avec l’équipe GC Cloud One Aurora par courriel :

- **aurora-aurore@ssc-spc.gc.ca**

Vous pouvez aussi nous joindre via notre canal Microsoft Teams :

- [**Canal de soutien Aurora sur Microsoft Teams**](https://teams.microsoft.com/l/channel/19%3AXLC7f7eMIGf8yEe8JqJ5q_j-G-0Rr-MjJTjsoCtOTWs1%40thread.tacv2/Support?groupId=856cec3e-dac1-473a-abe8-0a810d2a5e0a&tenantId=d05bc)

### Signalement d’incidents et de problèmes

Pour les problèmes opérationnels, interruptions ou incidents, veuillez soumettre un billet dans l’outil ITSM de SPC (Remedy) :

- https://smartit.prod.global.gc.ca/smartit/app/#/create/incident

Sélectionnez le groupe de soutien :

- **20814 GCCO Aurora/Aurore SIUGC**

Le soutien direct aux clients est offert du lundi au vendredi, de **9 h à 17 h (HE)**.
