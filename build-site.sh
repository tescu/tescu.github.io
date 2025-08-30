#!/usr/bin/env bash
# Simple sitegen powered by Pandoc

export updated=$(date '+%A, %d %B %Y')

# Clean
printf "%s\n" "[INIT] Cleaning html files..."
[ -f "index.html" ] && rm *.html
rm post/*

# Pagini simple / Simple pages
printf "%s\n" "[RUN] Building simple pages..."
for page in ./content/*; do
	# Obține numele simplu (fără locație)
	barename="$(basename $page)"
	# Schimbă extensia în .html
	htmlpage="${barename%.md}.html"
	# Verifică dacă este un fișier
	if [ -f "$page" ]; then
		printf "\t%s\n" "[RUN] Building $barename..."
		pandoc -s --toc --template=res/tmp/page.html "$page" -o "$htmlpage"
	else
		printf "%s\n" "[INFO] Skipping $page (not a file)."
	fi
done

# Postări
printf "%s\n" "[RUN] Buildings posts..."
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
printf "%s\n" "[RUN] Building index.html..."
envsubst < res/tmp/index.html > index.html

# Galerie / Gallery
printf "%s\n" "[RUN] Building gallery..."
export il=""
export pt=""
export sk=""
export ww=""

for img in $(find res/art -type f); do
	bname="$(basename $img)"
	name="$(echo ${bname#*-} | tr '_' ' ')"

	case "$(basename $img)" in
		# ilustratii / illustrations
		il-*)
			export il="$il<div class=\"pic\"><a href=\"$img\"><img src=\"$img\"></a>${name%.*}</div>"
		;;
		# picturi / paintings
		pt-*)
			export pt="$pt<div class=\"pic\"><a href=\"$img\"><img src=\"$img\"></a>${name%.*}</div>"
		;;
		# schite / sketches
		sk-*)
			export sk="$sk<div class=\"pic\"><a href=\"$img\"><img src=\"$img\"></a>${name%.*}</div>"
		;;
		# altele (lemn / wood, etc)
		ww-*)
			export ww="$ww<div class=\"pic\"><a href=\"$img\"><img src=\"$img\"></a>${name%.*}</div>"
		;;
	esac
done
envsubst < res/tmp/gallery.html > gallery.html

printf "\v%s\n" "Done!"
