# Povijesni Ex-Yu i Svjetski Kalendar za Linux Terminal

Ovaj projekt donosi jedinstvenu, kronološki posloženu bazu povijesnih podataka za Linux alat `calendar`, potpuno prilagođenu hrvatskom jeziku. 

Kalendar sadrži važne datume i svjedočanstva iz Domovinskog rata (uključujući operacije **Otkos 10**, **Orkan 91**, **Maslenicu** i **herojsku obranu Šibenika 1991.**), akcije Specijalne jedinice policije na Papuku (Zvečevo), Narodnooslobodilačku borbu (NOB), partizanske heroje, diverzije, kao i ključne prekretnice iz moderne svjetske povijesti (ratove u Iraku, Siriji, Libiji, Čečeniji, Gruziji te udar na Twinse i Afganistan).

## Kako instalirati i pokrenuti na svom Linuxu?

Upišite sljedeću naredbu u svoj terminal kako biste automatski preuzeli bazu i povezali je sa sustavom:

```bash
mkdir -p ~/.calendar && wget https://githubusercontent.com -O ~/.calendar/calendar.nob && echo "#include </home/\$USER/.calendar/calendar.nob>" > ~/.calendar/calendar
```

Nakon toga, kalendar pokrećete jednostavnom naredbom:
```bash
calendar -f ~/.calendar/calendar
```

Ukoliko želite provjeriti specifične povijesne datume (npr. Dan Republike), koristite parametar `-t` s oznakom mjeseca i dana (MMDD):
```bash
calendar -f ~/.calendar/calendar -t 1129
```
