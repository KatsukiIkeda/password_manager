#!/bin/bash

echo "パスワードマネージャーへようこそ！"  

while true; do
    echo "次の選択肢から入力してください(Add Password/Get Password/Exit)："
    read select

    if [ "$select" == "Add Password" ]; then

		# パスワード情報を入力し、空の場合は再入力を促す		
		while [ -z "$service" ]; do
    		read -p "サービス名を入力してください: " service
		done

		while [ -z "$username" ]; do
    		read -p "ユーザー名を入力してください: " username
		done

		while [ -z "$password" ]; do
    		read -p "パスワードを入力してください: " password
		done
		
		# パスワードファイルが存在する場合に復号化　
		# パスワードを直接シェルスクリプトに記述せず、代わりに環境変数USERを使用
		if [ -f "password.txt.gpg" ]; then
		gpg --batch --quiet --passphrase-fd 0 -o password.txt -d password.txt.gpg <<< "$USER"
		fi

		echo "$service:$username:$password" >> password.txt
		
		# ファイルを再度暗号化
		gpg --batch --quiet --passphrase-fd 0 -c --yes password.txt <<< "$USER"
		rm password.txt
		
		# 一時的な変数をリセット
		service=""
		username=""
		password=""

	elif [ "$select" == "Get Password" ]; then
        read -p "サービス名を入力してください：" set_service

		 # パスワードファイルが存在する場合、復号化して情報を取得
		if [ -f "password.txt.gpg" ]; then
			gpg --batch --quiet --passphrase-fd 0 -o password.txt -d password.txt.gpg <<< "$USER"
        fi

		# grep で検索した結果を全て取得
        get_service=$(grep "^$set_service:" password.txt 2>/dev/null)

        if [ -z "$get_service" ]; then
            echo "そのサービスは登録されていません。"
        else
		# 同一サービス名のパスワード情報を全て見出し付きで表示
            echo "$get_service" | while read line; do
                echo "サービス名: $(echo "$line" | cut -d':' -f1)"
                echo "ユーザー名: $(echo "$line" | cut -d':' -f2)"
                echo "パスワード: $(echo "$line" | cut -d':' -f3)"
			done
		fi
		rm -f password.txt

    elif [ "$select" == "Exit" ]; then
        echo "Thank you!"
        exit 0

    else
        echo "入力が間違えています。Add Password/Get Password/Exit から入力してください。"
    fi
done
