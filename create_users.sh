#!/bin/bash
# shebang: "#!/bin/bash" berättar för linux att detta skriptet är med bash-token. Så att linux förstår hur den ska köras.



# Skriptet ska kolla så att den som kör den är root annars avsluta med ett meddelande
# Kollar om det är sudo som kör annars avslutas scriptet och då får man fel meddelandet.
if [ "$EUID" -ne 0 ]; then
    # Har inte tillgång att köra då man kör den inte som en admin
    echo "Detta script måste köras som root"
    # om inte admin så avslutas scriptet
    exit 1
else
    # Du har admin behörighet att köra
    echo "Du har tillgång att köra detta scriptet"
fi # avslutar if satsen




# Skriptet ska ta in en lista av användare
# Vi skickar med några namn som argument när vi kör koden typ kalle, pelle och göran.
# Dessa loopas igenom och sedan kan vi använda oss utav dem som vi vill ha det.
for user in "$@"; do
    # Kollar om användaren redan finns dvs finns det någon som heter kaller så avslutas inte koden
    # Utan den forstätter bara istället.
    if getent passwd "$user" > /dev/null; then
        echo "Användaren $user finns redan, hoppar över..."
        continue # Hoppar direkt till nästa användare i listan.
    fi

    # lägger till ny användare i systemet
    useradd -m "$user" # -m skappar automatiskt åt användaren en hemkatalog som gör det lättare för personen.
    echo "Skapar ny användare vid namn: $user"
    
    # Skriptet ska loopa igenom varje användare och skapa mappar för var och en av dem i deras hem katalog
    # Skapa map Documents
    mkdir -p /home/"$user"/Documents
    # Skapa map Downloads
    mkdir -p /home/"$user"/Downloads
    # Skapa map Work
    mkdir -p /home/"$user"/Work

    # Se till att användaren äger sina mappar (För att göra det säkert)
    chown -R "$user":"$user" /home/"$user"

    # Skriptet ska se till att bara ägaren av dessa mapar kommer kunna redigera och läsa det som finns i.
    # Sätter behörigheter så att bara användaren kan komma åt dess egna mappar.
    chmod 700 /home/"$user"/Documents
    chmod 700 /home/"$user"/Downloads
    chmod 700 /home/"$user"/Work

    # tar bort om det skapades någon welcome.txt per automatik
    rm -f /home/"$user"/welcome.txt

    # Ett välkommst meddelande. welcome.txt - med ett personligt meddelande i formatet: Välkommen <användare>
    echo "Välkommen $user" > /home/"$user"/welcome.txt

    # Skriver in i welcome.txt också en lista på alla redan skapade användare på raden under "Välkommen <användare>"
    # testar att loopa in användarna.
    for u in "$@"; do
        echo "$u" >> /home/"$user"/welcome.txt
    done
    



done

