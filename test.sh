while read line; do
	if [[ $line == *'Word'* ]]; then
		echo "Word found"
	fi
		
done < /etc/shadow
