#! /bin/bash

# +---------------------------------------------------------------------------+
# | Crée une nouvelle version du projet SVG.                                  |
# | Usage:  ./svg2github.sh [-h] nomFichierSVG version                        |
# +---------------------------------------------------------------------------+

# +---------------------------------------------------------------------------+
# |  Fichier     : svg2github.sh                                              |
# |  Version     : 1.1.0                                                      |
# |  Auteur      : Bruno Boissonnet                                           |
# |  Date        : 20/04/2019                                                 |
# +---------------------------------------------------------------------------+


# +---------------------------------------------------------------------------+
# |                             FONCTIONS                                     |
# +---------------------------------------------------------------------------+

NOM_PROJET=""
VERSION=""

# fonction principale du programme
main()
{
    processParams $@
    
    RenommeTousLesSVG
        
    TousSvgVersPng
    TousSvgVersPDF

    EnregistreDansDepotGitEtGitHub "Version ${VERSION}"
    if [ $? -ne 0 ]; then
        PoseUnTagSurDepotGitEtGitHub "V${VERSION}"
    fi
    
    # rm -f ${NOM_PROJET}.*
}

# Affiche un message d'aide
# Pas de paramètres
usage()
{    
    echo "Usage: $0 [-options] nomFichierSVG Version"
    echo "Crée une nouvelle version du projet SVG"
    echo ""
    echo "    -h            : affiche cette aide"
    echo "    nomFichierSVG : Le nom du projet SVG"
    echo "    Version       : La version du projet SVG"
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

# Renomme tous les fichiers .svg du dossier en cours
# sour la forme : "NOM_PROJET_X.svg" => ex : carte-de-visite_1.svg
# retour : NA
# exemple : RenommeTousLesSVG
RenommeTousLesSVG()
{
    COMPTEUR=1
    for i in *.[sS][vV][gG];do
        # echo ${i}
        # echo ${NOM_PROJET}_${COMPTEUR}.svg
        mv "${i}" "${NOM_PROJET}_${COMPTEUR}.svg"
        let COMPTEUR++
    done
}


# Appelle la fonction svgVersPng
# sur tous les fichiers .svg du dossier en cours
# retour : NA
# exemple : TousSvgVersPng
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


# Appelle la fonction svgVersPDF
# sur tous les fichiers .svg du dossier en cours
# retour : NA
# exemple : TousSvgVersPng
TousSvgVersPDF()
{
    for i in *.[sS][vV][gG];do
        svgVersPDF "$i"
    done
}

# Transforme un fichier svg en PDF
# $1 : nom du fichier PDF
# retour : NA
# exemple : svgVersPDF fichier
svgVersPDF()
{
    RET=""
    INKSCAPE_PGM="/Applications/Inkscape.app/Contents/Resources/bin/inkscape"
    PDF=$(nomSansExtension "${1}")
    CWD=$(pwd)
        
    if [ -x "${INKSCAPE_PGM}" ]; then
        ${INKSCAPE_PGM} -z "${CWD}/${1}" --export-pdf="${CWD}/${PDF}.PDF"
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

# Enregistre tous les fichiers du dossier en cours
# dans le dépôt git et envoi cet instantanné sur GitHub.
# $1 : Message de la consigne
# Retour : 0 si erreur, ≠ 0 si OK
# Exemple : EnregistreDansDepotGitEtGitHub "modif cadre"
EnregistreDansDepotGitEtGitHub()
{
    if [ $# -gt 0 ]; then
        git add .
        git commit -m "${1}"
        git push origin master
    else
        exit 0
    fi
    
}


# Pose un tag sur le dernier commit du dépôt
# et sur le dépôt GitHub.
# $1 : Numéro de version pour le tag
# Retour : 0 si erreur, ≠ 0 si OK
# Exemple : PoseUnTagSurDepotGitEtGitHub "1.2.3"
PoseUnTagSurDepotGitEtGitHub()
{
    if [ $# -gt 0 ]; then
        git tag "V${1}"
        git push origin "V${1}"
    else
        exit 0
    fi
    
}


# +---------------------------------------------------------------------------+
# |                        DÉBUT DU PROGRAMME                                 |
# +---------------------------------------------------------------------------+

main $@

