import psycopg2

# MERK: Må kjøres med Python 3

user = 'romanse' # Sett inn ditt UiO-brukernavn ("_priv" blir lagt til under)
pwd = 'Wu1kei6Phi' # Sett inn passordet for _priv-brukeren du fikk i en mail

connection = \
    "dbname='" + user + "' " +  \
    "user='" + user + "_priv' " + \
    "port='5432' " +  \
    "host='dbpg-ifi-kurs03.uio.no' " + \
    "password='" + pwd + "'"

def huffsa():
    conn = psycopg2.connect(connection)

    ch = 0
    while (ch != 3):
        print("--[ HUFFSA ]--")
        print("Vennligst velg et alternativ:\n 1. Søk etter planet\n 2. Legg inn forsøksresultat\n 3. Avslutt")
        ch = int(input("Valg: "))

        if (ch == 1):
            planet_sok(conn)
        elif (ch == 2):
            legg_inn_resultat(conn)

def planet_sok(conn):
    # TODO: Oppg 1
    print(" -- [PLANET-SØK] -- ")

    molekyl1 = input("Molekyl 1: ")
    molekyl2 = input("Molekyl 2: ")

    if molekyl1 == "" and molekyl2 == "":
        print("Ingen molekyler oppgitt")
        print("Avlsutter søk!")
        return

    q = "SELECT p.navn, p.masse, s.masse, s.avstand, p.liv " + \
        "FROM planet as p " + \
        "INNER JOIN stjerne AS s ON (p.stjerne = s.navn) " + \
        "INNER JOIN materie AS m1 ON (p.navn = m1.planet) "

    if molekyl2 != "":
        q += "INNER JOIN materie AS m2 ON (p.navn = m2.planet) "
        q += "WHERE m1.molekyl = %(molekyl1)s "
        q += "AND m2.molekyl = %(molekyl2)s "
    else:
        q += "WHERE m1.molekyl = %(molekyl1)s"

    q+= "ORDER BY s.avstand ASC"

    cur = conn.cursor()
    cur.execute(q, {'molekyl1' : molekyl1, 'molekyl2' : molekyl2})
    rows = cur.fetchall()

    if rows == []:
        print("Ingen resultater:")
        return

    print(" -- RESULTATER -- " + "\n")

    for row in rows:
        print(" -- Planet -- ")
        liv = ""
        if row[4] == False:
            liv = "Nei"
        else:
            liv = "Ja"
        print("Navn: " + str(row[0]) + "\n" + \
              "Planet-masse: " + str(row[1]) + "\n" + \
              "Stjerne-masse: " + str(row[2]) + "\n" + \
              "Stjerne-avstand: " + str(row[3]) + "\n" + \
              "Planet-liv: " + liv)
        print()


    pass

def legg_inn_resultat(conn):
    # TODO: Oppg 2
    print(" -- [LEGG INN RESULTAT] -- ")

    planet = input("Planet: ")
    skummel = input("Skummel: ")
    intelligent = input("Intelligent: ")
    beskrivelse = input("Beskrivelse: ")

    q = "UPDATE planet " + \
        "SET skummel = %(skummel)s, intelligent = %(intelligent)s, beskrivelse = %(beskrivelse)s " + \
        "WHERE navn = %(planet)s"

    if skummel == "j":
        skummel = True
    else:
        skummel = False

    if intelligent == "j":
        intelligent = True
    else:
        intelligent = False

    cur = conn.cursor()
    cur.execute(q, {'planet' : planet, 'skummel' : skummel, 'intelligent' : intelligent, 'beskrivelse' : beskrivelse})
    conn.commit()

    print("Resultat lagt inn.")

    pass

if __name__ == "__main__":
    huffsa()
