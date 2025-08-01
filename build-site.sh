#!/usr/bin/env bash
# Simple sitegen powered by Pandoc

export updated=$(date '+%A, %d %B %Y')

# Clean
printf "%s\n" "Cleaning html files..."
[ -f "index.html" ] && rm *.html
rm post/*

# Pagini simple / Simple pages
echo "[RUN] Building simple pages..."
for page in ./content/*; do
	# Obține numele simplu (fără locație)
	barename="$(basename $page)"
	# Schimbă extensia în .html
	htmlpage="${barename%.md}.html"
	# Verifică dacă este un fișier
	if [ -f "$page" ]; then
		printf "\t%s\n" "Building $barename..."
		pandoc -s --toc --template=res/tmp/page.html "$page" -o "$htmlpage"
	else
		printf "%s\n" "INFO: Skipping $page (not a file)."
	fi
done

# Postări
echo "[RUN] Buildings posts..."
export articles=""
for post in $(find ./content/post/ -type f | sort -r); do
	# idem.
	barename="$(basename $post)"
	out="post/${barename%.md}.html"
	pdate="${barename%%_*}"
	printf "\t%s\n" "Building $barename..."
	pandoc -s --toc --template=res/tmp/post.html "$post" -o "$out"
	# Genereaza lista din index.html
	# - Obține titlul si limba
	ptitle="$(sed '2q;d' $post | sed 's/title: //')"
	plang="$(sed '3q;d' $post | sed 's/lang: //')"
	# Alege imaginea in functie de optiune
	case "$plang" in
		"ro-en") lang="(ro, en) <img src=\"./res/ro.gif\" title=\"(ro)\" /><img src=\"./res/en.gif\" title=\"(en)\" />"
		;;
		"es") lang="(es) <img src=\"./res/es.gif\" title=\"(es)\" />"
		;;
		*) lang="(ro) <img src=\"./res/ro.gif\" title=\"(ro)\" />"
		;;
	esac
	export articles="$articles<li><p><a href="$out"><em>$ptitle</em></a><br/>$pdate | $lang</p></li>"
done

# Index
echo "[RUN] Building index.html..."
envsubst < res/tmp/index.html > index.html

# Art gallery
echo "[RUN] Building gallery in art.html..."
export illust=""
export sketches=""
export extra=""
for draw in ./res/art/*.jpg; do
	barename="$(basename $draw)"
	title="$(sed 's/^...//' <<< "$barename")"
	# debug
	#printf "%s\n" "$barename ($title) -- $draw"
	case "$barename" in
		sk-*) export sketches="$sketches<div class=\"pic\"><a href=\"./res/art/$barename\"><img src=\"./res/art/$barename\"></a><p>${title%.jpg}</p></div>"
		;;
		il-*) export illust="$illust<div class=\"pic\"><a href=\"./res/art/$barename\"><img src=\"./res/art/$barename\"></a><p>${title%.jpg}</p></div>"
		;;
		ex-*) export extra="$extra<div class=\"pic\"><a href=\"./res/art/$barename\"><img src=\"./res/art/$barename\"></a><p>${title%.jpg}</p></div>"
		;;
	esac
done
envsubst < res/tmp/art.html > art.html

printf "\v%s\n" "Done!"
