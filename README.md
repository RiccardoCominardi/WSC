# WSC
Web Services Connector

TODO

Creazione tabella per selezione del Body:
- Simil tabella delle Header in cui si possono impostare dei body fissi nel caso in cui non si scelga di importare un file 

PER CONTROLLO DEL CORE

Invio Chiamata Manuale:
- Impostare una chiamata manuale del servizio. Se la chiamata deve aver un file nel body allora permettere di importare un file (se possibiel drag and drop con Javascript) e alla fine di scaricare la risposta (se possibile con Bottone Javascript)

Controllare il sito Microsoft:
https://learn.microsoft.com/en-us/dynamics365/release-plan/2023wave1/smb/dynamics365-business-central/drag-drop-files-onto-file-upload-dialog
Forse viene implementata di standard
Sito che usa js
https://vld-nav.com/drag-and-drop-factbox


DOPO LO SVILUPPO DEL CORE

Scelta HEADER facilitata: 
- Permette la selezione e l'importazione di Header già configurate. Ci sarà un bottone che ti scarica e ti mette una header con un template pre-caricato. Se la Header è già presente far comparire un messaggio per sostituirla o meno
Url per le Header da impostare: https://www.holisticseo.digital/technical-seo/http-header/
Creare codeunit di migrazione per gestire l'inserimento delle header;
https://www.bc-journal.com/post/work-with-installing-and-upgrading-codeunits-in-dynamics-365-business-central

Visualizzazione ad albero:
- Aprire una pagina temporanea in cui verrà mostrata una visualizzazione ad albero per i Token bearer e per i Gruppi. Essendo che i token possono appartenere a più chiamata non sarà possibile farlo con dati fisici ma partiamo da una temp in modo da "Sdoppiare" il Token solo per una migliore visualizzazione dell'utente.

Chiamate API provate e funzionanti:

Prokuria:
- GET VENDORS
- GET Send Order From BC To Prok
- POST CHANGE_STATUS
- POST INSERT_HEADER
- POST UPDATE_HEADER
- POST INSERT_LINE
- POST UPDATE_LINE