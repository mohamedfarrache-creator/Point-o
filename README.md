# Pointéo

Application Android Flutter de pointage, suivi des heures supplémentaires et estimation de paie locale.

## Paie

L’onglet **Paie** génère un bulletin estimatif pour la période d’entreprise : du **26 du mois M-1 au 25 du mois M**. Cette règle est encapsulée dans `PayPeriod.forMonth` et remplace les agrégations précédemment basées sur le mois calendaire, y compris le récapitulatif du calendrier.

Les paramètres de salaire sont accessibles dans **Profil > Paramètres salaire** et sauvegardés dans `SharedPreferences` : taux horaire (30,82 MAD par défaut), CNSS, plafond CNSS, CNSS-IPE, mutuelle, CIMR, acompte et COS.

Le brut sépare les heures normales, supplémentaires (majorées à 150 %) et les heures effectuées aux jours fériés fixes (majorées à 200 %). CNSS et CNSS-IPE sont calculées sur un brut plafonné ; mutuelle et CIMR sur le brut total. L’IR est estimé à partir de tranches progressives annualisées, puis ramené au mois.

> Attention : les taux, plafonds, jours fériés mobiles et barèmes fiscaux doivent être validés par le service paie avant toute utilisation comme bulletin officiel.
