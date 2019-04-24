#! /bin/bash -x

# +---------------------------------------------------------------------------+
# | Transforme tous les .svg du dossier en .png.                              |
# | Usage:  ./svg2png.sh [-h] parametre1 parametre2                            |
# +---------------------------------------------------------------------------+

# +---------------------------------------------------------------------------+
# |  Fichier     : svg2png.sh                                                  |
# |  Version     : 1.0.0                                                      |
# |  Auteur      : Bruno Boissonnet                                           |
# |  Date        : 20/04/2019                                                 |
# +---------------------------------------------------------------------------+


# Algorithme :
#
# 1. On récupère le mois en cours
# 2. On récupère le mois suivant
# 3. On récupère la date d'aujourd'hui
# 4. On récupère la date de demain
# 5. Utiliser la commande `curl --silent` pour récupérer le code source de la page
# 6. On efface les dix dernières lignes du fichier pour ne pas lire des caractères qui ne sont pas en UTF-8
# 7. On récupère les menus du mois en cours
# 8. On ne garde que la deuxième ligne
# 9. On efface toute la ligne avant <strong>${AUJOURDHUI}<\/strong> et tout après <strong>${DEMAIN}<\/strong>
# 10. On remplace <br /> par des sauts de ligne
# 11. On efface les lignes qui contiennent "<strong>" et les lignes vides


# +---------------------------------------------------------------------------+
# |                             FONCTIONS                                     |
# +---------------------------------------------------------------------------+

NOM_PROJET="carte-de-visite"
VERSION=""

# fonction principale du programme
main()
{
    processParams $@
    mv *.svg ${NOM_PROJET}.svg
    svgVersPng ${NOM_PROJET}.svg
    git add .
    git commit -m "Version "${VERSION}
    git push origin master
    git tag -fa "V"${VERSION}
    git push origin "V"${VERSION}
    rm -f ${NOM_PROJET}.*
    # instructions
    # RESULTAT=$(fonction $1 $2)
}

# Affiche un message d'aide
# Pas de paramètres
usage()
{    
    echo "Usage: $0 [-options] parametre1"
    echo "Crée une nouvelle version du projet SVG"
    echo ""
    echo "    -h:         affiche cette aide"
    echo "    parametre1: Le nom du projet SVG"
    echo "    parametre2: La version du projet SVG"
    echo ""
}

# Procédure de traitement des paramètres du programme
# $1 : les paramètres du programme
# retour : NA
# exemple : processParams $@
processParams()
{
    if [ $# -gt 0 ]; then
        if [ $1 == "-h" ]; then
            usage
            exit 0
        elif [ $# -eq 2 ]; then
            NOM_PROJET="$1"
            VERSION="$2"
        else
            usage
            exit 0
        fi
    else
        usage
        exit 0
    fi
}


# Transforme un fichier svg en png
# [Dans le dossier "Inkscape_PNG"]
# $1 : nom du fichier svg
# retour : NA
# exemple : svgVersPng fichier
TousSvgVersPng()
{
    for i in *.[sS][vV][gG];do
        svgVersPng "$i"
    done
}

# Transforme un fichier svg en png
# [Dans le dossier "Inkscape_PNG"]
# $1 : nom du fichier svg
# retour : NA
# exemple : svgVersPng fichier
svgVersPng()
{
    RET=""
    INKSCAPE_PGM="/Applications/Inkscape.app/Contents/Resources/bin/inkscape"
    PNG=$(nomSansExtension "${1}")
    CWD=$(pwd)
    DEST_DIR="Inkscape_PNG"
    #mkdir "${DEST_DIR}"
    # instructions
    if [ -x "${INKSCAPE_PGM}" ]; then
        #${INKSCAPE_PGM} -z "${CWD}/${1}" -e "${CWD}/${DEST_DIR}/${PNG}.png"
        ${INKSCAPE_PGM} -z "${CWD}/${1}" -e "${CWD}/${PNG}.png"
    else
        echo "Error : Inkscape not found ! Please install Inkscape before runing this script."
    fi
    
    # echo $RET
}


# Renvoi le nom sans l'extension
# $1 : fichier dont on veut le nom
# Retour : le nom sans le chemin ni l'extension
# Exemple : /tmp/my.dir/filename.tar.gz => filename.tar
nomSansExtension()
{
    fichier=$(basename "${1}")
    echo "${fichier%.*}"
}

# +---------------------------------------------------------------------------+
# |                        DÉBUT DU PROGRAMME                                 |
# +---------------------------------------------------------------------------+

main $@

