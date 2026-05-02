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
- [x] レビュー
    - [x] コードレビュー（自己/AI/他者）
    - [x] テスト実行・動作確認
- [x] リファクタリング
    - [x] コードの整理・改善
    - [x] 不要なコードやコメントの削除
- [ ] CI/CD (Github Actions) 実装
    - [ ] CI 自動テスト
    - [ ] 自動デプロイ？
- [ ] Readme 整備

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

## MVP実装レビュー（記録）

認証・記事 CRUD・ネストしたコメントの権限モデルが一貫しており、`strong_parameters` とネストルーティング（`article_id` でコメントを特定）も妥当。MVP としての土台は十分よい。

### 良い点

- 認可: `ArticlesController` では `edit` / `update` / `destroy` のみ所有者チェック（`authorize_owner!`）。`show` / `index` はゲスト可でプランどおり。`CommentsController` は常時ログイン必須。コメント削除は「投稿者または記事作者」のみ許可し、ビュー側の表示条件と一致している。
- データ整合性: `schema.rb` で記事・コメントの外部キーが張られている。
- ユーザー紐づけ: 記事は `current_user.articles.build`、コメントは `user_id` をフォームから渡さずサーバ側で `current_user` を設定している。
- 表示: 本文・コメントは `simple_format` によりエスケープされた段落表示で、素の `html_safe` より安全側。
- テスト: コメント削除について「他人不可・投稿者可・作者可」がリクエスト spec で押さえられている。

### 改善余地・リスク（優先度は用途次第）

1. 記事の編集・削除の認可テスト: `authorize_owner!` のロジックは妥当だが、別ユーザーの記事に対する `GET edit` / `PATCH` / `DELETE` がリダイレクトすることは現状の `articles` リクエスト spec では未確認。リファクタ時に壊れやすいので、必要なら少なくとも各 1 本追加を検討。
2. モデル spec: `Article` はタイトル無し程度の検証に留まっている。`body` の presence や `Comment` のバリデーションをモデル spec で軽く触れてもよい。
3. DB とバリデーション: `articles` の `title` / `body` は DB 上 NULL 許容で、アプリは `validates` に依存。厳密にするなら後から NOT NULL 制約も検討対象。
4. コメント作成失敗時の UX: バリデーションエラー時は `redirect` と `alert` のみで、入力内容は保持されない。MVP では許容しつつ、長文入力後の失敗ではストレスになり得る。
5. コメント表示で `user.email` をそのまま表示している。公開ブログではプライバシーやスパムの観点から、将来「表示名」やマスクを検討する余地あり。
6. 運用: `ApplicationController` の `allow_browser versions: :modern` は古いブラウザをブロックする。意図どおりかだけ認識しておく。Devise の `mailer_sender` はプレースホルダのままなら、本番でメール送信する前に差し替えが必要。
7. スケール: 記事一覧は全件 `order(created_at: :desc)`。件数が増えたらページネーション等が必要になるが、MVP 範囲外でよい。

### まとめ

要件どおり「ゲスト閲覧・ログイン投稿・作者のみ記事編集・コメントはログイン必須・削除は投稿者か記事作者」がコードと画面で揃っており、セキュリティ上の大きな穴は指摘事項に含まれない。足りないとするなら主に記事まわりの認可のリクエストテストと、運用上のメーラー From・一覧の件数増への備え。

## リファクタリング観点（現時点での記録）

MVP の規模でも効きやすい整理と、今は見送ってよいものを区別しておく。

### 優先度が高い: 権限ロジックの一箇所化

記事の所有者判定とコメント削除可否が、コントローラと `articles/show` のビューに二重になっている。ルール変更やレビュー時にズレやすいので、`Article` に「編集・削除できるユーザーか」（例: `editable_by?(user)` や `owned_by?(user)`）、`Comment` に「削除できるユーザーか」（例: `deletable_by?(user)` で記事作者も内部判定）のようなメソッドを置き、コントローラとビューはそれを呼ぶ形に寄せるとよい。規模がもう一段増える前に手を入れるコスト対効果が大きい。

### 優先度が中程度

- 一覧の並び: `Article.order(created_at: :desc)` に名前を付ける（例: `scope :recent`）と意図がコードに残る。
- 文言・ページタイトル: `notice` / `alert` や `content_for :title` の `"… — Ruby Blog"` が散らばっている。必須ではないが、I18n や `ApplicationHelper` のタイトル用ヘルパーでまとめる選択肢がある（ヘルパーは現状空でもよい）。

### 優先度が低い・見送りでよいもの

- 記事フォームと Devise のエラー表示パーシャルの共通化は可能だが、マークアップ差があり、今すぐ必須ではない。
- Pundit / Action Policy 等はルールが増えたタイミングでよい。現状はモデルにメソッドを置く程度で足りることが多い。
- サービスオブジェクト / フォームオブジェクトは、コメント作成が単紙保存のままなら不要。

### 優先度の目安（一覧）

- 高: 権限ロジックをモデル（または単一モジュール）に寄せ、コントローラと詳細ビューの重複をなくす。
- 中: 一覧用 `scope`、タイトル用ヘルパーまたは I18n。
- 低: エラー表示の共通化、細かい文言整理。

## 優先度高リファクタ（権限の一箇所化）— 作業手順の概要

前提: 記事の編集・削除は記事の所有者のみ。コメントの削除はコメント投稿者または記事の作者のみ。既存の挙動を変えず、判定式だけモデルに寄せる。

1. メソッド名と契約を決める
    - 例: `Article#editable_by?(user)`（または `owned_by?(user)`）。`user` が `nil` のときは常に false とするなど、一度だけ決める。
    - 例: `Comment#deletable_by?(user)`。投稿者一致または `article` の `user_id` 一致をこの中で判定する。

2. `Article` に実装する
    - 現状の `@article.user_id == current_user.id` と同値になるように書く。

3. `ArticlesController` を差し替える
    - `authorize_owner!` 内の判定を `editable_by?(current_user)`（または選んだ名前）に置き換える。

4. `Comment` に実装する
    - 現状の `comment_destroy_allowed?` と同値になるように書く（内部で `article` を参照して作者判定する）。

5. `CommentsController` を差し替える
    - `comment_destroy_allowed?` を削除または薄くし、`@comment.deletable_by?(current_user)` に寄せる。

6. `articles/show.html.erb` を差し替える
    - 記事ツールバー表示条件を `@article.editable_by?(current_user)` とし、ログイン済み前提なら `user_signed_in? &&` と組み合わせる（`editable_by?` が `nil` を false にするなら、`user_signed_in? &&` は省略できる設計も可。どちらかに統一する）。
    - コメント削除ボタン表示を `@comment.deletable_by?(current_user)`（と必要ならログイン条件）に置き換える。

7. テストを足す・流す
    - モデル spec: `editable_by?` / `deletable_by?` の代表ケース（所有者・他人・作者・第三者など）。
    - `bundle exec rspec` で既存のリクエスト spec が通ることを確認。未実施なら、別ユーザーの記事に対する `edit` / `update` / `destroy` のリダイレクトをリクエスト spec で 1 本ずつ足すと、このリファクタの安全網になる。

8. ブラウザ確認
    - ゲスト・別ユーザー・作者・コメント投稿者のそれぞれで、ツールバーと削除ボタンの出し分けが以前と同じか確認する。

## CI で RSpec を実行する—作業手順の概要

このプロジェクトはテストを **RSpec**（`spec/`）で書いており、GitHub Actions のワークフローは Rails が生成した **Minitest 向け（`bin/rails test`）のまま残っている可能性**がある。またトリガーが **`master`** のみだが、リポジトリのメインブランチは **`main`** を使う。

### 方針

- `.github/workflows/ci.yml` を修正し、テストジョブで **`bundle exec rspec`** を実行する。
- **`push` の対象ブランチを `main` に合わせる**。フィーチャーブランチの push でも CI を回したい場合は、`push` にブランチ制限を設けない、または複数ブランチを列挙する。

### 手順（ワークフロー）

1. **`on.push.branches` の確認・変更**  
    - `master` のみになっている場合は **`main`** に変更する。プルリクエスト経由だけでよければ `pull_request:` はそのままでよい。

2. **`test` ジョブのコマンド差し替え**  
    - 現状が `bin/rails db:test:prepare test` や `bin/rails test` 系であれば、テスト DB 準備のあと RSpec を実行する。例: 同一ステップで `bin/rails db:test:prepare` のあと `bundle exec rspec`、またはプロジェクトで使っているコマンドに統一する。  
    - 環境変数は既存どおり `RAILS_ENV=test`、`DATABASE_URL`（Postgres サービスと整合）を維持する。

3. **`system-test` ジョブの扱い**  
    - Minitest の `test:system` を実行している場合、RSpec では **`spec/system`** にシステムテストを置く前提になる。まだ `spec/system` に spec が無いなら、ジョブを削除するか条件付きスキップするか、将来追加時に `bundle exec rspec spec/system`（またはタグ指定）に差し替える方針を決める。

4. **ローカルでの確認**  
    - `bundle exec rspec` が通ることを確認したうえで、ブランチを push し、GitHub の Actions タブでワークフローが緑になることを確認する。

### 補足（メインブランチ名）

- GitHub のリポジトリ設定で **デフォルトブランチが `main`** になっていることと、`ci.yml` の `push.branches` が一致していることを確認する。`master` のままだと `main` へ直 push したときにテストジョブが走らない。

### 補足（既存の CI ジョブ）

- `scan_ruby`（Brakeman、bundler-audit）、`scan_js`（importmap audit）、`lint`（RuboCop）は、RSpec 化と独立に残してよい。必要に応じて同じ PR で触る。

### 補足（CI と `RUBY_BLOG_DATABASE_PASSWORD`）

- テストジョブで `DATABASE_URL`（例: `postgres://postgres:postgres@localhost:5432`）を渡している場合、Rails は URL の認証情報で接続するため、**CI では `RUBY_BLOG_DATABASE_PASSWORD` を別途設定しなくてよい**。ローカルの `.env` で使うパスワード変数とは別扱いになる。
