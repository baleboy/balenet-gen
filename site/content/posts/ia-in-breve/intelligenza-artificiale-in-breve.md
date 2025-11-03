---
title:  (In Italian) L'intelligenza artificiale in breve
date:  2024-05-09
topics: ai
---

Mi è stato chiesto un link a un articolo breve che spiegasse l’intelligenza artificiale in maniera non troppo superficiale. Non avendolo trovato, ho deciso di scriverlo io.

Con "Intelligenza artificiale" (IA) si intende la capacità di un computer di svolgere compiti tipicamente considerati prerogativa degli esseri umani. Guidare un'automobile, interpretare testi, riconoscere immagini e parlato, e cosí via. Al momento, chiamarla intelligenza è offensivo se con intelligenza si intende anche la creatività e l’intuito, ma in futuro questo potrebbe non essere più il caso.

Quando si parla di IA oggi si intende per lo più l’apprendimento meccanico (*machine learning*), cioè una serie di algoritmi che vengono programmati non con istruzioni successive, ma sulla base di esempi. L’intelligenza sta nel fatto che con un numero di esempi sufficiente, l’algoritmo riesce a generalizzare e produrre risultati corretti anche con ingressi mai visti prima.

Il principio di base è quello della regressione: dati un certo numero di campioni e un certo tipo di funzione, si cercano i parametri della funzione che minimizzano la differenza tra la funzione e i campioni, e si usa poi la funzione per generare valori al di fuori dei campioni.

![Image.tiff](https://realpython.com/cdn-cgi/image/width=600,format=auto/https://files.realpython.com/media/poly-reg.5790f47603d8.png)

Un particolare tipo di funzione di regressione è la rete neurale, ispirata a osservazioni fatte sul cervello umano. Non è però una riproduzione elettronica del cervello né fornisce nuove spiegazioni su come funzioni.

Una moderna rete neurale è caratterizzata da avere moltissime (migliaia, milioni) variabili di ingresso e moltissimi (miliardi) parametri, detti pesi, e una funzione di costo che viene minimizzata variando i pesi tramite iterazioni successive su un grande numero di campioni. Questo processo iterativo si chiama “apprendimento”.  L’apprendimento puo’ essere “supervisionato” (gli esempi includono sia ingressi che uscite) o “non supervisionato” (gli esempi includono solo ingressi e la rete neurale arriva da sola a un meccanismo di classificazione).

Le reti neurali hanno avuto molto successo nel riconoscimento di immagini, un campo tradizionalmente difficile per l’informatica ma estremamente semplice per un essere umano (un altro colpo al termine “intelligenza”). Invece di cercare un algoritmo che estragga le caratteristiche da una immagine, si addestra una rete neurale con un gran numero di immagini di esempio specificandone il contenuto (“qui c’e’un gatto” o “qui c’e una persona”). Non sempre funziona, come in questa immagine in cui molte reti neurali non riescono a distingure tra un Chihuahua e un muffin.

![Image.tiff](https://cdn-media-1.freecodecamp.org/images/C9OQH-2w3g-1Ayj08mjYLwlpI46QAbxgtyqa)

Le diverse configurazioni di reti neurali si chiamano modelli. Una categoria di modelli che hanno avuto molto successo, ma che sono computazionalmente molto complessi, è quella delle reti neurali "profonde" (*deep neural networks* e l’associato *deep learning*) in cui la rete neurale è organizzata in strati successivi. Trovare il modello giusto di rete neurale per un particolare tipo di problema è un’arte basata su tentativi e intuizioni. Questo vuole dire anche che è praticamente impossible garantire che il risultato di una rete neurale sarà sempre corretto.

![Image.tiff](https://imgs.xkcd.com/comics/machine_learning.png)

L’intelligenza artificiale esiste dagli anni 50 e le reti neurali dagli anni 80. Perchè se ne parla tanto solo adesso? Per due motivi: la quantità di dati disponibili con l’avvento dell’informazione digitale, e gli avanzamenti nella velocità di elaborazione di tali informazioni. Questo consente di creare reti neurali molto complesse e di avere un quantitativo di dati sufficiente ad addestrarle, e di farlo in tempi accettabili.

Recentemente sono emersi i modelli "generativi", in grado di creare informazioni complesse, come testi, immagini e video, partendo da un esempio minimo (una breve descrizione o un’immagine). Per esempio si può chiedere di scrivere una poesia sul viaggio spaziale nello stile di Leopardi, creare un’immagine di un maiale come se lo avesse dipinto Van Gogh o un video di una persona che balla basandosi su una sua foto. Questi modelli vengono addestrati usando enormi quantità di dati raccolti da internet. Sono estremamente complicati e addestrarli richiede tempo e un grande numero di potentissimi e costosi elaboratori. Per questo la loro “conoscenza” si ferma ad una certa data, la data dell’ultimo addestramento, e tra un addestramento e l’altro possono passare mesi.

A seconda dei dati usati per addestrarla, l'IA puo' mostrare una certa "parzialità" (*bias*). Per esempio le IA generative tenderanno a produrre immagini con persone di una certa etnia se sono state addestrate con immagini che contengono prevalentmente quella etnia.

Perchè si parla di etica e intelligenza artificiale? Più questa tecnologia diventa avanzata e di facile accesso, più le vengono affidati compiti delicati senza supervisione. Si pongono quindi problemi del tipo:

- Se una macchina autonoma si trova in una situazione in cui può scegliere se salvare un passante che attraversa la strada deviando in un burrone e uccidere così il guidatore, o salvare il guidatore e investire il passante, che deve fare?
- Se un algoritmo di riconoscimento facciale identifica erroneamente una persona scambiandola per un ricercato, di chi è colpa se viene messa ingiustamente in galera?
- Se un'IA generativa crea un’immagine basandosi su immagini pubblicate su internet, di chi sono i diritti di autore? Stessa cosa per articoli, musiche ecc.
- Se ho un lavoro ripetitivo e poco creativo che una IA può fare altrettanto bene, chi mi protegge dal licenziamento?
- Chi garantisce l'imparzialità dei dati usati per addestrare una IA?
- Chi garantisce che le informazioni pubblicate siano vere e non generate da IA? Chi è in grado di vedere la differenza?
- Come faccio a proteggermi dalla creazione e distribuzione di video falsi con le mie fattezze?
- È giusto che una ditta tenga segreto il suo algoritmo di IA?
- Chi pensa all’impatto ambientale ed energetico degli elaboratori usati per addestrare le reti neurali?

Il campo dell'IA ha fatto progressi strabilianti negli ultimi anni. Cosa possiamo aspettarci dal futuro? Secondo i ricercatori in questo campo, il prossimo passo è l'intelligenza artificiale generale (*Artificial General Intelligence, AGI*), ovvero "vera intelligenza". In altre parole la capacità di un computer di prendere decisioni autonome, riflettere, inventare e in generale essere completamente indistinguibile da un essere umano. A questo punto l'IA sarebbe capace non solo di eguagliare l'essere umano, ma di superarlo. L'ultima considerazione etica dunque è se si debba permettere di arrivare a questo punto.  

P.S.: non ho usato IA per scrivere questo articolo.