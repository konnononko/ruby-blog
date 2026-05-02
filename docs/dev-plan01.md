# dev-plan01

この文書には最初の開発のプランを書いています。

## プロジェクト概要

個人開発でrubyでブログWebアプリを開発します。
AIエージェントを利用して開発をします。そのために適宜必要な情報をドキュメント化します（例えばこのドキュメント）。

ブログアプリは最初の機能として以下をもちます。

- ユーザー認証
- 記事の投稿
- コメントの投稿
- 記事の表示

技術スタック

- Rails 8
- Hotwire
- PostgreSQL
- Kamal

テスト

- 実装した機能に対して、最低限のユニットテストを追加しながら動作を確認する
- 網羅や過剰なテストは不要
- テストフレームワークはRSpecを使う

UXデザイン

- 使い方が見てわかる
- 見た目がきれい・かっこいい。使っていて気持ちがいい。

実装方針

- 読んで理解しやすいコードを書く
- シンプルな実装から始め、過剰な設計を最初からしない
- 大規模な変更についてはいきなり行わず、計画をして確認をとる
- モダン・クリーンなコードの書き方のプラクティスにしたがう

ドキュメント

- 開発方針はAIが読めるようにdev-planNN.mdとして記述する
- AIはこちらからの求めに応じて、過去の実装について参照できるよう、作業内容をdev-logNN.mdに記述する
- AIはこちらからの求めに応じて、設計上の重要な判断をした場合には、docs/adr/に ADR として記載する。AIは記載するのが適当な判断があった場合、ADRへの記載が推奨であることを示唆する。

## 開発手順

以下のステップで開発する。

- 方針ドキュメントの作成（このドキュメント）
- 開発環境の準備
- リポジトリの設定。フォルダ構成、フレームワークのセットアップなど
- 機能実装
    - ユーザー認証
    - 記事の投稿
    - 記事の表示
    - コメントの投稿
- レビュー
- リファクタリング

### チェックリスト

開発手順のチェックリストです。この手順は仮のもので、実装時に必要に応じて調整してください。

- [x] 方針ドキュメントの作成
    - [x] プロジェクト概要・目的を記載
    - [x] 技術スタック・実装方針・テスト方針を記載
    - [x] ドキュメント運用ルールを記載
- [x] 開発環境の準備
    - [x] Gitをインストールし、バージョン確認
    - [x] パッケージマネージャー（winget/scoop）をインストール
    - [x] Ruby（RubyInstaller + Devkit）をインストールし、バージョン確認
    - [x] Node.jsをインストールし、バージョン確認
    - [x] Yarnをインストールし、バージョン確認
    - [x] PostgreSQLをインストールし、バージョン確認
    - [x] Railsをインストールし、バージョン確認
- [x] リポジトリの設定
    - [x] Gitリポジトリを初期化
    - [x] .gitignoreを作成
    - [x] フォルダ構成を決定
    - [x] Rails新規プロジェクトを作成
    - [x] 必要なGemを追加
- [x] 最初のRSpec smoke test
- [ ] 機能実装
    - [x] ユーザー認証
        - [x] 認証Gem（例: Devise）の導入
        - [x] ユーザーモデルの作成
        - [x] サインアップ・ログイン・ログアウト機能
        - [x] 認証テストの作成
    - [x] 記事の投稿
        - [x] Articleモデル・マイグレーション作成
        - [x] 記事投稿フォームの実装
        - [x] 記事一覧・詳細ページの作成
        - [x] 投稿・表示のテスト
    - [x] コメントの投稿
        - [x] Commentモデル・マイグレーション作成
        - [x] コメント投稿フォームの実装
        - [x] 記事詳細ページへのコメント表示
        - [x] コメント機能のテスト
- [x] UI/UXの実装
    - [x] デザインシステムの定義と実装
- [ ] レビュー
    - [ ] コードレビュー（自己/AI/他者）
    - [ ] テスト実行・動作確認
- [ ] リファクタリング
    - [ ] コードの整理・改善
    - [ ] 不要なコードやコメントの削除

### 開発環境の準備

1. Gitのインストール  
    https://git-scm.com/download/win  
    インストール後、`git --version`で確認

2. パッケージマネージャー（winget または scoop）  
    - [winget](https://learn.microsoft.com/ja-jp/windows/package-manager/winget/)（Windows 10以降は標準搭載）
    - [scoop](https://scoop.sh/)（コマンドで簡単にインストール可能）

3. Ruby（RubyInstaller + Devkit）  
    https://rubyinstaller.org/  
    Ruby+Devkit版を選択し、インストール時にMSYS2/Devkitセットアップも実行  
    `ruby -v`と`gem -v`で確認

4. Node.jsのインストール  
    https://nodejs.org/ja/download/  
    LTS版推奨  
    `node -v`と`npm -v`で確認

5. Yarnのインストール  
    `npm install --global yarn`  
    `yarn -v`で確認

6. PostgreSQLのインストール  
    https://www.postgresql.org/download/windows/  
    `psql --version`で確認

7. Railsのインストール  
    `gem install rails -v 8.0.0`  
    `rails -v`で確認

8. プロジェクト作成例  
    `rails new ruby-blog -d postgresql`  
    `cd ruby-blog`

9. データベース設定  
    `config/database.yml`を編集（必要に応じてユーザー名・パスワードを設定）  
    `rails db:create` でDB作成

10. 動作確認  
     `rails server` で http://localhost:3000 にアクセス

11. RSpec導入  
     `bundle add rspec-rails --group "development,test"`  
     `rails generate rspec:install`

## ユーザー認証（Devise）導入手順（最小）

前提:
- 認証は Devise を使用する
- モデル名は User
- 必須項目は email + password

手順:

1. Devise追加
    - `bundle add devise`
    - `bundle install`

2. Devise初期化
    - `bundle exec rails generate devise:install`

3. Userモデル作成（Devise）
    - `bundle exec rails generate devise User`

4. DB反映
    - `bundle exec rails db:migrate`
    - `RAILS_ENV=test bundle exec rails db:prepare`

5. 動作確認（最小）
    - `bundle exec rails server`
    - サインイン画面にアクセス（例: `/users/sign_in`）

6. テスト（最小）
    - `bundle exec rspec`

補足:

- 最小ログインログアウト画面遷移のナビをレイアウトに追加
- 最小モデルとリクエストのテストを追加

## 記事の投稿（Article）実装手順（概要）

前提:
- 記事は User に紐づく（`Article` は `User` に `belongs_to`、User 側は `has_many`）
- 投稿・編集・削除はログイン必須とする（一覧・詳細の公開範囲は別ステップで調整してよい）

手順:

1. Article のモデルとマイグレーションを用意する
    - 例: `title`、`body`（本文）、`user_id`（外部キー）
    - モデルだけ先に作る例: `bundle exec rails generate model Article title:string body:text user:references`
    - CRUDのひな形まで一気に作る例: `bundle exec rails generate scaffold Article title:string body:text user:references`

2. `User` モデルに `has_many :articles` を追加する（必要なら `dependent` も検討）

3. DBを反映する
    - `bundle exec rails db:migrate`
    - `RAILS_ENV=test bundle exec rails db:prepare`

4. ルーティングを整える
    - 例: `resources :articles`（必要に応じて `only` / `except` で絞る）

5. コントローラで認可と Strong Parameters を入れる
    - `before_action :authenticate_user!`（新規・作成・編集・更新・削除など、要件に合わせて適用）
    - `article_params` で許可するカラムを限定する（`user_id` はフォームから渡させず、サーバ側で `current_user` から紐づけるのが安全）

6. 画面を確認する
    - `bundle exec rails server` で一覧・詳細・投稿フォームが動くこと

7. テスト（最小）
    - モデル: 必須カラムのバリデーションなど
    - リクエスト: 未ログインで書き込み系にアクセスできないこと、など

補足:

- 「読者への公開」や下書きは、別途カラム（例: `published` や `published_at`）を足してからでもよい
- 検討の結果、MVPとしては公開フラグ/下書きなし、投稿したものは未ログインユーザー含め全員に公開

## コメントの投稿（Comment）実装手順（概要）

前提:
- コメントはログインユーザーのみが作成・削除できる（未ログインはコメント不可）
- Comment は Article と User に紐づく（`belongs_to :article`、`belongs_to :user`）

手順:

1. Comment のモデルとマイグレーションを用意する
    - 例: `body`（本文）、`article_id`、`user_id`（いずれも外部キー、`body` は text が無難）
    - ジェネレータ例: `bundle exec rails generate model Comment body:text article:references user:references`

2. `Article` に `has_many :comments` を、`User` に `has_many :comments` を追加する（`dependent` は要件に応じて）

3. DBを反映する
    - `bundle exec rails db:migrate`
    - `RAILS_ENV=test bundle exec rails db:prepare`

4. ルーティングを整える
    - 例: `resources :articles` の内側に `resources :comments, only: [:create, :destroy]` をネストする

5. CommentsController を用意する
    - `before_action :authenticate_user!`
    - `create`: 対象の Article を特定し、`current_user` と紐づいた Comment を保存する（`user_id` はフォームから渡さない）
    - `destroy`: コメントの投稿者本人、または記事の作者のみ削除可、などルールを決めて承認する

6. 記事の詳細画面に一覧・フォームを載せる
    - `articles/show` にコメント一覧と、ログイン時のみ表示する投稿フォーム（未ログイン時は案内文でもよい）

7. テスト（最小）
    - モデル: `body` 必須など
    - リクエスト: 未ログインで `POST` できないこと、ログイン済みで作成できること、など

補足:

- MVPでは匿名コメントは扱わず、`user_id` 必須で進めると実装が単純になる

## デザインシステム方針（MVP以降の見た目整備）

方針:
- まず CSS 変数で色・余白・影・角丸・ぼかしなどのトークン（ルール）を定義する
- そのトークンに沿って、素の CSS でナビ・カード・ボタン・フォームなどを揃える（大きな UI フレームワークは必須としない）

トーン（採用）:
- ライト寄りのウォームトーン。背景はクリーム〜ウォームグレーの弱いグラデを想定する
- アクセントはアンバー〜オレンジ系（リンク・主ボタン・強調に限定し、本文や長文をアクセント色のまま広く使わない）
- 彩度は抑えめにし、長文読書での疲れを避ける

狙う視覚効果:
- ガラス調（半透明のサーフェス + `backdrop-filter` の弱いぼかし + 薄い境界線）。効き過ぎない強さから試す
- ごく弱い背景グラデーション、控えめな影と角丸、ホバー時は移動・影・明度など変化を少数パターンに統一する

コントラストと操作性:
- 本文と背景のコントラストを優先する（ガラス上の文字は薄くなりやすいので注意）
- フォーカスリング（キーボード操作）を忘れない

実装の置き場所（目安）:
- `app/assets/stylesheets/application.css` を中心にトークンとコンポーネント用クラスを追加し、レイアウトと主要ビューにクラスを付与していく

## デザインシステム実装手順（概要）

前提:
- 上記「デザインシステム方針」のトーン（ウォームライト + アンバー系アクセント）に沿う

手順:

1. デザイントークンを CSS 変数で定義する
    - `:root` に色（背景・サーフェス・本文・控えめテキスト・境界・アクセント・ホバー）、余白の段階、角丸、影、ガラス用（半透明・ぼかし）を置く

2. ベーススタイルを当てる
    - `body` にフォントファミリー、本文色、背景の弱いグラデ
    - リンク（`a`）とフォーカス可視化（`:focus-visible`）のルール

3. レイアウトの骨格を整える
    - `application.html.erb` にページ全体のラッパー（最大幅・横余白）とナビ用のクラスを付与する

4. 再利用用クラスを少しずつ追加する
    - 例: ガラス風パネル、カード、主ボタン・副ボタン、入力欄。ホバーはパターンを絞る

5. 画面ごとに当てていく（おすすめ順）
    - トップ（`pages/home`）→ 記事一覧・詳細（`articles`）→ 記事の新規・編集フォーム → 記事詳細内のコメント欄

6. 仕上げ
    - 狭い画面幅での余白・フォントサイズの確認、ガラス上の文字の読みやすさの再確認、ホバーとフォーカスの両立

補足:

- 一度に全面を変えず、トークン → レイアウト → 主要ページの順で差分を小さく保つと調整しやすい
